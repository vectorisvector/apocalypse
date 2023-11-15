"use client";

import Header from "@/components/Header";
import {
  createNetworkConfig,
  SuiClientProvider,
  WalletProvider,
} from "@mysten/dapp-kit";
import { getFullnodeUrl } from "@mysten/sui.js/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import Content from "./components/Content";

const { networkConfig } = createNetworkConfig({
  localnet: { url: getFullnodeUrl("localnet") },
  devnet: { url: getFullnodeUrl("devnet") },
  testnet: { url: getFullnodeUrl("testnet") },
  mainnet: { url: getFullnodeUrl("mainnet") },
});
const queryClient = new QueryClient();

export default function Home() {
  let [isClient, setIsClient] = useState(false);

  useEffect(() => {
    if (typeof window !== "undefined") {
      setIsClient(true);
    }
  }, []);

  return (
    isClient && (
      <QueryClientProvider client={queryClient}>
        <SuiClientProvider
          networks={networkConfig}
          defaultNetwork="devnet"
        >
          <WalletProvider autoConnect>
            <Header />

            <main className=" mx-auto flex max-w-7xl flex-col py-10">
              <Content />
            </main>
          </WalletProvider>
        </SuiClientProvider>
      </QueryClientProvider>
    )
  );
}
