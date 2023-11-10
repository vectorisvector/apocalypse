module apocalypse::global_schema {
	use std::option::none;
    use sui::tx_context::TxContext;
    use apocalypse::events;
    use apocalypse::world::{Self, World, AdminCap};
    // Systems
	friend apocalypse::prop_system;
	friend apocalypse::pool_system;
	friend apocalypse::game_system;
	friend apocalypse::card_system;
	friend apocalypse::randomness_system;
	friend apocalypse::deploy_hook;

	const SCHEMA_ID: vector<u8> = b"global";
	const SCHEMA_TYPE: u8 = 1;

	// scissors_count
	// rock_count
	// paper_count
	// prop_count
	// game_count
	// card_count
	struct GlobalData has copy, drop , store {
		scissors_count: u64,
		rock_count: u64,
		paper_count: u64,
		prop_count: u64,
		game_count: u64,
		card_count: u64
	}

	public fun new(scissors_count: u64, rock_count: u64, paper_count: u64, prop_count: u64, game_count: u64, card_count: u64): GlobalData {
		GlobalData {
			scissors_count, 
			rock_count, 
			paper_count, 
			prop_count, 
			game_count, 
			card_count
		}
	}

	public fun register(_obelisk_world: &mut World, admin_cap: &AdminCap, _ctx: &mut TxContext) {
		let _obelisk_schema = new(0,0,0,0,0,0);
		world::add_schema<GlobalData>(_obelisk_world, SCHEMA_ID, _obelisk_schema, admin_cap);
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), _obelisk_schema);
	}

	public(friend) fun set(_obelisk_world: &mut World,  scissors_count: u64, rock_count: u64, paper_count: u64, prop_count: u64, game_count: u64, card_count: u64) {
		let _obelisk_schema = world::get_mut_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.scissors_count = scissors_count;
		_obelisk_schema.rock_count = rock_count;
		_obelisk_schema.paper_count = paper_count;
		_obelisk_schema.prop_count = prop_count;
		_obelisk_schema.game_count = game_count;
		_obelisk_schema.card_count = card_count;
	}

	public(friend) fun set_scissors_count(_obelisk_world: &mut World, scissors_count: u64) {
		let _obelisk_schema = world::get_mut_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.scissors_count = scissors_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_rock_count(_obelisk_world: &mut World, rock_count: u64) {
		let _obelisk_schema = world::get_mut_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.rock_count = rock_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_paper_count(_obelisk_world: &mut World, paper_count: u64) {
		let _obelisk_schema = world::get_mut_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.paper_count = paper_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_prop_count(_obelisk_world: &mut World, prop_count: u64) {
		let _obelisk_schema = world::get_mut_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prop_count = prop_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_game_count(_obelisk_world: &mut World, game_count: u64) {
		let _obelisk_schema = world::get_mut_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.game_count = game_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_card_count(_obelisk_world: &mut World, card_count: u64) {
		let _obelisk_schema = world::get_mut_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.card_count = card_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public fun get(_obelisk_world: &World): (u64,u64,u64,u64,u64,u64) {
		let _obelisk_schema = world::get_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		(
			_obelisk_schema.scissors_count,
			_obelisk_schema.rock_count,
			_obelisk_schema.paper_count,
			_obelisk_schema.prop_count,
			_obelisk_schema.game_count,
			_obelisk_schema.card_count,
		)
	}

	public fun get_scissors_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.scissors_count
	}

	public fun get_rock_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.rock_count
	}

	public fun get_paper_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.paper_count
	}

	public fun get_prop_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prop_count
	}

	public fun get_game_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.game_count
	}

	public fun get_card_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<GlobalData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.card_count
	}
}
