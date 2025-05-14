"use client";

import { useDispatch, useSelector } from "react-redux";
import dynamic from "next/dynamic";
import { connectWallet } from "@/store/features";
import { RootState } from "@/store/store";
import ThemeSwitcher from "./ThemeSwitcher";

const WalletConnect = dynamic(() => import("./WalletConnect"), {
  ssr: false,
});

export default function Header() {
  const dispatch = useDispatch();
  const walletAddress = useSelector((state: RootState) => state.wallet.account);

  return (
    <header>
      <h1 className='text-4xl font-bold mb-2'>🗳️ DAO Voting DApp</h1>
      <p className='text-lg text-gray-600'>Create proposals. Vote. Govern.</p>
      <p className='text-lg text-gray-600'>
        Connect your wallet to get started.
      </p>
      <div className='flex items-center gap-4 mt-4'>
        <ThemeSwitcher />
        <WalletConnect
          onConnect={(address: string) => {
            dispatch(connectWallet(address));
          }}
          onDisconnect={() => {
            dispatch(connectWallet(""));
          }}
          walletAddress={walletAddress}
        />
      </div>
    </header>
  );
}
