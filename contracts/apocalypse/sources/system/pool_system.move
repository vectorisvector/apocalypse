module apocalypse::pool_system {
    use std::vector::{Self};
    use std::string::{String, utf8};

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::package::{Self};
    use sui::transfer::{Self};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};

    use apocalypse::world::{World};
    use apocalypse::box_map_schema::{Self as box_map};
    use apocalypse::prop_map_schema::{Self as prop_map};

    // ----------Errors----------
    const EInvalidType: u64 = 0;
    const EInvalidAmount: u64 = 1;
    const ENotBoxCap: u64 = 2;
    const ENotProp: u64 = 3;

    // ----------Consts----------
    const SCISSORS: vector<u8> = b"scissors";
    const ROCK: vector<u8> = b"rock";
    const PAPER: vector<u8> = b"paper";

    // ----------Structs----------
    struct PoolCap has key {
        id: UID,
    }

    struct POOL_SYSTEM has drop {}

    struct Prop has key, store {
        id: UID,
        type: String,
        balance: Balance<SUI>,
    }

    struct Box has key, store {
        id: UID,
        fees: Balance<SUI>,
        index: u64,
        size: u64,
        activated: bool,
    }

    struct Pool has key {
        id: UID,
        balance: Balance<SUI>,
        mint_prop_fee: u64,
        game_fee: u16,
        deadline_fee: u16,
        prop_withdraw_fee: u16,
        box_burn_fee: u16,
        stake_fee: u16,
        props: vector<Prop>,
        boxes: vector<Box>,
    }

    // ----------Pool Init----------
    fun init(otw: POOL_SYSTEM, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);

        let pool_cap = PoolCap {
            id: object::new(ctx)
        };
        transfer::transfer(pool_cap, tx_context::sender(ctx));
        
        let pool = Pool {
            id: object::new(ctx),
            balance: balance::zero(),
            mint_prop_fee: 2_000_000_000,
            game_fee: 500,
            deadline_fee: 8_000,
            prop_withdraw_fee: 100,
            box_burn_fee: 100,
            stake_fee: 5_000,
            props: vector::empty(),
            boxes: vector::empty(),
        };
        transfer::share_object(pool);
    }

    // ----------Pool Functions----------
    /// Withdraws the pool balance to the caller.
    public fun withdraw(pool: &mut Pool, _: &PoolCap, ctx: &mut TxContext): Coin<SUI> {
        let total_balance = balance(pool);
        let coin = coin::take(&mut pool.balance, total_balance, ctx);
        coin
    }

    /// Updates the mint_prop_fee of the pool.
    public fun update_mint_prop_fee(pool: &mut Pool, fee: u64, _: &PoolCap, _: &mut TxContext) {
        pool.mint_prop_fee = fee;
    }

    /// Updates the game_fee of the pool.
    public fun update_game_fee(pool: &mut Pool, fee: u16, _: &PoolCap, _: &mut TxContext) {
        pool.game_fee = fee;
    }

    /// Updates the deadline_fee of the pool.
    public fun update_deadline_fee(pool: &mut Pool, fee: u16, _: &PoolCap, _: &mut TxContext) {
        pool.deadline_fee = fee;
    }

    /// Updates the prop_withdraw_fee of the pool.
    public fun update_prop_withdraw_fee(pool: &mut Pool, fee: u16, _: &PoolCap, _: &mut TxContext) {
        pool.prop_withdraw_fee = fee;
    }

    /// Updates the box_burn_fee of the pool.
    public fun update_box_burn_fee(pool: &mut Pool, fee: u16, _: &PoolCap, _: &mut TxContext) {
        pool.box_burn_fee = fee;
    }

    /// Updates the stake_fee of the pool.
    public fun update_stake_fee(pool: &mut Pool, fee: u16, _: &PoolCap, _: &mut TxContext) {
        pool.stake_fee = fee;
    }

    // ----------Prop Functions----------
    /// Creates a new prop and transfers it to the player
    public fun create_prop(type: vector<u8>, coin: Coin<SUI>, pool: &Pool, ctx: &mut TxContext): Prop {
        assert!(type == SCISSORS || type == ROCK || type == PAPER, EInvalidType);

        let stake_amount = coin::value(&coin);
        assert!(stake_amount == mint_prop_fee(pool), EInvalidAmount);

        Prop {
            id: object::new(ctx),
            type: utf8(type),
            balance: coin::into_balance(coin)
        }
    }

    /// Burns a prop and transfers the balance to the player
    public fun burn_prop(prop: Prop, pool: &mut Pool, ctx: &mut TxContext): Coin<SUI> {
        let Prop { id, balance: prop_banlance, type: _ } = prop;
        object::delete(id);

        let total_amount = balance::value(&prop_banlance);
        let fee_amount = total_amount * (prop_withdraw_fee(pool) as u64) / 10_000;
        let fee = balance::split(&mut prop_banlance, fee_amount);

        balance::join(&mut pool.balance, fee);

        let coin = coin::from_balance(prop_banlance, ctx);
        coin
    }

    // /// Stakes props to the pool
    public fun stake_props(input_props: vector<Prop>, pool: &mut Pool, world: &mut World, ctx: &mut TxContext) {
        let box = Box {
            id: object::new(ctx),
            fees: balance::zero(),
            index: vector::length(boxes(pool)),
            size: vector::length(&input_props),
            activated: false,
        };
        let box_address = object::id_address(&box);

        {
            let player = tx_context::sender(ctx);
            let box_vec = if (box_map::contains(world, player)) {
                boxes_from_player(player, world)
            } else {
                vector::empty()
            };
            vector::push_back(&mut box_vec, box_address);
            box_map::set(world, player, box_vec);
        };

        {
            let prop_vec = if (prop_map::contains(world, box_address)) {
                props_from_box(box_address, world)
            } else {
                vector::empty()
            };
            let i = 0;
            let len = vector::length(&input_props);
            while (i < len) {
                vector::push_back(&mut prop_vec, object::id_address(vector::borrow(&input_props, i)));
                i = i + 1;
            };
            prop_map::set(world, box_address, prop_vec);
        };

        vector::append(&mut pool.props, input_props);
        vector::push_back(boxes_mut(pool), box);
    }

    // /// Add props to a box
    public fun add_props_to_box(input_props: vector<Prop>, box: &Box, pool: &mut Pool, world: &mut World, ctx: &TxContext) {
        let player = tx_context::sender(ctx);
        check_box(player, box, world);

        let len = vector::length(&input_props);
        {
            let box_address = object::id_address(box);
            let prop_vec = props_from_box(box_address, world);
            let i = 0;
            while (i < len) {
                let prop = vector::borrow(&input_props, i);
                let prop_address = object::id_address(prop);
                vector::push_back(&mut prop_vec, prop_address);
                i = i + 1;
            };
            prop_map::set(world, box_address, prop_vec);
        };

        {
            let box = box_mut(box, pool);
            box.size = box.size + len;
            box.activated = false;
        };

        vector::append(&mut pool.props, input_props);
    }

    /// Claim props from a box
    public fun claim_props_from_box(input_props: &vector<Prop>, box: &Box, pool: &mut Pool, world: &mut World, ctx: &TxContext): vector<Prop> {
        let player = tx_context::sender(ctx);
        check_box(player, box, world);

        let len = vector::length(input_props);
        let props = vector::empty<Prop>();

        {
            let box_address = object::id_address(box);
            let i = 0;
            while (i < len) {
                let prop = vector::borrow(input_props, i);

                {
                    let prop_address = object::id_address(prop);
                    let prop_vec = props_from_box(box_address, world);
                    let (in_box, prop_i) = vector::index_of(&prop_vec, &prop_address);
                    assert!(in_box, ENotProp);

                    vector::remove(&mut prop_vec, prop_i);
                    prop_map::set(world, box_address, prop_vec);
                };

                {
                    let (_, prop_i) = prop_mut(prop, pool);

                    let prop = vector::remove(props_mut(pool), prop_i);
                    vector::push_back(&mut props, prop);
                };

                i = i + 1;
            };
        };

        {
            let box = box_mut(box, pool);
            box.size = box.size - len;
            box.activated = false;
        };

        props
    }

    /// Burns a box and transfers the fees to the sender
    public fun unstake_box(input_props: &vector<Prop>, box: &Box, pool: &mut Pool, world: &mut World, ctx: &mut TxContext): (Coin<SUI>, vector<Prop>) {
        let props = claim_props_from_box(input_props, box, pool, world, ctx);

        let box_i = box_index(box);
        let box = vector::remove(boxes_mut(pool), box_i);

        let Box { id, fees, index: _, size: _, activated: _ } = box;
        object::delete(id);

        let total_amount = balance::value(&fees);
        let fee_amount = total_amount * (box_burn_fee(pool) as u64) / 10_000;
        let fee = balance::split(&mut fees, fee_amount);

        balance::join(&mut pool.balance, fee);

        let coin = coin::from_balance(fees, ctx);
        (coin, props)
    }

    // ----------Pool Accessors----------
    /// Returns the balance of the pool.
    public fun balance(pool: &Pool): u64 {
        balance::value(&pool.balance)
    }

    /// Returns the mint_prop_fee of the pool.
    public fun mint_prop_fee(pool: &Pool): u64 {
        pool.mint_prop_fee
    }

    /// Returns the game_fee of the pool.
    public fun game_fee(pool: &Pool): u16 {
        pool.game_fee
    }

    /// Returns the deadline_fee of the pool.
    public fun deadline_fee(pool: &Pool): u16 {
        pool.deadline_fee
    }

    /// Returns the prop_withdraw_fee of the pool.
    public fun prop_withdraw_fee(pool: &Pool): u16 {
        pool.prop_withdraw_fee
    }

    /// Returns the box_burn_fee of the pool.
    public fun box_burn_fee(pool: &Pool): u16 {
        pool.box_burn_fee
    }

    /// Returns the stake_fee of the pool.
    public fun stake_fee(pool: &Pool): u16 {
        pool.stake_fee
    }

    public fun props(pool: &Pool): &vector<Prop> {
        &pool.props
    }

    // ----------Pool Helpers----------
    public fun check_box(player: address, box: &Box, world: &World){
        let box_vec = boxes_from_player(player, world);
        let box_address = object::id_address(box);
        let in_box_vec = vector::contains(&box_vec, &box_address);
        assert!(in_box_vec, ENotBoxCap);
    }

    // ----------Prop Accessors----------
    public fun prop_type(prop: &Prop): &String {
        &prop.type
    }

    public fun props_from_box(box: address, world: &World): vector<address> {
        prop_map::get(world, box)
    }

    public fun props_mut(pool: &mut Pool): &mut vector<Prop> {
        &mut pool.props
    }

    public fun prop_mut(prop: &Prop, pool: &mut Pool): (&mut Prop, u64) {
        let (in_props, index) = vector::index_of(props(pool), prop);
        assert!(in_props, ENotProp);

        (vector::borrow_mut(props_mut(pool), index), index)
    }

    // ----------Box Accessors----------
    public fun boxes_from_player(player: address, world: &World): vector<address> {
        box_map::get(world, player)
    }

    public fun boxes(pool: &Pool): &vector<Box> {
        &pool.boxes
    }

    public fun boxes_mut(pool: &mut Pool): &mut vector<Box> {
        &mut pool.boxes
    }

    public fun box_mut(box: &Box, pool: &mut Pool): &mut Box {
        let index = box_index(box);
        vector::borrow_mut(boxes_mut(pool), index)
    }

    public fun box_fees(box: &Box): u64 {
        balance::value(&box.fees)
    }

    public fun box_index(box: &Box): u64 {
        box.index
    }

    public fun box_size(box: &Box): u64 {
        box.size
    }

    public fun box_activated(box: &Box): bool {
        box.activated
    }

    // ----------Pool Tests----------
    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(POOL_SYSTEM {}, ctx);
    }
}