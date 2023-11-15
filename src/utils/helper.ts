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
