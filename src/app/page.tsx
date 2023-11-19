"use client";

import { useEffect, useState } from "react";
import { WalletProvider } from "@suiet/wallet-kit";
import Header from "@/components/Header";
import Content from "../components/Content";
import PlayerProps from "@/components/PlayerProps";
import StakerProps from "@/components/StakerProps";

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

      <main className=" flex items-start justify-center gap-5 px-5 py-10">
        {/* StakerProps */}
        <StakerProps />

        {/* Content */}
        <Content />

        {/* PlayerProps */}
        <PlayerProps />
      </main>
    </WalletProvider>
  ) : (
    <></>
  );
}
