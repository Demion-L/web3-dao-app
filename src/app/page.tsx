"use client";

import { useSelector } from "react-redux";
import { RootState } from "@/store/store";
import { useEffect, useState } from "react";

export default function Home() {
  const walletAddress = useSelector((state: RootState) => state.wallet.account);
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  if (!isMounted) {
    return null;
  }

  return (
    <div className='min-h-screen flex flex-col bg-background-primary'>
      <main className='flex-1 p-6'>
        <div className='max-w-4xl mx-auto space-y-8'>
          {walletAddress && (
            <section className='card p-6 rounded-lg'>
              <h2 className='text-2xl font-semibold mb-4 text-primary'>
                Proposals
              </h2>
              <p className='text-secondary'>
                You are connected as{" "}
                <span className='font-mono text-primary'>{walletAddress}</span>
              </p>

              {/* Next: list of proposals will go here */}
              <div className='mt-4 border-t border-theme pt-4'>
                <p className='text-secondary'>No proposals yet.</p>
              </div>
            </section>
          )}
        </div>
      </main>
    </div>
  );
}
