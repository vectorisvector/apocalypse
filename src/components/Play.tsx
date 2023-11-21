import { Prop, PropType } from "@/types/type";
import { useAccountCards, useOldRound, useStartGame } from "@/services";
import { useWallet } from "@suiet/wallet-kit";
import classNames from "classnames";
import { useCallback, useMemo, useState } from "react";
import InputModal from "./InputModal";
import { MIN_BALANCE } from "@/utils/const";
import BigNumber from "bignumber.js";

interface PlayProps {
  type: PropType;
  props: Prop[];
}
export default function Play({ type, props }: PlayProps) {
  const [isOpen, setIsOpen] = useState(false);

  const wallet = useWallet();
  const cards = useAccountCards(wallet.address);
  const oldRound = useOldRound();

  const { startGame } = useStartGame(Number(oldRound));

  const map = useMemo(() => {
    return {
      rock: {
        class: "btn-primary",
      },
      scissors: {
        class: "btn-secondary",
      },
      paper: {
        class: "btn-accent",
      },
    }[type];
  }, [type]);

  const activeProps = useMemo(() => {
    return props.filter((prop) => BigNumber(prop.balance).gt(MIN_BALANCE));
  }, [props]);

  const handleConfirm = useCallback(
    (count: number) => {
      startGame({
        propIds: activeProps.slice(0, count).map((prop) => prop.id),
        card: cards.length > 0 ? cards[0].id : undefined,
      });
    },
    [activeProps, cards, startGame],
  );

  return (
    <>
      <InputModal
        isOpen={isOpen}
        closeModal={() => setIsOpen(false)}
        maxCount={activeProps.length}
        onConfirm={handleConfirm}
      />

      <button
        className={classNames(" btn mt-6", map.class)}
        disabled={oldRound === "0" || activeProps.length === 0}
        onClick={() => setIsOpen(true)}
      >
        Play
      </button>
    </>
  );
}
