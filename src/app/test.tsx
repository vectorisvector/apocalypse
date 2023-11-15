import { useCallback, useEffect } from "react";
import {
  useCurrentAccount,
  useSignAndExecuteTransactionBlock,
} from "@mysten/dapp-kit";
import { SuiClient, getFullnodeUrl } from "@mysten/sui.js/client";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { bcs } from "@mysten/sui.js/bcs";
import objectData from "@/utils/config";

const rpcUrl = getFullnodeUrl("devnet");
const client = new SuiClient({ url: rpcUrl });

export default function Test() {
  const account = useCurrentAccount();
  const { mutate: signAndExecuteTransactionBlock } =
    useSignAndExecuteTransactionBlock();

  useEffect(() => {
    (async () => {
      let res = await client.multiGetObjects({
        ids: Object.values(objectData),
        options: {
          showContent: true,
        },
      });
      res.forEach((object) => {
        const arr = Object.entries(objectData);
        const o = arr.find((item) => item[1] === object.data?.objectId ?? "");
        if (o) {
          console.log(o[0], "=>");
          console.log(object.data?.content);
        }
      });
      console.log("--------------------");
    })();
  }, [account]);

  const handle = useCallback(async () => {
    if (!account) return;

    console.log(
      Uint8Array.from(
        Array.from("scissors").map((letter) => letter.charCodeAt(0)),
      ),
    );

    const txb = new TransactionBlock();
    const [coin] = txb.splitCoins(txb.gas, [100]);
    const [prop, coin_] = txb.moveCall({
      target: `${objectData.packageId}::pool_system::mint`,
      arguments: [
        // txb.pure.u8('scissors'),
        txb.pure(
          bcs
            .vector(bcs.u8())
            .serialize(
              Uint8Array.from(
                Array.from("scissors").map((letter) => letter.charCodeAt(0)),
              ),
            ),
        ),
        coin,
        txb.object(objectData.world),
      ],
    });
    txb.transferObjects([prop, coin_], account.address);

    signAndExecuteTransactionBlock(
      {
        transactionBlock: txb,
        chain: "sui:devnet",
      },
      {
        onSuccess: (result) => {
          console.log("executed transaction block", result);
        },
      },
    );
  }, [account, signAndExecuteTransactionBlock]);

  return (
    <button
      className="btn btn-primary"
      onClick={() => handle()}
    >
      Mint
    </button>
  );
}
