module apocalypse::pool_system {
    use std::vector::{Self};

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::transfer::{Self};
    use sui::package::{Self};

    use apocalypse::world::{Self as w, World, AdminCap};
    use apocalypse::pool_schema::{Self as pool_schema};
    use apocalypse::staker_map_schema::{Self as staker_map};
    use apocalypse::pool_map_schema::{Self as pool_map};
    use apocalypse::prop_system::{Self as p, Prop};
    use apocalypse::card_system::{Self as c, Card};

    friend apocalypse::game_system;

    // ----------Errors----------
    const ENotAdmin: u64 = 0;
    const EInsufficientCoin: u64 = 1;
    const EInsufficientPropBalance: u64 = 2;
    const ENotPropOwner: u64 = 3;

    // ----------Consts----------
    const SCISSORS: vector<u8> = b"scissors";
    const ROCK: vector<u8> = b"rock";
    const PAPER: vector<u8> = b"paper";

    // ----------Structs----------
    struct Pool has key {
        id: UID,
        balance: Balance<SUI>,
        staking_props: vector<Prop>,
        gaming_props: vector<Prop>,
    }
    
    struct POOL_SYSTEM has drop {}

    // ----------Init----------
    #[allow(unused_function)]
    fun init (otw: POOL_SYSTEM, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);

