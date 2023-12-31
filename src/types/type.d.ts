export interface PoolSchemaWrapper {
  value: {
    fields: PoolSchema;
  };
}

export interface PoolSchema {
  balance: string;
  staker_balance: string;
  staker_balance_plus: string;
  player_balance: string;
  player_balance_plus: string;
  founder_balance: string;
  prop_mint_fee: string;
  game_fee: string;
  min_prop_fee: string;
  prop_burn_fee: string;
  to_staker_fee: string;
  to_player_fee: string;
  scissors_count: string;
  rock_count: string;
  paper_count: string;
  prop_count: string;
}

export interface GlobalSchemaWrapper {
  value: {
    fields: GlobalSchema;
  };
}

export interface GlobalSchema {
  scissors_count: string;
  rock_count: string;
  paper_count: string;
  prop_count: string;
  game_count: string;
  card_count: string;
}

export type PropType = "scissors" | "rock" | "paper";

export interface PropOriginal {
  balance: string;
  type: PropType;
  id: {
    id: string;
  };
}

export interface Prop {
  id: string;
  type: PropType;
  balance: string;
}

export interface Props {
  rock: Prop[];
  scissors: Prop[];
  paper: Prop[];
}

export interface CardOriginal {
  id: {
    id: string;
  };
  size: string;
  fees: string;
  last_player_balance_plus: string;
}

export interface Card {
  id: string;
  size: string;
  fees: string;
  last_player_balance_plus: string;
}

export interface PoolOriginal {
  balance: string;
  id: {
    id: string;
  };
  gaming_props: {
    type: PropType;
    fields: PropOriginal;
  }[];
  staking_props: {
    type: PropType;
    fields: PropOriginal;
  }[];
}

export interface Pool {
  id: string;
  balance: string;
  gaming_props: Prop[];
  staking_props: Prop[];
}
