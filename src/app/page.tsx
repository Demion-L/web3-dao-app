"use client";

import { useState } from "react";
import WalletConnect from "../components/WalletConnect";

export default function Home() {
  const [walletAddress, setWalletAddress] = useState<string | null>(null);

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
            onConnect={(address) => {
              setWalletAddress(address);
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
