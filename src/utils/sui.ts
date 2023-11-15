import { SuiClient, getFullnodeUrl } from "@mysten/sui.js/client";

const rpcUrl = getFullnodeUrl("devnet");
export const suiClient = new SuiClient({ url: rpcUrl });
