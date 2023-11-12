import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { fromB64 } from "@mysten/sui.js/utils";
import fs from "fs";

function generateAccount() {
  const keypair = new Ed25519Keypair();

  const privateKey_u8 = fromB64(keypair.export().privateKey);
  const privateKey = Buffer.from(privateKey_u8).toString("hex");

  const path = process.cwd();

  fs.writeFileSync(`${path}/.env`, `PRIVATE_KEY=${privateKey}`);

  console.log(`Generate new Account: ${keypair.toSuiAddress()}`);
}

generateAccount();
