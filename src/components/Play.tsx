import { PropType } from "@/types/type";
import { useAccountCards, useOldRound, useStartGame } from "@/utils/service";
import { useWallet } from "@suiet/wallet-kit";
import classNames from "classnames";
import { useCallback, useMemo, useState } from "react";
import InputModal from "./InputModal";

interface PlayProps {
  type: PropType;
  props: string[];
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

  const handleConfirm = useCallback(
    (count: number) => {
      startGame({
        propIds: props.slice(0, count),
        card: cards.length > 0 ? cards[0].id.id : undefined,
      });
    },
    [cards, props, startGame],
  );

  return (
    <>
      <InputModal
        isOpen={isOpen}
        closeModal={() => setIsOpen(false)}
        maxCount={props.length}
        onConfirm={handleConfirm}
      />

      <button
        className={classNames(" btn mt-6", map.class)}
        disabled={oldRound === "0"}
        onClick={() => setIsOpen(true)}
      >
        Play
      </button>
    </>
  );
}
