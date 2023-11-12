#[test_only]
module apocalypse::test {
    use std::debug;
    use std::vector;

    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::test_scenario;
    use sui::object;

    use apocalypse::pool_system;
    use apocalypse::world::{World, AdminCap};
    use apocalypse::init;
    use apocalypse::deploy_hook;
    use apocalypse::pool_schema;
    use apocalypse::staker_map_schema::{Self as staker_map};

    #[test]
    fun test() {
        let admin = @0xA;

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
            let coin = coin::mint_for_testing<SUI>(2_000_000_000, ctx);
            let (prop, coin_) = pool_system::mint(b"scissors", coin, &mut world, ctx);
            transfer::public_transfer(coin_, admin);
            // transfer::public_transfer(prop, admin);

            let prpp_address = object::id_address(&prop);

            pool_system::stake(vector[prop], admin, &mut pool, &mut world);
            pool_system::unstake(vector[prpp_address], &mut pool, &mut world, ctx);
        };

        test_scenario::return_to_sender(scenario, admin_cap);
        test_scenario::return_shared(world);
        test_scenario::return_shared(pool);
        test_scenario::end(scenario_val);
    }
}