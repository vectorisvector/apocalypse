import { useGlobalSchema, usePoolSchema } from "@/services";

export default function Pool() {
  const poolSchema = usePoolSchema();
  const globalSchema = useGlobalSchema();

  return (
    <div className=" flex flex-col gap-4">
      <h2 className=" text-3xl font-bold">Pool</h2>
      <div className=" stats flex w-full shadow">
        <div className="stat">
          <div className="stat-title">Rock</div>
          <div className="stat-value text-primary">
            {poolSchema?.rock_count ?? 0}
          </div>
          <div className="stat-desc text-sm">
            total rock {globalSchema?.rock_count ?? 0}
          </div>
        </div>

        <div className="stat">
          <div className="stat-title">Scissors</div>
          <div className="stat-value text-secondary">
            {poolSchema?.scissors_count ?? 0}
          </div>
          <div className="stat-desc text-sm">
            total scissors {globalSchema?.scissors_count ?? 0}
          </div>
        </div>

        <div className="stat">
          <div className="stat-title">Paper</div>
          <div className="stat-value text-accent">
            {poolSchema?.paper_count ?? 0}
          </div>
          <div className="stat-desc text-sm">
            total paper {globalSchema?.paper_count ?? 0}
          </div>
        </div>
      </div>
    </div>
  );
}
