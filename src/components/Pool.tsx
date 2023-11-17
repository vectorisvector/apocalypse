import { useGlobal, usePool } from "@/utils/service";

export default function Pool() {
  const pool = usePool();
  const global = useGlobal();

  return (
    <div className=" flex flex-col gap-4">
      <h2 className=" text-3xl font-bold">Pool</h2>
      <div className=" stats flex w-full shadow">
        <div className="stat">
          <div className="stat-title">Rock</div>
          <div className="stat-value text-primary">{pool?.rock_count ?? 0}</div>
          <div className="stat-desc text-sm">
            total rock {global?.rock_count ?? 0}
          </div>
        </div>

        <div className="stat">
          <div className="stat-title">Scissors</div>
          <div className="stat-value text-secondary">
            {pool?.scissors_count ?? 0}
          </div>
          <div className="stat-desc text-sm">
            total scissors {global?.scissors_count ?? 0}
          </div>
        </div>

        <div className="stat">
          <div className="stat-title">Paper</div>
          <div className="stat-value text-accent">{pool?.paper_count ?? 0}</div>
          <div className="stat-desc text-sm">
            total paper {global?.paper_count ?? 0}
          </div>
        </div>
      </div>
    </div>
  );
}
