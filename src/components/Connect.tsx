"use client";

import { useState } from "react";
import { truncateAddress } from "@/utils/helper";
import { useCurrentAccount, useDisconnectWallet } from "@mysten/dapp-kit";

import ConnectModal from "./ConnectModal";

export default function Connect() {
  const [showModal, setShowModal] = useState(false);

  const account = useCurrentAccount();
  const { mutate: disconnect } = useDisconnectWallet();

  return (
    <>
      <ConnectModal
        isOpen={showModal}
        closeModal={() => setShowModal(false)}
      />

      {account ? (
        <div className="dropdown dropdown-end dropdown-hover">
          <label
            tabIndex={0}
            className="btn btn-neutral"
          >
            {truncateAddress(account.address)}
          </label>
          <ul
            tabIndex={0}
            className="menu dropdown-content rounded-box z-[1] w-40 bg-base-100 p-2 shadow"
          >
            <li onClick={() => disconnect()}>
              <a>disconnect</a>
            </li>
          </ul>
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
