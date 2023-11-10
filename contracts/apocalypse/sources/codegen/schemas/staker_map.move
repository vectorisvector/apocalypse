module apocalypse::staker_map_schema {
	use std::option::some;
    use sui::tx_context::TxContext;
    use sui::table::{Self, Table};
    use apocalypse::events;
    use apocalypse::world::{Self, World, AdminCap};

    // Systems
	friend apocalypse::prop_system;
	friend apocalypse::pool_system;
	friend apocalypse::game_system;
	friend apocalypse::card_system;
	friend apocalypse::randomness_system;
	friend apocalypse::deploy_hook;

	/// Entity does not exist
	const EEntityDoesNotExist: u64 = 0;

	const SCHEMA_ID: vector<u8> = b"staker_map";
	const SCHEMA_TYPE: u8 = 0;

	// fees
	// size
	// scissors_count
	// rock_count
	// paper_count
	// last_staker_balance_plus
	struct StakerMapData has copy, drop , store {
		fees: u64,
		size: u64,
		scissors_count: u64,
		rock_count: u64,
		paper_count: u64,
		last_staker_balance_plus: u64
	}

	public fun new(fees: u64, size: u64, scissors_count: u64, rock_count: u64, paper_count: u64, last_staker_balance_plus: u64): StakerMapData {
		StakerMapData {
			fees, 
			size, 
			scissors_count, 
			rock_count, 
			paper_count, 
			last_staker_balance_plus
		}
	}

	public fun register(_obelisk_world: &mut World, admin_cap: &AdminCap, ctx: &mut TxContext) {
		world::add_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID, table::new<address, StakerMapData>(ctx), admin_cap);
	}

	public(friend) fun set(_obelisk_world: &mut World, _obelisk_entity_key: address,  fees: u64, size: u64, scissors_count: u64, rock_count: u64, paper_count: u64, last_staker_balance_plus: u64) {
		let _obelisk_schema = world::get_mut_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		let _obelisk_data = new( fees, size, scissors_count, rock_count, paper_count, last_staker_balance_plus);
		if(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key)) {
			*table::borrow_mut<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key) = _obelisk_data;
		} else {
			table::add(_obelisk_schema, _obelisk_entity_key, _obelisk_data);
		};
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, some(_obelisk_entity_key), _obelisk_data)
	}

	public(friend) fun set_fees(_obelisk_world: &mut World, _obelisk_entity_key: address, fees: u64) {
		let _obelisk_schema = world::get_mut_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow_mut<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.fees = fees;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, some(_obelisk_entity_key), *_obelisk_data)
	}

	public(friend) fun set_size(_obelisk_world: &mut World, _obelisk_entity_key: address, size: u64) {
		let _obelisk_schema = world::get_mut_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow_mut<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.size = size;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, some(_obelisk_entity_key), *_obelisk_data)
	}

	public(friend) fun set_scissors_count(_obelisk_world: &mut World, _obelisk_entity_key: address, scissors_count: u64) {
		let _obelisk_schema = world::get_mut_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow_mut<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.scissors_count = scissors_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, some(_obelisk_entity_key), *_obelisk_data)
	}

	public(friend) fun set_rock_count(_obelisk_world: &mut World, _obelisk_entity_key: address, rock_count: u64) {
		let _obelisk_schema = world::get_mut_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow_mut<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.rock_count = rock_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, some(_obelisk_entity_key), *_obelisk_data)
	}

	public(friend) fun set_paper_count(_obelisk_world: &mut World, _obelisk_entity_key: address, paper_count: u64) {
		let _obelisk_schema = world::get_mut_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow_mut<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.paper_count = paper_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, some(_obelisk_entity_key), *_obelisk_data)
	}

	public(friend) fun set_last_staker_balance_plus(_obelisk_world: &mut World, _obelisk_entity_key: address, last_staker_balance_plus: u64) {
		let _obelisk_schema = world::get_mut_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow_mut<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.last_staker_balance_plus = last_staker_balance_plus;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, some(_obelisk_entity_key), *_obelisk_data)
	}

	public fun get(_obelisk_world: &World, _obelisk_entity_key: address): (u64,u64,u64,u64,u64,u64) {
		let _obelisk_schema = world::get_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		(
			_obelisk_data.fees,
			_obelisk_data.size,
			_obelisk_data.scissors_count,
			_obelisk_data.rock_count,
			_obelisk_data.paper_count,
			_obelisk_data.last_staker_balance_plus
		)
	}

	public fun get_fees(_obelisk_world: &World, _obelisk_entity_key: address): u64 {
		let _obelisk_schema = world::get_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.fees
	}

	public fun get_size(_obelisk_world: &World, _obelisk_entity_key: address): u64 {
		let _obelisk_schema = world::get_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.size
	}

	public fun get_scissors_count(_obelisk_world: &World, _obelisk_entity_key: address): u64 {
		let _obelisk_schema = world::get_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.scissors_count
	}

	public fun get_rock_count(_obelisk_world: &World, _obelisk_entity_key: address): u64 {
		let _obelisk_schema = world::get_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.rock_count
	}

	public fun get_paper_count(_obelisk_world: &World, _obelisk_entity_key: address): u64 {
		let _obelisk_schema = world::get_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.paper_count
	}

	public fun get_last_staker_balance_plus(_obelisk_world: &World, _obelisk_entity_key: address): u64 {
		let _obelisk_schema = world::get_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key);
		_obelisk_data.last_staker_balance_plus
	}

	public(friend) fun remove(_obelisk_world: &mut World, _obelisk_entity_key: address) {
		let _obelisk_schema = world::get_mut_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		table::remove(_obelisk_schema, _obelisk_entity_key);
		events::emit_remove(SCHEMA_ID, _obelisk_entity_key)
	}

	public fun contains(_obelisk_world: &World, _obelisk_entity_key: address): bool {
		let _obelisk_schema = world::get_schema<Table<address,StakerMapData>>(_obelisk_world, SCHEMA_ID);
		table::contains<address, StakerMapData>(_obelisk_schema, _obelisk_entity_key)
	}
}
