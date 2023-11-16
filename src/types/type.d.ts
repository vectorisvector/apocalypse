export interface PoolWrapper {
  value: {
    fields: Pool;
  };
}

export interface Pool {
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

export interface GlobalWrapper {
  value: {
    fields: Global;
  };
}

export interface Global {
  scissors_count: string;
  rock_count: string;
  paper_count: string;
  prop_count: string;
  game_count: string;
  card_count: string;
}

export type PropType = "scissors" | "rock" | "paper";

export interface Prop {
  balance: string;
  type: PropType;
  id: {
    id: string;
  };
}

export interface Props {
  scissors: string[];
  rock: string[];
  paper: string[];
}
