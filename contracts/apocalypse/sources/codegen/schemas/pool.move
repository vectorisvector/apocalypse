module apocalypse::pool_schema {
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

	const SCHEMA_ID: vector<u8> = b"pool";
	const SCHEMA_TYPE: u8 = 1;

	// balance
	// staker_balance
	// staker_balance_plus
	// player_balance
	// player_balance_plus
	// founder_balance
	// prop_mint_fee
	// game_fee
	// min_prop_fee
	// prop_burn_fee
	// to_staker_fee
	// to_player_fee
	// scissors_count
	// rock_count
	// paper_count
	// prop_count
	struct PoolData has copy, drop , store {
		balance: u64,
		staker_balance: u64,
		staker_balance_plus: u64,
		player_balance: u64,
		player_balance_plus: u64,
		founder_balance: u64,
		prop_mint_fee: u64,
		game_fee: u16,
		min_prop_fee: u16,
		prop_burn_fee: u16,
		to_staker_fee: u16,
		to_player_fee: u16,
		scissors_count: u64,
		rock_count: u64,
		paper_count: u64,
		prop_count: u64
	}

	public fun new(balance: u64, staker_balance: u64, staker_balance_plus: u64, player_balance: u64, player_balance_plus: u64, founder_balance: u64, prop_mint_fee: u64, game_fee: u16, min_prop_fee: u16, prop_burn_fee: u16, to_staker_fee: u16, to_player_fee: u16, scissors_count: u64, rock_count: u64, paper_count: u64, prop_count: u64): PoolData {
		PoolData {
			balance, 
			staker_balance, 
			staker_balance_plus, 
			player_balance, 
			player_balance_plus, 
			founder_balance, 
			prop_mint_fee, 
			game_fee, 
			min_prop_fee, 
			prop_burn_fee, 
			to_staker_fee, 
			to_player_fee, 
			scissors_count, 
			rock_count, 
			paper_count, 
			prop_count
		}
	}

	public fun register(_obelisk_world: &mut World, admin_cap: &AdminCap, _ctx: &mut TxContext) {
		let _obelisk_schema = new(0,0,0,0,0,0,2000000000,500,8000,100,5000,5000,0,0,0,0);
		world::add_schema<PoolData>(_obelisk_world, SCHEMA_ID, _obelisk_schema, admin_cap);
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), _obelisk_schema);
	}

	public(friend) fun set(_obelisk_world: &mut World,  balance: u64, staker_balance: u64, staker_balance_plus: u64, player_balance: u64, player_balance_plus: u64, founder_balance: u64, prop_mint_fee: u64, game_fee: u16, min_prop_fee: u16, prop_burn_fee: u16, to_staker_fee: u16, to_player_fee: u16, scissors_count: u64, rock_count: u64, paper_count: u64, prop_count: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.balance = balance;
		_obelisk_schema.staker_balance = staker_balance;
		_obelisk_schema.staker_balance_plus = staker_balance_plus;
		_obelisk_schema.player_balance = player_balance;
		_obelisk_schema.player_balance_plus = player_balance_plus;
		_obelisk_schema.founder_balance = founder_balance;
		_obelisk_schema.prop_mint_fee = prop_mint_fee;
		_obelisk_schema.game_fee = game_fee;
		_obelisk_schema.min_prop_fee = min_prop_fee;
		_obelisk_schema.prop_burn_fee = prop_burn_fee;
		_obelisk_schema.to_staker_fee = to_staker_fee;
		_obelisk_schema.to_player_fee = to_player_fee;
		_obelisk_schema.scissors_count = scissors_count;
		_obelisk_schema.rock_count = rock_count;
		_obelisk_schema.paper_count = paper_count;
		_obelisk_schema.prop_count = prop_count;
	}

	public(friend) fun set_balance(_obelisk_world: &mut World, balance: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.balance = balance;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_staker_balance(_obelisk_world: &mut World, staker_balance: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.staker_balance = staker_balance;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_staker_balance_plus(_obelisk_world: &mut World, staker_balance_plus: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.staker_balance_plus = staker_balance_plus;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_player_balance(_obelisk_world: &mut World, player_balance: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.player_balance = player_balance;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_player_balance_plus(_obelisk_world: &mut World, player_balance_plus: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.player_balance_plus = player_balance_plus;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_founder_balance(_obelisk_world: &mut World, founder_balance: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.founder_balance = founder_balance;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_prop_mint_fee(_obelisk_world: &mut World, prop_mint_fee: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prop_mint_fee = prop_mint_fee;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_game_fee(_obelisk_world: &mut World, game_fee: u16) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.game_fee = game_fee;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_min_prop_fee(_obelisk_world: &mut World, min_prop_fee: u16) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.min_prop_fee = min_prop_fee;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_prop_burn_fee(_obelisk_world: &mut World, prop_burn_fee: u16) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prop_burn_fee = prop_burn_fee;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_to_staker_fee(_obelisk_world: &mut World, to_staker_fee: u16) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.to_staker_fee = to_staker_fee;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_to_player_fee(_obelisk_world: &mut World, to_player_fee: u16) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.to_player_fee = to_player_fee;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_scissors_count(_obelisk_world: &mut World, scissors_count: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.scissors_count = scissors_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_rock_count(_obelisk_world: &mut World, rock_count: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.rock_count = rock_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_paper_count(_obelisk_world: &mut World, paper_count: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.paper_count = paper_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public(friend) fun set_prop_count(_obelisk_world: &mut World, prop_count: u64) {
		let _obelisk_schema = world::get_mut_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prop_count = prop_count;
		events::emit_set(SCHEMA_ID, SCHEMA_TYPE, none(), *_obelisk_schema)
	}

	public fun get(_obelisk_world: &World): (u64,u64,u64,u64,u64,u64,u64,u16,u16,u16,u16,u16,u64,u64,u64,u64) {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		(
			_obelisk_schema.balance,
			_obelisk_schema.staker_balance,
			_obelisk_schema.staker_balance_plus,
			_obelisk_schema.player_balance,
			_obelisk_schema.player_balance_plus,
			_obelisk_schema.founder_balance,
			_obelisk_schema.prop_mint_fee,
			_obelisk_schema.game_fee,
			_obelisk_schema.min_prop_fee,
			_obelisk_schema.prop_burn_fee,
			_obelisk_schema.to_staker_fee,
			_obelisk_schema.to_player_fee,
			_obelisk_schema.scissors_count,
			_obelisk_schema.rock_count,
			_obelisk_schema.paper_count,
			_obelisk_schema.prop_count,
		)
	}

	public fun get_balance(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.balance
	}

	public fun get_staker_balance(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.staker_balance
	}

	public fun get_staker_balance_plus(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.staker_balance_plus
	}

	public fun get_player_balance(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.player_balance
	}

	public fun get_player_balance_plus(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.player_balance_plus
	}

	public fun get_founder_balance(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.founder_balance
	}

	public fun get_prop_mint_fee(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prop_mint_fee
	}

	public fun get_game_fee(_obelisk_world: &World): u16 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.game_fee
	}

	public fun get_min_prop_fee(_obelisk_world: &World): u16 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.min_prop_fee
	}

	public fun get_prop_burn_fee(_obelisk_world: &World): u16 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prop_burn_fee
	}

	public fun get_to_staker_fee(_obelisk_world: &World): u16 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.to_staker_fee
	}

	public fun get_to_player_fee(_obelisk_world: &World): u16 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.to_player_fee
	}

	public fun get_scissors_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.scissors_count
	}

	public fun get_rock_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.rock_count
	}

	public fun get_paper_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.paper_count
	}

	public fun get_prop_count(_obelisk_world: &World): u64 {
		let _obelisk_schema = world::get_schema<PoolData>(_obelisk_world, SCHEMA_ID);
		_obelisk_schema.prop_count
	}
}
