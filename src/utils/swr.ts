import useSWR from "swr";
import useSWRMutation from "swr/mutation";
import { global_schema, packageId, pool, pool_schema, world } from "./config";
import { suiClient } from "./sui";
import {
  GlobalWrapper,
  PoolWrapper,
  Prop,
  PropType,
  Props,
} from "@/types/type";
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

export const useAccountProps = (address?: string) => {
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

  const props: Props = {
    scissors: [],
    rock: [],
    paper: [],
  };

  data?.forEach(({ data }) => {
    if (data?.content?.dataType === "moveObject") {
      const prop = data.content.fields as unknown as Prop;
      props[prop.type].push(prop.id.id);
    }
  });
  return props;
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

export const useBurn = () => {
  const account = useCurrentAccount();

  const { mutate: signAndExecuteTransactionBlock } =
    useSignAndExecuteTransactionBlock();

  const { trigger } = useSWRMutation(
    "mint",
    (
      _,
      {
        arg: { propIds },
      }: {
        arg: {
          propIds: string[];
        };
      },
    ) => {
      if (!account) return;

      const txb = new TransactionBlock();

      for (const propId of propIds) {
        const coin = txb.moveCall({
          target: `${packageId}::pool_system::burn`,
          arguments: [txb.object(propId), txb.object(pool), txb.object(world)],
        });
        txb.transferObjects([coin], account.address);
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
    burn: trigger,
  };
};
