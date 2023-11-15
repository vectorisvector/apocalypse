import { Fragment } from "react";
import { Dialog, Transition } from "@headlessui/react";
import { useConnectWallet, useWallets } from "@mysten/dapp-kit";
import Image from "next/image";

interface ConnectModalProps {
  isOpen: boolean;
  closeModal: () => void;
}
export default function ConnectModal({
  isOpen,
  closeModal,
}: ConnectModalProps) {
  const wallets = useWallets();
  const { mutate: connect } = useConnectWallet({
    onSuccess: closeModal,
  });

  return (
    <Transition
      appear
      show={isOpen}
      as={Fragment}
    >
      <Dialog
        as="div"
        className="relative z-10"
        onClose={closeModal}
      >
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black/25" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4 text-center">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-300"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-200"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel className="w-80 transform overflow-hidden rounded-2xl bg-white p-2 text-left shadow-xl transition-all">
                <Dialog.Title
                  as="h3"
                  className=" text-center text-lg font-medium leading-10"
                >
                  Select Wallet
                </Dialog.Title>

                <ul className=" flex flex-col gap-2 py-4">
                  {wallets.map((wallet) => (
                    <li
                      key={wallet.name}
                      className=" flex h-12 cursor-pointer items-center gap-1 rounded-full px-4 transition-all hover:bg-base-100"
                      onClick={() =>
                        connect({
                          wallet,
                        })
                      }
                    >
                      <Image
                        src={wallet.icon}
                        alt={wallet.name}
                        width={20}
                        height={20}
                      />
                      <span>{wallet.name}</span>
                    </li>
                  ))}
                </ul>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
}
