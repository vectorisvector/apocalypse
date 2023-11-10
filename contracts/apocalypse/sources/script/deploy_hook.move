module apocalypse::deploy_hook {
    use sui::object::{Self};

    use apocalypse::world::{World, AdminCap, get_admin};
    use apocalypse::randomness_schema::{Self};

    /// Not the right admin for this world
    const ENotAdmin: u64 = 0;

    public entry fun run(world: &mut World, admin_cap: &AdminCap) {
        assert!(get_admin(world) == object::id(admin_cap), ENotAdmin);

        // Logic that needs to be automated once the contract is deployed

        // Set the initial randomness
        randomness_schema::set_sig(world, x"93f95e710aa460cdb05ea166be436ee464f9f7da3ef1d96304d330516252fa0032910fa6976845939a26198bcd9a6d47048b7c8fb5d54d329dcd63f4d5f1409f0239dfc84002becfb7ca23285f63c336cccd736b02a1bcfd7da1ceeb4cf5baf1");
        randomness_schema::set_prev_sig(world, x"b6b0d2597aba34ca04e80723f07aef26baeebfb7759d6ab949d65a8b5661e344ec4bd0da40ad764f620f957d1c76de230d47fdfdc69cbac6081745d42a816040a730bc058ca1f83a4fa532bb22206f4ac2806cac5cd4420d4d20aa173ec9ea56");
        randomness_schema::set_round(world, 2948226);
        randomness_schema::set_seed(world, x"de2cc309d7eaa08b4dbc8e1f94dfa9fabba4938d45e0b5105fd219d1cd8e21463a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532");
        randomness_schema::set_value(world, x"de2cc309d7eaa08b4dbc8e1f94dfa9fabba4938d45e0b5105fd219d1cd8e21463a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532");
    }

    #[test_only]
    public fun deploy_hook_for_testing(world: &mut World, admin_cap: &AdminCap){
        run(world, admin_cap)
    }
}
