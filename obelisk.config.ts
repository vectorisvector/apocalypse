import { ObeliskConfig } from "@0xobelisk/sui-common";

export const obeliskConfig: ObeliskConfig = {
  name: "apocalypse",
  description: "Apocalypse game on the chain",
  systems: [
    "prop_system",
    "pool_system",
    "game_system",
    "card_system",
    "randomness_system",
  ],
  schemas: {
    staker_map: {
      valueType: {
        fees: "u64",
        size: "u64",
        scissors_count: "u64",
        rock_count: "u64",
        paper_count: "u64",
        last_staker_balance_plus: "u64",
      },
    }, // staker => { fees: 0, size: 0, last_staker_balance_plus: 0 }
    game_map: {
      valueType: {
        player: "address",
        index: "u64",
      },
    }, // prop => player
    pool_map: {
      valueType: {
        staker: "address",
        index: "u64",
      },
    }, // prop => staker
    card_map: "vector<address>", // player => [ card1, card2, ... ]
    pool: {
      valueType: {
        balance: "u64",
        staker_balance: "u64",
        staker_balance_plus: "u64",
        player_balance: "u64",
        player_balance_plus: "u64",
        founder_balance: "u64",
        prop_mint_fee: "u64",
        game_fee: "u64",
        min_prop_fee: "u64",
        prop_burn_fee: "u64",
        to_staker_fee: "u64",
        to_player_fee: "u64",
        scissors_count: "u64",
        rock_count: "u64",
        paper_count: "u64",
        prop_count: "u64",
      },
      defaultValue: {
        balance: 0,
        staker_balance: 0,
        staker_balance_plus: 0,
        player_balance: 0,
        player_balance_plus: 0,
        founder_balance: 0,
        prop_mint_fee: 2_000_000_000, // 2 Sui
        game_fee: 500, // 5%
        min_prop_fee: 8_000, // 80%
        prop_burn_fee: 100, // 1%
        to_staker_fee: 5_000, // 50%
        to_player_fee: 5_000, // 50%
        scissors_count: 0,
        rock_count: 0,
        paper_count: 0,
        prop_count: 0,
      },
    },
    global: {
      valueType: {
        scissors_count: "u64",
        rock_count: "u64",
        paper_count: "u64",
        prop_count: "u64",
        game_count: "u64",
        card_count: "u64",
      },
      defaultValue: {
        scissors_count: 0,
        rock_count: 0,
        paper_count: 0,
        prop_count: 0,
        game_count: 0,
        card_count: 0,
      },
    },
    randomness: {
      valueType: {
        sig: "vector<u8>",
        prev_sig: "vector<u8>",
        round: "u64",
        seed: "vector<u8>",
        value: "vector<u8>",
      },
      defaultValue: {
        sig: [""],
        prev_sig: [""],
        round: 0,
        seed: [""],
        value: [""],
      },
    },
  },
};
