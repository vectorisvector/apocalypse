import InputModal from "@/components/InputModal";
import { PropType } from "@/types/type";
import { truncateAddress } from "@/utils/helper";
import {
  useAccountProps,
  useBurn,
  useMint,
  useStake,
  useStakingProps,
  useUnstake,
} from "@/services";
import { useWallet } from "@suiet/wallet-kit";
import { useCallback, useMemo, useState } from "react";
import Play from "./Play";
import Props from "./Props";

export type actionType = "mint" | "burn" | "stake" | "unstake";

export default function Account() {
  const [isOpen, setIsOpen] = useState(false);
  const [maxCount, setMaxCount] = useState(100);
  const [type, setType] = useState<actionType>("mint");
  const [propType, setPropType] = useState<PropType>("rock");

  const wallet = useWallet();
  const props = useAccountProps(wallet.address);

  const stakerData = useStakingProps(wallet.address);

  const { mint } = useMint();
  const { burn } = useBurn();
  const { stake } = useStake();
  const { unstake } = useUnstake();

  const handleModal = useCallback(
    (type: actionType, propType: PropType, maxCount: number = 100) => {
      setMaxCount(maxCount);
      setType(type);
      setPropType(propType);
      setIsOpen(true);
    },
    [],
  );

  const propsRock = useMemo(() => {
    return props?.rock.length ?? 0;
  }, [props?.rock.length]);

  const propsScissors = useMemo(() => {
    return props?.scissors.length ?? 0;
  }, [props?.scissors.length]);

  const propsPaper = useMemo(() => {
    return props?.paper.length ?? 0;
  }, [props?.paper.length]);

  const stakingRock = useMemo(() => {
    return stakerData.props.filter((prop) => prop.type === "rock").length;
  }, [stakerData.props]);

  const stakingScissors = useMemo(() => {
    return stakerData.props.filter((prop) => prop.type === "scissors").length;
  }, [stakerData.props]);

  const stakingPaper = useMemo(() => {
    return stakerData.props.filter((prop) => prop.type === "paper").length;
  }, [stakerData.props]);

  const handleConfirm = useCallback(
    (count: number) => {
      if (type === "mint") {
        mint({
          type: propType,
          count,
        });
      } else if (type === "burn") {
        burn({
          propIds: props[propType].slice(0, count).map((prop) => prop.id),
        });
      } else if (type === "stake") {
        stake({
          propIds: props[propType].slice(0, count).map((prop) => prop.id),
        });
      } else if (type === "unstake") {
        unstake({
          propIds: stakerData.props
            .filter((prop) => prop.type === propType)
            .slice(0, count)
            .map((prop) => prop.id),
        });
      }
    },
    [burn, mint, propType, props, stake, stakerData.props, type, unstake],
  );

  return (
    <>
      <InputModal
        isOpen={isOpen}
        closeModal={() => setIsOpen(false)}
        maxCount={maxCount}
        onConfirm={handleConfirm}
      />

      {wallet.address && (
        <div className=" flex flex-col gap-4">
          <h2 className=" text-3xl font-bold">
            Account {truncateAddress(wallet.address)}
          </h2>
          <div className=" stats flex w-full shadow">
            <div className="stat relative">
              <div className="stat-title">Rock</div>

              <div className=" flex justify-between">
                <div className=" flex flex-col">
                  <div className="stat-value text-primary">{propsRock}</div>
                  <div className="stat-desc">hold</div>
                </div>

                <div className=" flex flex-col text-right">
                  <div className="stat-value text-primary">{stakingRock}</div>
                  <div className="stat-desc">staking</div>
                </div>
              </div>

              <Play
                type="rock"
                props={props.rock}
              />
            </div>

            <div className="stat relative">
              <div className="stat-title">Scissors</div>

              <div className=" flex justify-between">
                <div className=" flex flex-col">
                  <div className="stat-value text-secondary">
                    {propsScissors}
                  </div>
                  <div className="stat-desc">hold</div>
                </div>

                <div className=" flex flex-col text-right">
                  <div className="stat-value text-secondary">
                    {stakingScissors}
                  </div>
                  <div className="stat-desc">staking</div>
                </div>
              </div>

              <Play
                type="scissors"
                props={props.scissors}
              />
            </div>

            <div className="stat relative">
              <div className="stat-title">Paper</div>

              <div className=" flex justify-between">
                <div className=" flex flex-col">
                  <div className="stat-value text-accent">{propsPaper}</div>
                  <div className="stat-desc">hold</div>
                </div>

                <div className=" flex flex-col text-right">
                  <div className="stat-value text-accent">{stakingPaper}</div>
                  <div className="stat-desc">staking</div>
                </div>
              </div>

              <Play
                type="paper"
                props={props.paper}
              />
            </div>
          </div>

          {/* Props */}
          <Props handleModal={handleModal} />
        </div>
      )}
    </>
  );
}
