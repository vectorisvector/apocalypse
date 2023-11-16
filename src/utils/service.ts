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
import { MIST_PER_SUI } from "@mysten/sui.js/utils";
import { bcs } from "@mysten/sui.js/bcs";

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

  if (data?.error) {
    return {
      fees: "0",
      size: "0",
      last_staker_balance_plus: "0",
      props: [],
    };
  }

  const values = data?.results?.[0].returnValues?.map((v) => {
    const res = bcs.de(v[1], Uint8Array.from(v[0]));
    if (v[1] === "vector<vector<u8>>") {
      return (res as number[][]).map((r) => {
        return r.map((num) => String.fromCharCode(num)).join("");
      });
    }
    if (v[1] === "vector<address>") {
      return (res as string[]).map((r) => "0x" + r);
    }
    return res;
  }) ?? ["0", "0", "0", [], []];

  return {
    fees: values[0] as string,
    size: values[1] as string,
    last_staker_balance_plus: values[2] as string,
    props: values[3].map((propId: string, i: number) => {
      return {
        id: propId,
        type: values[4][i],
      };
    }) as { id: string; type: PropType }[],
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

export const useUnstake = () => {
  const wallet = useWallet();

  const { trigger } = useSWRMutation(
    "unstake",
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

      txb.moveCall({
        target: `${packageId}::pool_system::unstake`,
        arguments: [
          txb.pure(propIds, "vector<address>"),
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
    unstake: trigger,
  };
};
