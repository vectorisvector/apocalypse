"use client";

import { useEffect, useState } from "react";
import { WalletProvider } from "@suiet/wallet-kit";
import Header from "@/components/Header";
import Content from "../components/Content";

export default function Home() {
  let [isClient, setIsClient] = useState(false);

  useEffect(() => {
    if (typeof window !== "undefined") {
      setIsClient(true);
    }
  }, []);

  return isClient ? (
    <WalletProvider autoConnect>
      <Header />

      <main className=" mx-auto flex max-w-7xl flex-col py-10">
        <Content />
      </main>
    </WalletProvider>
  ) : (
    <></>
  );
}
