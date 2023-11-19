import { Pool, PoolOriginal, Prop, PropOriginal } from "@/types/type";
import { MIST_PER_SUI } from "@mysten/sui.js/utils";
import BigNumber from "bignumber.js";

/**
 * Truncate the address, keep the first 6 digits and the last four digits, and use ... in the middle
 * @param address address
 * @returns truncated address
 */
export function truncateAddress(address: string): string {
  if (address.length <= 10) {
    return address;
  }
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

/**
 * Convert mist to sui
 * @param mist mist
 * @param decimal decimal
 * @returns sui
 */
export function mistToSui(mist: number | string, decimal: number = 2): string {
  BigNumber.config({
    ROUNDING_MODE: BigNumber.ROUND_DOWN,
  });
  const v = new BigNumber(mist);
  const sui = v.div(MIST_PER_SUI.toString()).toFixed(decimal);
  return sui;
}

/**
 * Converts an array of 8 numbers representing a 64-bit unsigned integer to a string.
 *
 * @param u64 - An array of 8 numbers representing a 64-bit unsigned integer.
 * @returns A string representation of the 64-bit unsigned integer.
 */
export function u64ToString(u64: number[]): string {
  const buffer = new ArrayBuffer(8);
  const byteView = new Uint8Array(buffer);
  for (let i = 0; i < 8; i++) {
    byteView[i] = u64[i];
  }

  const dataView = new DataView(buffer);
  const u64Value = dataView.getBigUint64(0, true);

  return u64Value.toString();
}

/**
 * Returns the timestamp for a specified round number.
 * @param round The round number.
 * @returns The timestamp.
 */
export function roundTime(round: number): number {
  const GENESIS = 1595431050;
  return GENESIS + 30 * (round - 1);
}

export function checkRoundExpired(round: number): boolean {
  return Date.now() / 1000 > roundTime(round) + 30;
}

export function formatProp(prop: PropOriginal): Prop {
  return {
    id: prop.id.id,
    type: prop.type,
    balance: prop.balance,
  };
}

export function formatPool(pool: PoolOriginal): Pool {
  return {
    id: pool.id.id,
    balance: pool.balance,
    gaming_props: pool.gaming_props.map((prop) => formatProp(prop.fields)),
    staking_props: pool.staking_props.map((prop) => formatProp(prop.fields)),
  };
}
