import { usePool } from "@/services";
import { PropType } from "@/types/type";
import { mistToSui, truncateAddress } from "@/utils/helper";
import classNames from "classnames";

export default function PlayerProps() {
  const pool = usePool();

  const getTypeCount = (type: PropType) => {
    if (!pool) return 0;
    return pool.gaming_props.filter((prop) => prop.type === type).length;
  };

  return (
    <div className=" left-5 top-10 w-80 rounded-lg border p-4">
      <h2 className=" text-xl font-bold">Player Props</h2>

      <div className=" mt-4 flex h-6 items-center gap-4">
        <span className=" text-primary">Rock: {getTypeCount("rock")}</span>
        <span className=" text-secondary">
          Scissors: {getTypeCount("scissors")}
        </span>
        <span className=" text-accent">Paper: {getTypeCount("paper")}</span>
      </div>

      <div className=" mt-4 flex h-6 items-center gap-2">
        <span className=" w-36">id</span>
        <span className=" flex-1">balance</span>
        <span>type</span>
      </div>

      {pool && (
        <div className=" mt-4 flex max-h-[600px] flex-col gap-4 overflow-auto">
          {pool.gaming_props.map((prop) => (
            <div
              key={prop.id}
              className=" flex h-6 items-center gap-2"
            >
              <span className=" w-36">{truncateAddress(prop.id)}</span>
              <span className=" flex-1">{mistToSui(prop.balance)}</span>
              <span
                className={classNames(
                  prop.type === "rock" ? " text-primary" : "",
                  prop.type === "scissors" ? " text-secondary" : "",
                  prop.type === "paper" ? " text-accent" : "",
                )}
              >
                {prop.type}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
