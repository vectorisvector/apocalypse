import useSWR from "swr";
import useSWRMutation from "swr/mutation";
import { suiClient } from "./sui";
import { global_schema, packageId, pool, pool_schema, world } from "./config";
import {
  GlobalWrapper,
  PoolWrapper,
  Prop,
  PropType,
  Props,
} from "@/types/type";
import { useWallet } from "@suiet/wallet-kit";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { u64ToString } from "./helper";
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
    address + "/accountProps",
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

export const useStakingProps = (address?: string) => {
  const wallet = useWallet();

  const { data } = useSWR(
    address + "/stakingProps",
    async () => {
      if (!address || !wallet.address) return;

      const txb = new TransactionBlock();

      txb.moveCall({
        target: `${packageId}::staker_map_schema::get`,
        arguments: [txb.pure(world), txb.object(address)],
      });

      return suiClient
        .devInspectTransactionBlock({
          transactionBlock: txb,
          sender: wallet.address,
        })
        .then((res) => res);
    },
    { refreshInterval: 10_000 },
  );

  const values = data?.results?.[0].returnValues?.map((v) => {
    return u64ToString(v[0]);
  }) ?? [0, 0, 0, 0, 0, 0];

  return {
    fees: values[0],
    size: values[1],
    scissors_count: values[2],
    rock_count: values[3],
    paper_count: values[4],
    last_staker_balance_plus: values[5],
  };
};

export const useMint = () => {
  const wallet = useWallet();

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
      if (!wallet.address) return;

      const txb = new TransactionBlock();

      for (let i = 0; i < count; i++) {
        const [coin] = txb.splitCoins(txb.gas, [txb.pure(2n * MIST_PER_SUI)]);
        const [prop, coin_] = txb.moveCall({
          target: `${packageId}::pool_system::mint`,
          arguments: [txb.pure(type), coin, txb.object(world)],
        });
        txb.transferObjects([prop, coin_], txb.pure(wallet.address));
      }

      wallet.signAndExecuteTransactionBlock({
        transactionBlock: txb,
      });
    },
  );

  return {
    mint: trigger,
  };
};

export const useBurn = () => {
  const wallet = useWallet();

  const { trigger } = useSWRMutation(
    "burn",
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
      if (!wallet.address) return;

      const txb = new TransactionBlock();

      for (const propId of propIds) {
        const coin = txb.moveCall({
          target: `${packageId}::pool_system::burn`,
          arguments: [txb.object(propId), txb.object(pool), txb.object(world)],
        });
        txb.transferObjects([coin], txb.pure(wallet.address));
      }

      wallet.signAndExecuteTransactionBlock({
        transactionBlock: txb,
      });
    },
  );

  return {
    burn: trigger,
  };
};

export const useStake = () => {
  const wallet = useWallet();

  const { trigger } = useSWRMutation(
    "stake",
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
      if (!wallet.address) return;

      const txb = new TransactionBlock();

      const props = txb.makeMoveVec({
        objects: propIds.map((propId) => txb.object(propId)),
      });

      txb.moveCall({
        target: `${packageId}::pool_system::stake`,
        arguments: [
          props,
          txb.pure(wallet.address),
          txb.object(pool),
          txb.object(world),
        ],
      });

      wallet.signAndExecuteTransactionBlock({
        transactionBlock: txb,
      });
    },
  );

  return {
    stake: trigger,
  };
};
