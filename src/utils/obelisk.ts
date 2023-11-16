import { loadMetadata, Obelisk } from "@0xobelisk/sui-client";
import { NETWORK, PACKAGE_ID } from "../../chain/devnet/config";

const metadata = await loadMetadata(NETWORK, PACKAGE_ID);

export const obelisk = new Obelisk({
  networkType: NETWORK,
  packageId: PACKAGE_ID,
  metadata: metadata,
});
