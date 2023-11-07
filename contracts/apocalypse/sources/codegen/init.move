module apocalypse::init {
    use std::ascii::string;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use apocalypse::world;
	use apocalypse::box_map_schema;
	use apocalypse::prop_map_schema;

    fun init(ctx: &mut TxContext) {
        let (_obelisk_world, admin_cap) = world::create(string(b"Apocalypse"), string(b"Apocalypse game"),ctx);

        // Add Schema
		box_map_schema::register(&mut _obelisk_world, &admin_cap, ctx);
		prop_map_schema::register(&mut _obelisk_world, &admin_cap, ctx);

        transfer::public_share_object(_obelisk_world);
        transfer::public_transfer(admin_cap, tx_context::sender(ctx));
    }

    #[test_only]
    public fun init_world_for_testing(ctx: &mut TxContext){
        init(ctx)
    }
}
