import useSWR from "swr";
import useSWRMutation from "swr/mutation";
import { global_schema, packageId, pool_schema, world } from "./config";
import { suiClient } from "./sui";
import { GlobalWrapper, PoolWrapper, PropType } from "@/types/type";
import {
  useCurrentAccount,
  useSignAndExecuteTransactionBlock,
} from "@mysten/dapp-kit";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { MIST_PER_SUI } from "@mysten/sui.js/utils";

export const useBalance = (address?: string) => {
  const { data } = useSWR(
    address + "/balance",
    () => {
      if (!address) return;
      return suiClient.getBalance({
        owner: address,
      });
    },
    { refreshInterval: 10_000 },
  );

  return data;
};

export const usePool = () => {
  const { data } = useSWR(
    "pool",
    () => {
      return suiClient
        .getObject({
          id: pool_schema,
          options: {
            showContent: true,
          },
        })
        .then((res) => res.data);
    },
    { refreshInterval: 10_000 },
  );

  if (data?.content?.dataType === "moveObject") {
    return (data.content.fields as unknown as PoolWrapper).value.fields;
  }
};

export const useGlobal = () => {
  const { data } = useSWR(
    "global",
    () => {
      return suiClient
        .getObject({
          id: global_schema,
          options: {
            showContent: true,
          },
        })
        .then((res) => res.data);
    },
    { refreshInterval: 10_000 },
  );

  if (data?.content?.dataType === "moveObject") {
    return (data.content.fields as unknown as GlobalWrapper).value.fields;
  }
};

export const useAccountData = (address?: string) => {
  const { data } = useSWR(
    address + "/accountData",
    () => {
      if (!address) return;
      return suiClient
        .getOwnedObjects({
          owner: address,
          filter: {
            StructType: `${packageId}::prop_system::Prop`,
          },
          options: {
            showContent: true,
          },
        })
        .then((res) => res.data);
    },
    { refreshInterval: 10_000 },
  );
  console.log(data);

  return data?.map(({ data }) => {
    if (data?.content?.dataType === "moveObject") {
      // return (data.content.fields as unknown as GlobalWrapper).value.fields;
    }
  });
};

export const useMint = () => {
  const account = useCurrentAccount();

  const { mutate: signAndExecuteTransactionBlock } =
    useSignAndExecuteTransactionBlock();

  const { trigger } = useSWRMutation(
    "mint",
    (
      _,
      {
        arg: { type, count },
      }: {
        arg: {
          type: PropType;
          count: number;
        };
      },
    ) => {
      if (!account) return;

      const txb = new TransactionBlock();
      for (let i = 0; i < count; i++) {
        const [coin] = txb.splitCoins(txb.gas, [2n * MIST_PER_SUI]);
        const [prop, coin_] = txb.moveCall({
          target: `${packageId}::pool_system::mint`,
          arguments: [txb.pure.string(type), coin, txb.object(world)],
        });
        txb.transferObjects([prop, coin_], account.address);
      }

      signAndExecuteTransactionBlock(
        {
          transactionBlock: txb,
        },
        {
          onSuccess: (result) => {
            console.log("executed transaction block", result);
          },
          onError: (error) => {
            console.error("failed to execute transaction block", error);
          },
        },
      );
    },
  );

  return {
    mint: trigger,
  };
};
