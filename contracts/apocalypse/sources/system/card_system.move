module apocalypse::card_system {
    use std::vector::{Self};

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{Self};

    use apocalypse::world::{World};
    use apocalypse::global_schema::{Self as global};
    use apocalypse::pool_schema::{Self as pool};
    use apocalypse::card_map_schema::{Self as card_map};

    friend apocalypse::pool_system;
    friend apocalypse::game_system;

    // ----------Structs----------
    struct Card has key {
        id: UID,
        size: u64,
        fees: u64,
        last_player_balance_plus: u64,
    }

    // ----------Friend Functions----------
    public(friend) fun new(world: &mut World, ctx: &mut TxContext): Card {
        let card_count = global::get_card_count(world);
        global::set_card_count(world, card_count + 1);

        let player = tx_context::sender(ctx);
        let player_balance_plus = pool::get_player_balance_plus(world);
        let card = Card {
            id: object::new(ctx),
            size: 0,
            fees: 0,
            last_player_balance_plus: player_balance_plus,
        };

        push_in_cards(object::id_address(&card), player, world);

        card
    }

    public(friend) fun update_size(count: u64, in: bool, card: &mut Card, world: &World) {
        let fees_plus = fees_plus(card, world);

        update_fees(fees_plus, true, card);
        card.size = if (in) {
            card.size + count
        } else {
            card.size - count
        };
    }

    public(friend) fun update_fees(count: u64, in: bool, card: &mut Card) {
        card.fees = if (in) {
            card.fees + count
        } else {
            card.fees - count
        };
    }

    public(friend) fun fees_plus(card: &Card, world: &World): u64 {
        let player_balance_plus = pool::get_player_balance_plus(world);
        let last_player_balance_plus = card.last_player_balance_plus;
        let prop_count = pool::get_prop_count(world);
        prop_count = if (prop_count == 0) { 1 } else { prop_count };

        let size = card.size;
        let fees_plus = (player_balance_plus - last_player_balance_plus) * size / prop_count;
        fees_plus
    }

    // ----------Public Functions----------
    public fun transfer(card: Card, to: address, world: &mut World, ctx: &TxContext) {
        let from = tx_context::sender(ctx);
        let card_address = object::id_address(&card);

        remove_in_cards(card_address, from, world);
        push_in_cards(card_address, to, world);

        transfer::transfer(card, to);
    }

    // ----------Getters----------
    public fun size(card: &Card): u64 {
        card.size
    }

    public fun fees(card: &Card): u64 {
        card.fees
    }

    public fun last_player_balance_plus(card: &Card): u64 {
        card.last_player_balance_plus
    }

    // ----------Helpers----------
    fun push_in_cards(card_address: address, player: address, world: &mut World) {
        if (!card_map::contains(world, player)) {
            card_map::set(world, player, vector::empty());
        };
        let cards = card_map::get(world, player);
        vector::push_back(&mut cards, card_address);
        card_map::set(world, player, cards);
    }

    fun remove_in_cards(card_address: address, player: address, world: &mut World) {
        let cards = card_map::get(world, player);
        let (in, i) = vector::index_of(&cards, &card_address);
        if (in) {
            vector::remove(&mut cards, i);
        };
        card_map::set(world, player, cards);
    }
}
