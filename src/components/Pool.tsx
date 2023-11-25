import { usePoolSchema } from "@/services";
import { mistToSui } from "@/utils/helper";

export default function Pool() {
  const poolSchema = usePoolSchema();

  return (
    <div className=" flex flex-col gap-4">
      <h2 className=" text-3xl font-bold">Fee</h2>
      <div className=" stats flex w-full shadow">
        <div className="stat">
          <div className="stat-title">Total Balance</div>
          <div className="stat-value text-primary">
            {mistToSui(poolSchema?.balance ?? 0)}
          </div>
        </div>

        <div className="stat">
          <div className="stat-title">Staker Fee</div>
          <div className="stat-value text-secondary">
            {mistToSui(poolSchema?.staker_balance ?? 0)}
          </div>
        </div>

        <div className="stat">
          <div className="stat-title">Player Fee</div>
          <div className="stat-value text-accent">
            {mistToSui(poolSchema?.player_balance ?? 0)}
          </div>
        </div>
      </div>
    </div>
  );
}
