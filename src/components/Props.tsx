import { useAccountProps, useStakingProps } from "@/services";
import { Prop, PropType } from "@/types/type";
import { mistToSui, truncateAddress } from "@/utils/helper";
import { Tab } from "@headlessui/react";
import { useWallet } from "@suiet/wallet-kit";
import BigNumber from "bignumber.js";
import classNames from "classnames";
import { useMemo, useState } from "react";
import { actionType } from "./Account";
import { MIN_BALANCE } from "@/utils/const";

interface PropsProps {
  handleModal: (
    type: actionType,
    propType: PropType,
    maxCount?: number,
  ) => void;
}
export default function Props({ handleModal }: PropsProps) {
  const [type, setType] = useState<PropType>("rock");

  const wallet = useWallet();
  const props = useAccountProps(wallet.address);
  const stakerData = useStakingProps(wallet.address);

  const playerProps = useMemo(() => props[type], [props, type]);

  const stakingProps = useMemo(
    () => stakerData.props.filter((prop) => prop.type === type),
    [stakerData.props, type],
  );

  return (
    <div className=" flex flex-col gap-5">
      <Tab.Group>
        <Tab.List className=" tabs w-fit">
          {(Object.keys(props) as PropType[]).map((type) => (
            <Tab
              key={type}
              className={({ selected }) =>
                classNames(
                  "tab h-10 rounded-full px-10 text-base transition-all",
                  selected && type === "rock" ? " tab-active bg-primary" : "",
                  selected && type === "scissors"
                    ? " tab-active bg-secondary"
                    : "",
                  selected && type === "paper" ? " tab-active bg-accent" : "",
                )
              }
              onClick={() => setType(type)}
            >
              {type} ({props[type].length})
            </Tab>
          ))}
        </Tab.List>

        <div className=" flex items-center justify-between">
          <div className=" flex items-center gap-4">
            <button
              className={classNames(
                " btn btn-sm",
                type === "rock" ? " btn-primary" : "",
                type === "scissors" ? " btn-secondary" : "",
                type === "paper" ? " btn-accent" : "",
              )}
              onClick={() => handleModal("mint", "rock")}
            >
              mint
            </button>
            <button
              className={classNames(
                " btn btn-sm",
                type === "rock" ? " btn-primary" : "",
                type === "scissors" ? " btn-secondary" : "",
                type === "paper" ? " btn-accent" : "",
              )}
              disabled={playerProps.length === 0}
              onClick={() =>
                handleModal(
                  "stake",
                  "rock",
                  playerProps.length > 100 ? 100 : playerProps.length,
                )
              }
            >
              stake
            </button>
            <button
              className=" btn btn-error btn-sm"
              disabled={playerProps.length === 0}
              onClick={() =>
                handleModal(
                  "burn",
                  "rock",
                  playerProps.length > 100 ? 100 : playerProps.length,
                )
              }
            >
              burn
            </button>
            <button
              className=" btn btn-error btn-sm"
              disabled={stakingProps.length === 0}
              onClick={() =>
                handleModal(
                  "unstake",
                  "rock",
                  stakingProps.length > 100 ? 100 : stakingProps.length,
                )
              }
            >
              unstake
            </button>
          </div>

          <button
            className=" btn btn-error btn-sm"
            disabled={
              playerProps.filter((prop) =>
                BigNumber(prop.balance).lte(MIN_BALANCE),
              ).length === 0
            }
          >
            clear insufficient balance
          </button>
        </div>

        <Tab.Panels>
          {(Object.values(props) as Prop[][]).map((values, idx) => (
            <Tab.Panel
              key={idx}
              className="rounded-xl bg-white p-3"
            >
              {values.map((prop) => (
                <div
                  key={prop.id}
                  className={classNames(
                    "card w-40 bg-base-100 shadow-xl transition-all hover:shadow-2xl",
                    prop.type === "rock" ? " bg-primary" : "",
                    prop.type === "scissors" ? " bg-secondary" : "",
                    prop.type === "paper" ? " bg-accent" : "",
                  )}
                >
                  <div className="card-body items-center">
                    <h2 className="card-title capitalize">{prop.type}</h2>
                    <div>{truncateAddress(prop.id)}</div>
                    <div>{mistToSui(prop.balance)} SUI</div>
                  </div>
                </div>
              ))}

              {values.length === 0 && (
                <div className=" flex flex-col items-center gap-2">
                  <h2 className="text-2xl font-bold">No Props</h2>
                  <p className="text-center">You have no props yet</p>
                </div>
              )}
            </Tab.Panel>
          ))}
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
}
