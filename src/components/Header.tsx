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
    <header className='border-b border-gray-200 pb-4'>
      <div className='flex items-center justify-between'>
        <div>
          <h1 className='text-2xl font-bold'>🗳️ DAO Voting DApp</h1>
          <p className='text-sm text-gray-600'>
            Create proposals. Vote. Govern.
          </p>
        </div>
        <div className='flex items-center gap-4'>
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
      </div>
    </header>
  );
}
