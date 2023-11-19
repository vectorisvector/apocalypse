import Pool from "./Pool";
import Account from "./Account";
import { useBeacon, useCountdown } from "@/utils/drand";

export default function Content() {
  const beacon = useBeacon();
  const countdown = useCountdown(beacon);

  return (
    <div className=" flex w-full max-w-5xl flex-1 flex-col gap-10">
      {/* Round */}
      <div className=" relative h-12 text-center font-bold">
        {beacon && (
          <span className=" absolute left-0 top-1/2 -translate-y-1/2 text-2xl">
            {beacon.round}
          </span>
        )}
        <span className=" text-5xl text-primary">{countdown}s</span>
      </div>

      {/* Pool */}
      <Pool />

      {/* Account */}
      <Account />
    </div>
  );
}
