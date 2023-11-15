import { truncateAddress } from "@/utils/helper";
import { useAccountData, useGlobal, useMint, usePool } from "@/utils/swr";
import { useCurrentAccount } from "@mysten/dapp-kit";

export default function Content() {
  const account = useCurrentAccount();

  const pool = usePool();

  const global = useGlobal();

  const { mint } = useMint();

  const accountData = useAccountData(account?.address);

  return (
    <div className=" flex flex-col gap-10">
      {/* Pool */}
      <div className=" flex flex-col items-center gap-4">
        <h2 className=" text-3xl font-bold">Pool</h2>
        <div className=" stats flex w-full shadow">
          <div className="stat">
            <div className="stat-title">Rock</div>
            <div className="stat-value text-primary">
              {pool?.rock_count ?? 0}
            </div>
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
            <div className="stat-value text-accent">
              {pool?.paper_count ?? 0}
            </div>
            <div className="stat-desc text-sm">
              total paper {global?.paper_count ?? 0}
            </div>
          </div>
        </div>
      </div>

      {/* Account */}
      {account && (
        <div className=" flex flex-col items-center gap-4">
          <h2 className=" text-3xl font-bold">
            Account {truncateAddress(account.address)}
          </h2>
          <div className=" stats flex w-full shadow">
            <div
              className="stat cursor-pointer"
              onClick={() =>
                mint({
                  type: "rock",
                  count: 1,
                })
              }
            >
              <div className="stat-title">Rock</div>
              <div className="stat-value text-primary">
                {pool?.rock_count ?? 0}
              </div>
            </div>

            <div
              className="stat cursor-pointer"
              onClick={() =>
                mint({
                  type: "scissors",
                  count: 1,
                })
              }
            >
              <div className="stat-title">Scissors</div>
              <div className="stat-value text-secondary">
                {pool?.scissors_count ?? 0}
              </div>
            </div>

            <div
              className="stat cursor-pointer"
              onClick={() =>
                mint({
                  type: "paper",
                  count: 1,
                })
              }
            >
              <div className="stat-title">Paper</div>
              <div className="stat-value text-accent">
                {pool?.paper_count ?? 0}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
