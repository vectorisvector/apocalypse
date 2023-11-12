module apocalypse::prop_system {
    use std::string::{Self, String, utf8};

    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};

    use apocalypse::world::{World};
    use apocalypse::global_schema::{Self as global};
    use apocalypse::pool_schema::{Self as pool};

    friend apocalypse::pool_system;
    friend apocalypse::game_system;

    // ----------Errors----------
    const EInvalidType: u64 = 0;

    // ----------Consts----------
    const SCISSORS: vector<u8> = b"scissors";
    const ROCK: vector<u8> = b"rock";
    const PAPER: vector<u8> = b"paper";

    // ----------Structs----------
    struct Prop has key, store {
        id: UID,
        type: String,
        balance: Balance<SUI>,
    }

    // ----------Friend Functions----------
    public(friend) fun new(type: vector<u8>, coin: Coin<SUI>, world: &mut World, ctx: &mut TxContext): Prop {
        assert!(type == SCISSORS || type == ROCK || type == PAPER, EInvalidType);

        let prop = Prop {
            id: object::new(ctx),
            type: utf8(type),
            balance: coin::into_balance(coin),
        };

        update_global_count(type, 1, true, world);

        prop
    }

    public(friend) fun burn(prop: Prop, world: &mut World, ctx: &mut TxContext): Coin<SUI> {
        let Prop {
            id,
            type,
            balance,
        } = prop;
        object::delete(id);

        update_global_count(*string::bytes(&type), 1, false, world);

        coin::from_balance(balance, ctx)
    }

    // ----------Getters----------
    public fun type(prop: &Prop): vector<u8> {
        *string::bytes(&prop.type)
    }

    public fun balance(prop: &Prop): u64 {
        balance::value(&prop.balance)
    }

    public(friend) fun balance_mut(prop: &mut Prop): &mut Balance<SUI> {
        &mut prop.balance
    }

    public fun min_prop_balance(world: &World): u64 {
        let prop_mint_fee = pool::get_prop_mint_fee(world); // 2 sui
        let min_prop_fee = (pool::get_min_prop_fee(world) as u64); // 80%
        prop_mint_fee * min_prop_fee / 10_000
    }

    public fun game_fee_amount(world: &World): u64 {
        let prop_mint_fee = pool::get_prop_mint_fee(world); // 2 sui
        let game_fee = (pool::get_game_fee(world) as u64); // 5%
        prop_mint_fee * game_fee / 10_000
    }

    // ----------Helpers----------
    fun update_global_count(type: vector<u8>, count: u64, in: bool, world: &mut World) {
        let prop_count = if (in) {
            global::get_prop_count(world) + count
        } else {
            global::get_prop_count(world) - count
        };
        global::set_prop_count(world, prop_count);

        if (type == SCISSORS) {
            let scissors_count = if (in) {
                global::get_scissors_count(world) + count
            } else {
                global::get_scissors_count(world) - count
            };
            global::set_scissors_count(world, scissors_count);
        };

        if (type == ROCK ) {
            let rock_count = if (in) {
                global::get_rock_count(world) + count
            } else {
                global::get_rock_count(world) - count
            };
            global::set_rock_count(world, rock_count);
        };

        if (type == PAPER) {
            let paper_count = if (in) {
                global::get_paper_count(world) + count
            } else {
                global::get_paper_count(world) - count
            };
            global::set_paper_count(world, paper_count);
        };
    }
}
