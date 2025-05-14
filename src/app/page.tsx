"use client";

import { useSelector } from "react-redux";
import { RootState } from "@/store/store";
import { useEffect, useState } from "react";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

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
    <div className='min-h-screen flex flex-col'>
      <main className='flex-1 bg-gray-100 text-gray-900 p-6'>
        <div className='max-w-4xl mx-auto space-y-8'>
          <Header />

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
      <Footer />
    </div>
  );
}
