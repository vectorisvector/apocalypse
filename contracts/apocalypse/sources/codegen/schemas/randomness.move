module apocalypse::randomness_schema {
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

	const SCHEMA_ID: vector<u8> = b"randomness";
	const SCHEMA_TYPE: u8 = 1;

	// sig
	// prev_sig
	// round
	// seed
	// value
	struct RandomnessData has copy, drop , store {
		sig: vector<u8>,
		prev_sig: vector<u8>,
		round: u64,
		seed: vector<u8>,
		value: vector<u8>
	}

	public fun new(sig: vector<u8>, prev_sig: vector<u8>, round: u64, seed: vector<u8>, value: vector<u8>): RandomnessData {
		RandomnessData {
			sig, 
			prev_sig, 
			round, 
			seed, 
			value
		}
	}

	public fun register(_obelisk_world: &mut World, admin_cap: &AdminCap, _ctx: &mut TxContext) {
		let _obelisk_schema = new(vector[],vector[],0,vector[],vector[]);
		world::add_schema<RandomnessData>(_obelisk_world, SCHEMA_ID, _obelisk_schema, admin_cap);
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), _obelisk_schema);
	}

	public(friend) fun set(_obelisk_world: &mut World,  sig: vector<u8>, prev_sig: vector<u8>, round: u64, seed: vector<u8>, value: vector<u8>) {
		let _obelisk_schema = world::get_mut_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.sig = sig;
		_obelisk_schema.prev_sig = prev_sig;
		_obelisk_schema.round = round;
		_obelisk_schema.seed = seed;
		_obelisk_schema.value = value;
	}

	public(friend) fun set_sig(_obelisk_world: &mut World, sig: vector<u8>) {
		let _obelisk_schema = world::get_mut_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.sig = sig;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_prev_sig(_obelisk_world: &mut World, prev_sig: vector<u8>) {
		let _obelisk_schema = world::get_mut_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prev_sig = prev_sig;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_round(_obelisk_world: &mut World, round: u64) {
		let _obelisk_schema = world::get_mut_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.round = round;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_seed(_obelisk_world: &mut World, seed: vector<u8>) {
		let _obelisk_schema = world::get_mut_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.seed = seed;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_value(_obelisk_world: &mut World, value: vector<u8>) {
		let _obelisk_schema = world::get_mut_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.value = value;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public fun get(_obelisk_world: &World): (vector<u8>,vector<u8>,u64,vector<u8>,vector<u8>) {
		let _obelisk_schema = world::get_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		(
			_obelisk_schema.sig,
			_obelisk_schema.prev_sig,
			_obelisk_schema.round,
			_obelisk_schema.seed,
			_obelisk_schema.value,
		)
	}

	public fun get_sig(_obelisk_world: &World): vector<u8> {
		let _obelisk_schema = world::get_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.sig
	}

	public fun get_prev_sig(_obelisk_world: &World): vector<u8> {
		let _obelisk_schema = world::get_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prev_sig
	}

	public fun get_round(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.round
	}

	public fun get_seed(_obelisk_world: &World): vector<u8> {
		let _obelisk_schema = world::get_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.seed
	}

	public fun get_value(_obelisk_world: &World): vector<u8> {
		let _obelisk_schema = world::get_schema<RandomnessData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.value
	}
}
