import useSWR from "swr";
import useSWRMutation from "swr/mutation";
import {
  global_schema,
  packageId,
  pool,
  pool_map_schema,
  pool_schema,
  world,
} from "./config";
import { suiClient } from "./sui";
import {
  GlobalWrapper,
  PoolWrapper,
  Prop,
  PropType,
  Props,
} from "@/types/type";
// import { TransactionBlock } from "@mysten/sui.js/transactions";
import { MIST_PER_SUI } from "@mysten/sui.js/utils";
import { obelisk } from "./obelisk";
import { TransactionBlock } from "@mysten/sui.js";
import { useWallet } from "@suiet/wallet-kit";
