module apocalypse::init {
    use std::ascii::string;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use apocalypse::world;
	use apocalypse::staker_map_schema;
	use apocalypse::game_map_schema;
	use apocalypse::pool_map_schema;
	use apocalypse::card_map_schema;
	use apocalypse::pool_schema;
	use apocalypse::global_schema;
	use apocalypse::randomness_schema;

    fun init(ctx: &mut TxContext) {
        let (_obelisk_world, admin_cap) = world::create(string(b"Apocalypse"), string(b"Apocalypse game on the chain"),ctx);

        // Add Schema
		staker_map_schema::register(&mut _obelisk_world, &admin_cap, ctx);
		game_map_schema::register(&mut _obelisk_world, &admin_cap, ctx);
		pool_map_schema::register(&mut _obelisk_world, &admin_cap, ctx);
		card_map_schema::register(&mut _obelisk_world, &admin_cap, ctx);
		pool_schema::register(&mut _obelisk_world, &admin_cap, ctx);
		global_schema::register(&mut _obelisk_world, &admin_cap, ctx);
		randomness_schema::register(&mut _obelisk_world, &admin_cap, ctx);

        transfer::public_share_object(_obelisk_world);
        transfer::public_transfer(admin_cap, tx_context::sender(ctx));
    }

    #[test_only]
    public fun init_world_for_testing(ctx: &mut TxContext){
        init(ctx)
    }
}
