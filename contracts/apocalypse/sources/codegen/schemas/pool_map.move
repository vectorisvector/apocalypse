module apocalypse::pool_map_schema {
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

	const SCHEMA_ID: vector<u8> = b"pool_map";
	const SCHEMA_TYPE: u8 = 0;

	// value
	struct PoolMapData has copy, drop , store {
		value: address
	}

	public fun new(value: address): PoolMapData {
		PoolMapData {
			value
		}
	}

	public fun register(_obelisk_world: &mut World, admin_cap: &AdminCap, ctx: &mut TxContext) {
		world::add_schema<Table<address,PoolMapData>>(_obelisk_world, SCHEMA_ID, table::new<address, PoolMapData>(ctx), admin_cap);
	}

	public(friend) fun set(_obelisk_world: &mut World, _obelisk_entity_key: address,  value: address) {
		let _obelisk_schema = world::get_mut_schema<Table<address,PoolMapData>>(_obelisk_world, SCHEMA_ID);
		let _obelisk_data = new( value);
		if(table::contains<address, PoolMapData>(_obelisk_schema, _obelisk_entity_key)) {
			*table::borrow_mut<address, PoolMapData>(_obelisk_schema, _obelisk_entity_key) = _obelisk_data;
		} else {
			table::add(_obelisk_schema, _obelisk_entity_key, _obelisk_data);
		};
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, some(_obelisk_entity_key), _obelisk_data)
	}

	public fun get(_obelisk_world: &World, _obelisk_entity_key: address): address {
		let _obelisk_schema = world::get_schema<Table<address,PoolMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, PoolMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		let _obelisk_data = table::borrow<address, PoolMapData>(_obelisk_schema, _obelisk_entity_key);
		(
			_obelisk_data.value
		)
	}

	public(friend) fun remove(_obelisk_world: &mut World, _obelisk_entity_key: address) {
		let _obelisk_schema = world::get_mut_schema<Table<address,PoolMapData>>(_obelisk_world, SCHEMA_ID);
		assert!(table::contains<address, PoolMapData>(_obelisk_schema, _obelisk_entity_key), EEntityDoesNotExist);
		table::remove(_obelisk_schema, _obelisk_entity_key);
		events::emit_remove(SCHEMA_ID, _obelisk_entity_key)
	}

	public fun contains(_obelisk_world: &World, _obelisk_entity_key: address): bool {
		let _obelisk_schema = world::get_schema<Table<address,PoolMapData>>(_obelisk_world, SCHEMA_ID);
		table::contains<address, PoolMapData>(_obelisk_schema, _obelisk_entity_key)
	}
}
