import { Transition, Dialog } from "@headlessui/react";
import classNames from "classnames";
import { Fragment, useCallback, useMemo, useState } from "react";

interface InputModalProps {
  isOpen: boolean;
  closeModal: () => void;
  maxCount: number;
  onConfirm: (count: number) => void;
}
export default function InputModal({
  isOpen,
  closeModal,
  maxCount = 100,
  onConfirm,
}: InputModalProps) {
  const [count, setCount] = useState(0);

  const isError = useMemo(() => {
    return maxCount >= 0 && count > maxCount;
  }, [count, maxCount]);

  const confirm = useCallback(() => {
    onConfirm(count);
    closeModal();
  }, [closeModal, count, onConfirm]);

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
              <Dialog.Panel className="w-80 transform overflow-hidden rounded-2xl bg-base-100 p-4 text-left shadow-xl transition-all">
                <Dialog.Title
                  as="h3"
                  className=" text-center text-lg font-medium leading-10"
                >
                  Input Count
                </Dialog.Title>

                <div className=" mt-4 flex flex-col items-center gap-4">
                  <input
                    type="number"
                    placeholder="Input Count"
                    className={classNames(
                      " input input-bordered w-full",
                      isError ? " input-error" : "",
                    )}
                    onChange={(e) => setCount(Number(e.target.value))}
                    onKeyDown={(e) =>
                      !(isError || count <= 0) && e.key === "Enter" && confirm()
                    }
                  />

                  <button
                    className=" btn btn-primary w-full"
                    disabled={isError || count <= 0}
                    onClick={confirm}
                  >
                    Confirm
                  </button>
                </div>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
}
