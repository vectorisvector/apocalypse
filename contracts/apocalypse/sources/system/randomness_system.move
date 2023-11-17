module apocalypse::randomness_system {
    use std::hash::{Self};
    use std::vector::{Self};
    use sui::clock::{Clock, timestamp_ms};

    use sui::bls12381::{Self};
    use sui::tx_context::{Self, TxContext};

    use apocalypse::world::{World};
    use apocalypse::randomness_schema::{Self};

    friend apocalypse::game_system;

    // ----------Errors----------
    const EInvalidProof: u64 = 0;

    // ----------Consts----------
    const GENESIS: u64 = 1595431050;
    const DRAND_PK: vector<u8> = x"868f005eb8e6e4ca0a47c8a77ceaa5309a47978a7c71bc5cce96366b5d7a569937c529eeda66c7293784a9402801af31";

    /// Update randomness
    public(friend) fun update_randomness(sig: vector<u8>, prev_sig: vector<u8>, round: u64, world: &mut World, ctx: &TxContext) {
        let seed = derive_seed(sig, prev_sig, round);
        let tx_hash = tx_context::digest(ctx);
        vector::append(&mut seed, *tx_hash);

        randomness_schema::set_sig(world, sig);
        randomness_schema::set_prev_sig(world, prev_sig);
        randomness_schema::set_round(world, round);
        randomness_schema::set_seed(world, seed);
        randomness_schema::set_value(world, seed);
    }

    /// Update randomness value
    fun next_digest(world: &mut World): vector<u8> {
        let value = hash::sha2_256(randomness_schema::get_value(world));
        randomness_schema::set_value(world, value);
        value
    }

    /// Generate a random u8
    fun next_u8(world: &mut World): u8 {
        vector::pop_back(&mut next_digest(world))
    }

    /// Generate a random u8 in the range [0, upper_bound - 1]
    public(friend) fun next_u8_in_range(upper_bound: u8, world: &mut World): u8 {
        assert!(upper_bound > 0, 0);
        next_u8(world) % upper_bound
    }

    /// Generate a random u64
    public fun next_u64(world: &mut World): u64 {
        (next_u256_in_range(world, 1 << 64) as u64)
    }

    /// Generate a random u64 in the range [0, upper_bound - 1]
    public fun next_u64_in_range(world: &mut World, upper_bound: u64): u64 {
        assert!(upper_bound > 0, 0);
        next_u64(world) % upper_bound
    }

      /// Generate a random u256
    public fun next_u256(world: &mut World): u256 {
        let bytes = next_digest(world);
        let (value, i) = (0u256, 0u8);

        while (i < 32) {
        let byte = (vector::pop_back(&mut bytes) as u256);
        value = value + (byte << 8*i);
        i = i + 1;
        };

        value
    }

    /// Generate a random u256 in the range [0, upper_bound - 1]
    public fun next_u256_in_range(world: &mut World, upper_bound: u256): u256 {
        assert!(upper_bound > 0, 0);
        next_u256(world) % upper_bound
    }

    public fun round_time(round: u64): u64 {
        GENESIS + 30 * (round - 1)
    }

    public fun check_round_expired(round: u64, clock: &Clock): bool {
        (timestamp_ms(clock) / 1_000) > (round_time(round) + 30)
    }

    public fun derive_seed(sig: vector<u8>, prev_sig: vector<u8>, round: u64): vector<u8> {
        verify_drand_signature(sig, prev_sig, round);
        hash::sha2_256(sig)
    }

    public fun verify_drand_signature(sig: vector<u8>, prev_sig: vector<u8>, round: u64) {
        let round_bytes: vector<u8> = vector[0, 0, 0, 0, 0, 0, 0, 0];
        let i = 7;
        while (i > 0) {
        let curr_byte = round % 0x100;
        let curr_element = vector::borrow_mut(&mut round_bytes, i);
        *curr_element = (curr_byte as u8);
        round = round >> 8;
        i = i - 1;
        };

        vector::append(&mut prev_sig, round_bytes);
        let digest = hash::sha2_256(prev_sig);

        assert!(bls12381::bls12381_min_pk_verify(&sig, &DRAND_PK, &digest), EInvalidProof);
    }
}
