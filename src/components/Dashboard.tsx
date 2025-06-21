"use client";

import { useSelector } from "react-redux";
import { RootState } from "@/store/store";
import { useEffect, useState } from "react";
import { useToken } from "@/hooks/useToken";
import NeonButton from "@/components/ui/NeonButton";

export default function Dashboard() {
  const walletAddress = useSelector((state: RootState) => state.wallet.account);
  const [isMounted, setIsMounted] = useState(false);
  const { balance, isLoading: isTokenLoading, getBalance } = useToken();

  useEffect(() => {
    setIsMounted(true);
  }, []);

  useEffect(() => {
    if (walletAddress) {
      getBalance();
    }
  }, [walletAddress, getBalance]);

  if (!isMounted) {
    return null;
  }

  return (
    <div className='flex max-w-7xl w-5/6 flex-col gap-6 dark:bg-stone-800 bg-white/90 shadow-black shadow-2xl rounded-lg p-6'>
      <div>
        <h2 className='text-2xl font-extrabold text-white rounded-lg mb-4  dark:text-shadow-neon bg-black/90 text-center py-2'>
          DAO Dashboard
        </h2>
        <p className='dark:text-cyan-300 text-cyan-800 text-center text-xl bg-slate-700/30 p-2 rounded-lg'>
          Welcome to the future of governance!
        </p>
      </div>
      {walletAddress ? (
        <>
          <div className='space-y-4'>
            <div className='flex items-center justify-between'>
              <span className='text-secondary'>Connected as:</span>
              <span className='font-mono text-primary text-neon-cyan'>
                {walletAddress}
              </span>
            </div>
            <div className='flex items-center justify-between'>
              <span className='text-secondary'>Token Balance:</span>
              <span className='font-mono text-primary text-neon-pink'>
                {isTokenLoading ? "Loading..." : `${balance} TOKENS`}
              </span>
            </div>
          </div>
          <NeonButton
            onClick={() => {
              /* open proposal modal */
            }}>
            Create Proposal
          </NeonButton>
        </>
      ) : (
        <div className='text-center py-8'>
          <p className='text-secondary text-lg'>
            Please connect your wallet to continue.
          </p>
        </div>
      )}
    </div>
  );
}
