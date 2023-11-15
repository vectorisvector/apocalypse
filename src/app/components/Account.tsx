import InputModal from "@/components/InputModal";
import { PropType } from "@/types/type";
import { truncateAddress } from "@/utils/helper";
import { useAccountProps, useBurn, useMint } from "@/utils/swr";
import { useCurrentAccount } from "@mysten/dapp-kit";
import { useCallback, useMemo, useState } from "react";

export default function Account() {
  const [isOpen, setIsOpen] = useState(false);
  const [maxCount, setMaxCount] = useState(100);
  const [type, setType] = useState<"mint" | "burn" | "staking">("mint");
  const [propType, setPropType] = useState<PropType>("rock");

  const account = useCurrentAccount();
  const props = useAccountProps(account?.address);

  const { mint } = useMint();
  const { burn } = useBurn();

  const handleModal = useCallback(
    (
      type: "mint" | "burn" | "staking",
      propType: PropType,
      maxCount: number = 100,
    ) => {
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
    return props?.rock.length ?? 0;
  }, [props?.rock.length]);

  const stakingScissors = useMemo(() => {
    return props?.scissors.length ?? 0;
  }, [props?.scissors.length]);

  const stakingPaper = useMemo(() => {
    return props?.paper.length ?? 0;
  }, [props?.paper.length]);

  const handleConfirm = useCallback(
    (count: number) => {
      if (type === "mint") {
        mint({
          type: propType,
          count,
        });
      } else if (type === "burn") {
        burn({
          propIds: props[propType].slice(0, count),
        });
      }
    },
    [burn, mint, propType, props, type],
  );

  return (
    <>
      <InputModal
        isOpen={isOpen}
        closeModal={() => setIsOpen(false)}
        maxCount={maxCount}
        onConfirm={handleConfirm}
      />

      {account && (
        <div className=" flex flex-col items-center gap-4">
          <h2 className=" text-3xl font-bold">
            Account {truncateAddress(account.address)}
          </h2>
          <div className=" stats flex w-full shadow">
            <div className="stat relative">
              <div className="stat-title">Rock</div>

              <div className=" flex justify-between">
                <div className=" flex flex-col">
                  <div className="stat-value text-primary">{propsRock}</div>
                  <div className="stat-desc">hold</div>
                  <div className=" mt-2 flex items-center gap-4">
                    <button
                      className=" btn btn-primary btn-sm"
                      onClick={() => handleModal("mint", "rock")}
                    >
                      mint
                    </button>
                    <button
                      className=" btn btn-error btn-sm"
                      disabled={propsRock === 0}
                      onClick={() =>
                        handleModal(
                          "burn",
                          "rock",
                          propsRock > 100 ? 100 : propsRock,
                        )
                      }
                    >
                      burn
                    </button>
                  </div>
                </div>

                <div className=" flex flex-col text-right">
                  <div className="stat-value text-primary">{stakingRock}</div>
                  <div className="stat-desc">staking</div>
                  <button className=" btn btn-primary btn-sm mt-2">
                    stake
                  </button>
                </div>
              </div>
            </div>

            <div className="stat relative">
              <div className="stat-title">Scissors</div>

              <div className=" flex justify-between">
                <div className=" flex flex-col">
                  <div className="stat-value text-secondary">
                    {propsScissors}
                  </div>
                  <div className="stat-desc">hold</div>
                  <div className=" mt-2 flex items-center gap-4">
                    <button
                      className=" btn btn-secondary btn-sm"
                      onClick={() => handleModal("mint", "scissors")}
                    >
                      mint
                    </button>
                    <button
                      className=" btn btn-error btn-sm"
                      disabled={propsScissors === 0}
                      onClick={() =>
                        handleModal(
                          "burn",
                          "scissors",
                          propsScissors > 100 ? 100 : propsScissors,
                        )
                      }
                    >
                      burn
                    </button>
                  </div>
                </div>

                <div className=" flex flex-col text-right">
                  <div className="stat-value text-secondary">
                    {stakingScissors}
                  </div>
                  <div className="stat-desc">staking</div>
                  <button className=" btn btn-secondary btn-sm mt-2">
                    stake
                  </button>
                </div>
              </div>
            </div>

            <div className="stat relative">
              <div className="stat-title">Paper</div>

              <div className=" flex justify-between">
                <div className=" flex flex-col">
                  <div className="stat-value text-accent">{propsPaper}</div>
                  <div className="stat-desc">hold</div>
                  <div className=" mt-2 flex items-center gap-4">
                    <button
                      className=" btn btn-accent btn-sm"
                      onClick={() => handleModal("mint", "paper")}
                    >
                      mint
                    </button>
                    <button
                      className=" btn btn-error btn-sm"
                      disabled={propsPaper === 0}
                      onClick={() =>
                        handleModal(
                          "burn",
                          "paper",
                          propsPaper > 100 ? 100 : propsPaper,
                        )
                      }
                    >
                      burn
                    </button>
                  </div>
                </div>

                <div className=" flex flex-col text-right">
                  <div className="stat-value text-accent">{stakingPaper}</div>
                  <div className="stat-desc">staking</div>
                  <button className=" btn btn-accent btn-sm mt-2">stake</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
