#[test_only]
module apocalypse::test {
    use std::debug;
    use std::vector;

    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::test_scenario;
    use sui::object;
    use sui::clock::{Self, Clock};
    use sui::tx_context::TxContext;

    use apocalypse::pool_system::{Self, Pool};
    use apocalypse::world::{World, AdminCap};
    use apocalypse::init;
    use apocalypse::deploy_hook;
    use apocalypse::pool_schema;
    use apocalypse::staker_map_schema::{Self as staker_map};
    use apocalypse::randomness_system::{Self as randomness};
    use apocalypse::randomness_schema::{Self};
    use apocalypse::game_system::{Self as game};
    use apocalypse::game_map_schema::{Self as game_map};

    #[test]
    fun test() {
        let admin = @0xAA;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, admin);
        {
            let ctx = test_scenario::ctx(scenario);
            pool_system::init_for_testing(ctx);
            init::init_world_for_testing(ctx);
        };

        test_scenario::next_tx(scenario, admin);
        let world = test_scenario::take_shared<World>(scenario);
        let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);
        let pool = test_scenario::take_shared<pool_system::Pool>(scenario);

        test_scenario::next_tx(scenario, admin);
        {
            deploy_hook::deploy_hook_for_testing(&mut world, &admin_cap);
        };

        test_scenario::next_tx(scenario, admin);
        {
            let ctx = test_scenario::ctx(scenario);
            let coin1 = coin::mint_for_testing<SUI>(2_000_000_000, ctx);
            let (prop1, coin_1) = pool_system::mint(b"rock", coin1, &mut world, ctx);
            transfer::public_transfer(coin_1, admin);
            let coin2 = coin::mint_for_testing<SUI>(2_000_000_000, ctx);
            let (prop2, coin_2) = pool_system::mint(b"scissors", coin2, &mut world, ctx);
            transfer::public_transfer(coin_2, admin);
            let coin3 = coin::mint_for_testing<SUI>(2_000_000_000, ctx);
            let (prop3, coin_3) = pool_system::mint(b"paper", coin3, &mut world, ctx);
            transfer::public_transfer(coin_3, admin);

            pool_system::stake(vector[prop1, prop2, prop3], admin, &mut pool, &mut world);

            let clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, (randomness::round_time(randomness_schema::get_round(&world)) + 100) * 1000);

            let sig = x"b38ad89f582ec495099a76e60bf424ebfbc825a7f09cc14cbd6e5a6ee2e6f0c062587ddcb18b3fd509f0f0f6b92a77c30f4b20d83f356f909e41cab619550e7b6ac218c3bf75f72505762b16386145dd13e68753142eb2cafa7e0cbbcbdc3d70";
            let prev_sig = x"95534a881d61f4151270f24ce8ff00dc9a46082d411629056e76cfd732b853a6d5e953f1f0bef6661c2e969e5a0602dd1772ab10b9d9b82b6ff88d8100b008e6661f444bdd550ce77f7935f0f320a897047ada39f0eb3b7a944ed38f30493ed6";
            let round = 3490107;
            game::end_game(sig, prev_sig, round, &clock, &mut pool, &mut world, ctx);

            // pool_system::unstake(vector[prop_address], &mut pool, &mut world, ctx);
            clock::destroy_for_testing(clock);
        };

        test_scenario::next_tx(scenario, admin);
        let prop_address = {
            let ctx = test_scenario::ctx(scenario);
            let coin = coin::mint_for_testing<SUI>(2_000_000_000, ctx);
            let (prop, coin_) = pool_system::mint(b"rock", coin, &mut world, ctx);
            transfer::public_transfer(coin_, admin);
            let prop_address = object::id_address(&prop);

            let clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, (randomness::round_time(3490107) + 10) * 1000);

            game::start_game_new_card(vector[prop], &clock, &mut pool, &mut world, ctx);

            let gaming_prop_onwer = game_map::get(&world, prop_address);
            debug::print(&gaming_prop_onwer);

            // game::end_game(sig, prev_sig, round, &clock, &mut pool, &mut world, ctx);

            clock::destroy_for_testing(clock);
            prop_address
        };

        test_scenario::next_tx(scenario, admin);
        {
            let ctx = test_scenario::ctx(scenario);

            let clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, (randomness::round_time(3490107) + 31) * 1000);

            let sig = x"92073ebb0aa478a651b566ac2dd00ee4f50f6faa5bad5118b48e9d05dc75b9b49870300db74bfb6f17a8410fb306998919aeae891cdb65491700e2125aa716950e225393991ac997fc7c067027c2dcf3d82603f55712dcc9c91d160d2b5bc2af";
            let prev_sig = x"83c2952f4496eaf39844bc5caeccbb4e1ca8ce424a02be9affeb78e4c3b10ce34d714805db6a11b320500bba4c140d3d0a36f37f1da68d0b05e2f094076b0024e324d262a0a20a52248ae575f82a3972127953dda44854a1f875cd9f5e37d82c";
            let round = 3490437;

            let gaming_prop_onwer = game_map::get(&world, prop_address);
            debug::print(&gaming_prop_onwer);

            let gaming_props = pool_system::gaming_props(&pool);
            debug::print(&prop_address);

            game::end_game(sig, prev_sig, round, &clock, &mut pool, &mut world, ctx);

            clock::destroy_for_testing(clock);
        };

        test_scenario::return_to_sender(scenario, admin_cap);
        test_scenario::return_shared(world);
        test_scenario::return_shared(pool);
        test_scenario::end(scenario_val);
    }

    // #[test]
    // fun test_verify_drand_signature() {
    //     let sig = x"b38ad89f582ec495099a76e60bf424ebfbc825a7f09cc14cbd6e5a6ee2e6f0c062587ddcb18b3fd509f0f0f6b92a77c30f4b20d83f356f909e41cab619550e7b6ac218c3bf75f72505762b16386145dd13e68753142eb2cafa7e0cbbcbdc3d70";
    //     let prev_sig = x"95534a881d61f4151270f24ce8ff00dc9a46082d411629056e76cfd732b853a6d5e953f1f0bef6661c2e969e5a0602dd1772ab10b9d9b82b6ff88d8100b008e6661f444bdd550ce77f7935f0f320a897047ada39f0eb3b7a944ed38f30493ed6";
    //     let round = 3490107;
    //     randomness::verify_drand_signature(
    //         sig,
    //         prev_sig,
    //         round,
    //     );
    // }
}