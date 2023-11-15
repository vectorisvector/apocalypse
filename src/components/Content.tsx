import Pool from "./Pool";
import Account from "./Account";

export default function Content() {
  return (
    <div className=" flex flex-col gap-10">
      {/* Pool */}
      <Pool />

      {/* Account */}
      <Account />
    </div>
  );
}
