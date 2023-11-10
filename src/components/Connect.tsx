import { useState } from "react";
import { ConnectModal, useCurrentAccount } from "@mysten/dapp-kit";
import { obelisk } from "@/utils/oblisk";

export default function Connect() {
  const currentAccount = useCurrentAccount();
  const [open, setOpen] = useState(false);

  return (
    <ConnectModal
      trigger={
        <button disabled={!!currentAccount}>
          {" "}
          {currentAccount ? "Connected" : "Connect"}
        </button>
      }
      open={open}
      onOpenChange={(isOpen) => setOpen(isOpen)}
    />
  );
}
