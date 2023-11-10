"use client";

import Connect from "@/components/Connect";
import {
  createNetworkConfig,
  SuiClientProvider,
  WalletProvider,
} from "@mysten/dapp-kit";
import { getFullnodeUrl, type SuiClientOptions } from "@mysten/sui.js/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useEffect, useState } from "react";

// Config options for the networks you want to connect to
const { networkConfig } = createNetworkConfig({
  localnet: { url: getFullnodeUrl("localnet") },
  mainnet: { url: getFullnodeUrl("mainnet") },
});
const queryClient = new QueryClient();

export default function Home() {
  const [page, setPage] = useState<JSX.Element>();

  useEffect(() => {
    setPage(
      <QueryClientProvider client={queryClient}>
        <SuiClientProvider
          networks={networkConfig}
          defaultNetwork="localnet"
        >
          <WalletProvider>
            <header className=" flex h-20 items-center justify-between px-10">
              <div className=" text-center text-4xl">Apocalypse</div>
              <Connect />
            </header>

            <main>
              <div className=" mx-auto flex max-w-7xl flex-col py-10"></div>
            </main>
          </WalletProvider>
        </SuiClientProvider>
      </QueryClientProvider>,
    );
  }, []);

  return page ?? "";
}
