"use client";

import { useState } from "react";
import { mistToSui, truncateAddress } from "@/utils/helper";
import ConnectModal from "./ConnectModal";
import { useWallet } from "@suiet/wallet-kit";
import { useBalance } from "@/utils/service";
export default function Connect() {
  const [showModal, setShowModal] = useState(false);

  const wallet = useWallet();

  const balance = useBalance(wallet.address);

  return (
    <>
      <ConnectModal
        isOpen={showModal}
        closeModal={() => setShowModal(false)}
      />

      {wallet.address ? (
        <div className=" flex items-center gap-4">
          <span className=" font-bold uppercase text-primary">
            {mistToSui(balance?.totalBalance ?? 0)} sui
          </span>

          <div className="dropdown dropdown-end dropdown-hover">
            <label
              tabIndex={0}
              className="btn btn-neutral"
            >
              {truncateAddress(wallet.address)}{" "}
            </label>
            <ul
              tabIndex={0}
              className="menu dropdown-content rounded-box z-[1] w-40 bg-base-100 p-2 shadow"
            >
              <li onClick={() => wallet.disconnect()}>
                <a>disconnect</a>
              </li>
            </ul>
          </div>
        </div>
      ) : (
        <button
          className="btn btn-primary"
          onClick={() => setShowModal(true)}
        >
          Connect
        </button>
      )}
    </>
  );
}
