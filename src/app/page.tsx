"use client";

import { useSelector } from "react-redux";
import { RootState } from "@/store/store";
import { useEffect, useState } from "react";
import { useToken } from "@/hooks/useToken";

export default function Home() {
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
    <div className='min-h-screen flex flex-col bg-background-primary'>
      <main className='flex-1 p-6'>
        <div className='max-w-4xl mx-auto space-y-8'>
          {!walletAddress ? (
            <section className='card p-6 rounded-lg'>
              <h2 className='text-2xl font-semibold mb-4 text-primary'>
                To interact with the DAO, please connect your wallet first!
              </h2>
            </section>
          ) : (
            <section className='card p-6 rounded-lg'>
              <h2 className='text-2xl font-semibold mb-4 text-primary'>
                Your DAO Dashboard
              </h2>
              <div className='space-y-4'>
                <div className='flex items-center justify-between'>
                  <p className='text-secondary'>Connected as:</p>
                  <span className='font-mono text-primary'>
                    {walletAddress}
                  </span>
                </div>
                <div className='flex items-center justify-between'>
                  <p className='text-secondary'>Token Balance:</p>
                  <span className='font-mono text-primary'>
                    {isTokenLoading ? "Loading..." : `${balance} TOKENS`}
                  </span>
                </div>
              </div>

              <div className='mt-8 border-t border-theme pt-4'>
                <h3 className='text-xl font-semibold mb-4 text-primary'>
                  Active Proposals
                </h3>
                <p className='text-secondary'>No proposals yet.</p>
              </div>
            </section>
          )}
        </div>
      </main>
    </div>
  );
}
