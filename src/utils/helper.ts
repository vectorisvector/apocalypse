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
