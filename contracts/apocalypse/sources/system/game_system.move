module apocalypse::game_system {
    use std::vector::{Self};

    use sui::object::{Self};
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::transfer::{Self};
    use sui::clock::{Clock};

    use apocalypse::world::{World};
    use apocalypse::randomness_schema::{Self};
    use apocalypse::randomness_system::{Self as randomness};
    use apocalypse::prop_system::{Self as p, Prop};
    use apocalypse::pool_system::{Self, Pool};
    use apocalypse::game_map_schema::{Self as game_map};
    use apocalypse::global_schema::{Self as global};
    use apocalypse::pool_schema::{Self};
    use apocalypse::pool_map_schema::{Self as pool_map};
    use apocalypse::card_system::{Self as c, Card};

    // ----------Errors----------
    const EGameNotEnd: u64 = 0;
    const EGameNotExpired: u64 = 1;

    // ----------Consts----------
    const SCISSORS: vector<u8> = b"scissors";
    const ROCK: vector<u8> = b"rock";
    const PAPER: vector<u8> = b"paper";
    const CARD_SUPPLY: u64 = 100_000_000; // 100 million

    // ----------Public Functions----------
    public fun start_game(props: vector<Prop>, card: &mut Card, clock: &Clock, pool: &mut Pool, world: &mut World, ctx: &TxContext) {
        let old_round = randomness_schema::get_round(world);
        assert!(!randomness::check_round_expired(old_round, clock), EGameNotEnd);

        let player = tx_context::sender(ctx);
        let len = vector::length(&props);
        let i = 0;
        while (i < len) {
            let prop = vector::pop_back(&mut props);
            pool_system::check_prop_balance(&prop, world);

            handle_game_fee(p::balance_mut(&mut prop), pool_system::balance(pool), world);

            let prop_address = object::id_address(&prop);
            let gaming_props = pool_system::gaming_props_mut(pool);

            game_map::set(world, prop_address, player, vector::length(gaming_props));
            vector::push_back(gaming_props, prop);

            let game_count = global::get_game_count(world);
            if (game_count < CARD_SUPPLY) {
                c::update_size(len, true, card, world);
            };
            global::set_game_count(world, game_count + 1);

            i = i + 1;
        };
        vector::destroy_empty(props);
    }

    public fun start_game_new_card(props: vector<Prop>, clock: &Clock, pool: &mut Pool, world: &mut World, ctx: &mut TxContext) {
        let card = c::new(world, ctx);
        start_game(props, &mut card, clock, pool, world, ctx);
        let player = tx_context::sender(ctx);
        c::transfer(card, player, world, ctx);
    }

    public fun end_game(sig: vector<u8>, prev_sig: vector<u8>, round: u64, clock: &Clock, pool: &mut Pool, world: &mut World, ctx: &TxContext) {
        let old_round = randomness_schema::get_round(world);
        assert!(randomness::check_round_expired(old_round, clock) && !randomness::check_round_expired(round, clock) && round > old_round, EGameNotExpired);

        randomness::update_randomness(sig, prev_sig, round, world, ctx);

        loop {
            let len = {
                let gaming_props = pool_system::gaming_props(pool);
                vector::length(gaming_props)
            };
            if (len == 0) break;

            let index = {
                let staking_props = pool_system::staking_props_mut(pool);
                let upper_bound = vector::length(staking_props);
                random(upper_bound, world)
            };

            {
                let (balance, _, staking_props) = pool_system::pool_fields(pool);
                let staking_prop = vector::borrow_mut(staking_props, index);
                handle_game_fee(p::balance_mut(staking_prop), balance, world);
            };

            let res = {
                let gaming_props = pool_system::gaming_props(pool);
                let staking_props = pool_system::staking_props(pool);
                let gaming_prop = vector::borrow(gaming_props, 0);
                let staking_prop = vector::borrow(staking_props, index);
                calculate_winer(gaming_prop, staking_prop)
            };

            let gaming_prop_onwer = {
                let gaming_props = pool_system::gaming_props(pool);
                let gaming_prop = vector::borrow(gaming_props, 0);
                let gaming_prop_address = object::id_address(gaming_prop);
                game_map::get_player(world, gaming_prop_address)
            };

            let staking_prop_onwer = {
                let staking_props = pool_system::staking_props(pool);
                let staking_prop = vector::borrow(staking_props, index);
                let staking_prop_address = object::id_address(staking_prop);
                pool_map::get_staker(world, staking_prop_address)
            };

            // player lose
            if (res == 0) {
                let gaming_props = pool_system::gaming_props_mut(pool);
                let gaming_prop = vector::remove(gaming_props, 0);
                pool_system::stake(vector[gaming_prop], staking_prop_onwer, pool, world);
            };

            // player win
            if (res == 1) {
                let gaming_props = pool_system::gaming_props_mut(pool);
                let gaming_prop = vector::remove(gaming_props, 0);

                let staking_props = pool_system::staking_props(pool);
                let staking_prop = vector::borrow(staking_props, index);
                let staking_prop_address = object::id_address(staking_prop);

                let unstake_props = pool_system::unstake_friend(vector[staking_prop_address], staking_prop_onwer, pool, world);
                let staking_prop = vector::pop_back(&mut unstake_props);
                vector::destroy_empty(unstake_props);

                transfer::public_transfer(staking_prop, gaming_prop_onwer);
                transfer::public_transfer(gaming_prop, gaming_prop_onwer);
            };

            // draw game
            if (res == 2) {
                let gaming_props = pool_system::gaming_props_mut(pool);
                let gaming_prop = vector::remove(gaming_props, 0);
                pool_system::stake(vector[gaming_prop], gaming_prop_onwer, pool, world);
            };
        };
    }

    // ----------Helpers----------
    fun handle_game_fee(prop_balance: &mut Balance<SUI>, pool_balance: &mut Balance<SUI>, world: &mut World) {
        let game_fee_amount = p::game_fee_amount(world); // 0.1 sui

        let to_staker_fee = (pool_schema::get_to_staker_fee(world) as u64); // 50%
        let staker_fee = game_fee_amount * to_staker_fee / 10_000;
        let staker_balance = pool_schema::get_staker_balance(world);
        pool_schema::set_staker_balance(world, staker_balance + staker_fee);
        let staker_balance_plus = pool_schema::get_staker_balance_plus(world);
        pool_schema::set_staker_balance_plus(world, staker_balance_plus + staker_fee);

        let to_player_fee = (pool_schema::get_to_player_fee(world) as u64); // 50%
        let player_fee = game_fee_amount * to_player_fee / 10_000;
        let player_balance = pool_schema::get_player_balance(world);
        pool_schema::set_player_balance(world, player_balance + player_fee);
        let player_balance_plus = pool_schema::get_player_balance_plus(world);
        pool_schema::set_player_balance_plus(world, player_balance_plus + player_fee);

        let founder_balance = pool_schema::get_founder_balance(world);
        pool_schema::set_founder_balance(world, founder_balance + game_fee_amount - staker_fee - player_fee);

        balance::join(pool_balance, balance::split(prop_balance, game_fee_amount));

        pool_schema::set_balance(world, balance::value(pool_balance));
    }

    fun random(upper_bound: u64, world: &mut World): u64 {
        randomness::next_u64_in_range(world, upper_bound)
    }

    fun calculate_winer(gaming_prop: &Prop, staking_prop: &Prop): u8 {
        let gaming_prop_type = p::type(gaming_prop);
        let staking_prop_type = p::type(staking_prop);

        if (gaming_prop_type == SCISSORS) {
            if (staking_prop_type == ROCK) {
                0
            } else if (staking_prop_type == PAPER) {
                1
            } else {
                2
            }
        } else if (gaming_prop_type == ROCK) {
            if (staking_prop_type == PAPER) {
                0
            } else if (staking_prop_type == SCISSORS) {
                1
            } else {
                2
            }
        } else {
            if (staking_prop_type == SCISSORS) {
                0
            } else if (staking_prop_type == ROCK) {
                1
            } else {
                2
            }
        }
    }
}