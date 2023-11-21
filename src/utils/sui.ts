import { SuiClient, getFullnodeUrl } from "@mysten/sui.js/client";

const rpcUrl = getFullnodeUrl("testnet");
export const suiClient = new SuiClient({ url: rpcUrl });