        transfer::share_object(Pool {
            id: object::new(ctx),
            balance: balance::zero(),
            staking_props: vector::empty(),
            gaming_props: vector::empty(),
        });
    }

    // ----------Admin Functions----------
    public fun deposit(coin: Coin<SUI>, pool: &mut Pool, admin_cap: &AdminCap, world: &mut World, _: &mut TxContext) {
        check_admin(admin_cap, world);

        balance::join(&mut pool.balance, coin::into_balance(coin));
        pool_schema::set_balance(world, balance::value(&pool.balance));
    }

    public fun withdraw(pool: &mut Pool, admin_cap: &AdminCap, world: &mut World, ctx: &mut TxContext): Coin<SUI> {
        check_admin(admin_cap, world);

        let coin_amount = balance::value(&pool.balance);
        let coin = coin::take(&mut pool.balance, coin_amount, ctx);

        pool_schema::set_balance(world, balance::value(&pool.balance));

        coin
    }

    public fun withdraw_to_founder(pool: &mut Pool, admin_cap: &AdminCap, world: &mut World, ctx: &mut TxContext): Coin<SUI>  {
        check_admin(admin_cap, world);

        let founder_balance_amount = pool_schema::get_founder_balance(world);
        let coin = coin::take(&mut pool.balance, founder_balance_amount, ctx);

        pool_schema::set_founder_balance(world, 0);
        pool_schema::set_balance(world, balance::value(&pool.balance));

        coin
    }

    // ----------Public Functions----------
    public fun stake(props: vector<Prop>, staker: address, pool: &mut Pool, world: &mut World) {
        let len = vector::length(&props);
        let i = 0;
        while (i < len) {
            let prop = vector::pop_back(&mut props);
            let prop_address = object::id_address(&prop);
            check_prop_balance(&prop, world);

            let type = p::type(&prop);
            update_pool_prop_count(type, 1, true, world);
            update_staker_prop_count(type, prop_address, 1, true, staker, world);

            update_staker_fees(staker, world);
            update_last_staker_balance_plus(staker, world);

            let prop_index = vector::length(&pool.staking_props);
            pool_map::set(world, prop_address, staker, prop_index);
            vector::push_back(&mut pool.staking_props, prop);

            i = i + 1;
        };
        vector::destroy_empty(props);
    }

    public fun unstake(prop_addresses: vector<address>, pool: &mut Pool, world: &mut World, ctx: &TxContext){
        let staker = tx_context::sender(ctx);
        let props = unstake_friend(prop_addresses, staker, pool, world);
        let len = vector::length(&props);
        let i = 0;
        while (i < len) {
            let prop = vector::pop_back(&mut props);
            transfer::public_transfer(prop, staker);

            i = i + 1;
        };
        vector::destroy_empty(props);
    }

    public fun mint(type: vector<u8>, fee: Coin<SUI>, world: &mut World, ctx: &mut TxContext): (Prop, Coin<SUI>) {
        let amount = coin::value(&fee);
        let mint_prop_fee = pool_schema::get_prop_mint_fee(world);
        assert!(amount >= mint_prop_fee, EInsufficientCoin);

        let mint_fee = coin::split(&mut fee, mint_prop_fee, ctx);
        let prop = p::new(type, mint_fee, world, ctx);

        (prop, fee)
    }

    public fun burn(prop: Prop, pool: &mut Pool, world: &mut World, ctx: &mut TxContext): Coin<SUI> {
        let fee = calculate_prop_burn_fee(&prop, world);
        let prop_coin = p::burn(prop, world, ctx);
        let fee_coin = coin::split(&mut prop_coin, fee, ctx);

        balance::join(&mut pool.balance, coin::into_balance(fee_coin));
        pool_schema::set_balance(world, balance::value(&pool.balance));

        prop_coin
    }

    public fun withdraw_to_staker(pool: &mut Pool, world: &mut World, ctx: &mut TxContext): Coin<SUI> {
        let staker = tx_context::sender(ctx);
        let fees_plus = staker_fees_plus(staker, world);
        let fees = staker_map::get_fees(world, staker);
        let fees_amount = fees + fees_plus;
        
        let coin = coin::take(&mut pool.balance, fees_amount, ctx);

        staker_map::set_fees(world, staker, 0);

        let staker_balance_plus = pool_schema::get_staker_balance_plus(world);
        staker_map::set_last_staker_balance_plus(world, staker, staker_balance_plus);

        let staker_balance = pool_schema::get_staker_balance(world);
        pool_schema::set_staker_balance(world, staker_balance - fees_amount);

        pool_schema::set_balance(world, balance::value(&pool.balance));
        
        coin
    }

    public fun withdraw_to_player(card: &mut Card, pool: &mut Pool, world: &mut World, ctx: &mut TxContext): Coin<SUI> {
        let fees_plus = c::fees_plus(card, world);
        let fees_amount = c::fees(card) + fees_plus;
        let coin = coin::take(&mut pool.balance, fees_amount, ctx);
        let player_balance = pool_schema::get_player_balance(world);

        c::update_fees(fees_amount, false, card);
        pool_schema::set_player_balance(world, player_balance - fees_amount);

        pool_schema::set_balance(world, balance::value(&pool.balance));

        coin
    }

    public fun check_admin(admin_cap: &AdminCap, world: &World) {
        let admin_id = w::get_admin(world);
        assert!(admin_id == object::id(admin_cap), ENotAdmin);
    }

    public fun check_prop_balance(prop: &Prop, world: &World) {
        assert!(p::balance(prop) > p::min_prop_balance(world), EInsufficientPropBalance);
    }

    // ----------Friend Functions----------
    public(friend) fun unstake_friend(prop_addresses: vector<address>, staker: address, pool: &mut Pool, world: &mut World): vector<Prop> {
        let len = vector::length(&prop_addresses);
        let i = 0;
        let props = vector::empty<Prop>();
        while (i < len) {
            let prop_address = vector::pop_back(&mut prop_addresses);

            let (staker_, prop_index) = pool_map::get(world, prop_address);
            assert!(staker == staker_, ENotPropOwner);

            let prop = vector::remove(&mut pool.staking_props, prop_index);
            let type = p::type(&prop);

            update_staker_fees(staker, world);
            update_pool_prop_count(type, 1, false, world);
            update_staker_prop_count(type, prop_address, 1, false, staker, world);
            update_last_staker_balance_plus(staker, world);

            pool_map::remove(world, prop_address);
            vector::push_back(&mut props, prop);

            i = i + 1;
        };

        props
    }

    public fun gaming_props(pool: &Pool): &vector<Prop> {
        &pool.gaming_props
    }

    public(friend) fun gaming_props_mut(pool: &mut Pool): &mut vector<Prop> {
        &mut pool.gaming_props
    }

    public fun staking_props(pool: &Pool): &vector<Prop> {
        &pool.staking_props
    }

    public(friend) fun staking_props_mut(pool: &mut Pool): &mut vector<Prop> {
        &mut pool.staking_props
    }

    public(friend) fun balance(pool: &mut Pool): &mut Balance<SUI> {
        &mut pool.balance
    }

    public(friend) fun pool_fields(pool: &mut Pool): (&mut Balance<SUI>, &mut vector<Prop>, &mut vector<Prop>) {
        (&mut pool.balance, &mut pool.staking_props, &mut pool.gaming_props)
    }

    // ----------Helpers----------
    fun update_pool_prop_count(type: vector<u8>, count: u64, in: bool, world: &mut World) {
        let prop_count = if (in) {
            pool_schema::get_prop_count(world) + count
        } else {
            pool_schema::get_prop_count(world) - count
        };
        pool_schema::set_prop_count(world, prop_count);

        if (type == SCISSORS) {
            let scissors_count = if (in) {
                pool_schema::get_scissors_count(world) + count
            } else {
                pool_schema::get_scissors_count(world) - count
            };
            pool_schema::set_scissors_count(world, scissors_count);
        };

        if (type == ROCK ) {
            let rock_count = if (in) {
                pool_schema::get_rock_count(world) + count
            } else {
                pool_schema::get_rock_count(world) - count
            };
            pool_schema::set_rock_count(world, rock_count);
        };

        if (type == PAPER) {
            let paper_count = if (in) {
                pool_schema::get_paper_count(world) + count
            } else {
                pool_schema::get_paper_count(world) - count
            };
            pool_schema::set_paper_count(world, paper_count);
        };
    }

    fun calculate_prop_burn_fee(prop: &Prop, world: &mut World): u64 {
        let prop_balance = p::balance(prop);
        let prop_burn_fee = (pool_schema::get_prop_burn_fee(world) as u64); // 1%
        let fee_amount = prop_balance * prop_burn_fee / 10_000;
        let to_player_fee = (pool_schema::get_to_player_fee(world) as u64); // 50%
        let player_fee = fee_amount * to_player_fee / 10_000;

        let player_balance = pool_schema::get_player_balance(world) + player_fee;
        pool_schema::set_player_balance(world, player_balance);
        let player_balance_plus = pool_schema::get_player_balance_plus(world) + player_fee;
        pool_schema::set_player_balance_plus(world, player_balance_plus);

        let founder_balance = pool_schema::get_founder_balance(world) + fee_amount - player_fee;
        pool_schema::set_founder_balance(world, founder_balance);

        fee_amount
    }

    fun staker_fees_plus(staker: address, world: &World): u64 {
        // pool balance plus
        let staker_balance_plus = pool_schema::get_staker_balance_plus(world);
        let prop_count = pool_schema::get_prop_count(world);

        // last staker balance plus
        let last_staker_balance_plus = staker_map::get_last_staker_balance_plus(world, staker);
        let size = staker_map::get_size(world, staker);

        let fees_plus = (staker_balance_plus - last_staker_balance_plus) * size / prop_count;
        fees_plus
    }

    fun update_staker_prop_count(type: vector<u8>, prop_address: address, count: u64, in: bool, staker: address, world: &mut World) {
        if (!staker_map::contains(world, staker)) {
            staker_map::set(world,
                staker,
                0,
                0,
                0,
                vector::empty(),
                vector::empty(),
            );
        };

        let prop_count = if (in) {
            staker_map::get_size(world, staker) + count
        } else {
            staker_map::get_size(world, staker) - count
        };
        staker_map::set_size(world, staker, prop_count);

        let prop_types = staker_map::get_prop_types(world, staker);
        let prop_ids = staker_map::get_prop_ids(world, staker);

        if (in) {
            vector::push_back(&mut prop_types, type);
            staker_map::set_prop_types(world, staker, prop_types);

            vector::push_back(&mut prop_ids, prop_address);
            staker_map::set_prop_ids(world, staker, prop_ids);
        } else {
            let (in, prop_index) = vector::index_of(&prop_ids, &prop_address);

            if (in) {
                vector::remove(&mut prop_types, prop_index);
                vector::remove(&mut prop_ids, prop_index);

                staker_map::set_prop_types(world, staker, prop_types);
                staker_map::set_prop_ids(world, staker, prop_ids);
            };
        };
    }

    fun update_staker_fees(staker: address, world: &mut World) {
        let fees_plus = staker_fees_plus(staker, world);
        let fees = staker_map::get_fees(world, staker);
        staker_map::set_fees(world, staker, fees + fees_plus);
    }

    fun update_last_staker_balance_plus(staker: address, world: &mut World) {
        let staker_balance_plus = pool_schema::get_staker_balance_plus(world);
        staker_map::set_last_staker_balance_plus(world, staker, staker_balance_plus);
    }

    // ----------Tests----------
    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(POOL_SYSTEM {}, ctx);
    }
}
