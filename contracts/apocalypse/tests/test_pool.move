#[test_only]
module apocalypse::test_pool {
    use std::debug::{print};
    use std::vector::{Self};

    use sui::test_scenario;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::transfer::{Self};

    use apocalypse::world::{World};
    use apocalypse::pool_system::{Self as pool, Pool, Prop, Box};
    use apocalypse::init;

    #[test]
    fun test_init() {
        let admin = @0xA;
        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        {
            let ctx = test_scenario::ctx(scenario);
            init::init_world_for_testing(ctx);
            pool::init_for_testing(ctx);

            let coin = coin::mint_for_testing<SUI>(200_000_000_000, ctx);
            transfer::public_transfer(coin, admin);
        };

        test_scenario::next_tx(scenario, admin);
        let pool = test_scenario::take_shared<Pool>(scenario);

        test_scenario::next_tx(scenario, admin);
        let world = test_scenario::take_shared<World>(scenario);

        test_scenario::next_tx(scenario, admin);
        {
            let admin_coin = test_scenario::take_from_sender<Coin<SUI>>(scenario);
            let ctx = test_scenario::ctx(scenario);

            let coin = coin::split(&mut admin_coin, pool::mint_prop_fee(&pool), ctx);
            transfer::public_transfer(admin_coin, admin);
            print(&coin::value(&coin));

            pool::create_prop(b"rock", coin, &pool, ctx);
        };

        test_scenario::next_tx(scenario, admin);
        let prop = test_scenario::take_from_sender<Prop>(scenario);
        print(pool::prop_type(&prop));

        test_scenario::next_tx(scenario, admin);
        {
            let ctx = test_scenario::ctx(scenario);
            let input_props = vector::singleton(prop);
            pool::stake_props(input_props, &mut pool, &mut world, ctx);
        };

        // test_scenario::next_tx(scenario, admin);
        // let box = test_scenario::take_from_sender<Box>(scenario);
        // print(&pool::box_fees(&box));
        // print(&pool::box_index(&box));
        // print(&pool::box_size(&box));
        // print(&pool::box_activated(&box));

        test_scenario::next_tx(scenario, admin);
        {
            let box_vec = pool::boxes_from_player(admin, &world);
            print(&box_vec);
            // test_scenario::return_to_sender(scenario, box);
        };


        test_scenario::return_shared(pool);
        test_scenario::return_shared(world);
        test_scenario::end(scenario_val);
    }
}