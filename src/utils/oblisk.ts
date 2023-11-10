import { getMetadata, Obelisk, NetworkType } from "@0xobelisk/client";

const network = "devnet" as NetworkType;
const packageId =
  "0x804578b9eed47d461bba52c393cf148302819e2ba0a0f558356cc419b3e941ed";

const metadata = await getMetadata(network, packageId);

export const obelisk = new Obelisk({
  networkType: network,
  packageId: packageId,
  metadata: metadata,
});

console.log(obelisk, metadata);
