"use client";

import { useDispatch, useSelector } from "react-redux";
import dynamic from "next/dynamic";
import { connectWallet } from "@/store/features";
import { RootState } from "@/store/store";
import { useEffect, useState } from "react";

const WalletConnect = dynamic(() => import("../components/WalletConnect"), {
  ssr: false,
});

export default function Home() {
  const dispatch = useDispatch();
  const walletAddress = useSelector((state: RootState) => state.wallet.account);
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  if (!isMounted) {
    return null;
  }

  return (
    <main className='min-h-screen bg-gray-100 text-gray-900 p-6'>
      <div className='max-w-4xl mx-auto space-y-8'>
        <header>
          <h1 className='text-4xl font-bold mb-2'>🗳️ DAO Voting DApp</h1>
          <p className='text-lg text-gray-600'>
            Create proposals. Vote. Govern.
          </p>
        </header>

        <section className='bg-white shadow p-6 rounded-lg'>
          <WalletConnect
            onConnect={(address: string) => {
              dispatch(connectWallet(address));
            }}
          />
        </section>

        {walletAddress && (
          <section className='bg-white shadow p-6 rounded-lg'>
            <h2 className='text-2xl font-semibold mb-4'>Proposals</h2>
            <p className='text-gray-600'>
              You are connected as{" "}
              <span className='font-mono'>{walletAddress}</span>
            </p>

            {/* Next: list of proposals will go here */}
            <div className='mt-4 border-t pt-4'>
              <p>No proposals yet.</p>
            </div>
          </section>
        )}
      </div>
    </main>
  );
}
