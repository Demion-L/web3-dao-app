"use client";

import WalletConnect from "./WalletConnect";
import ThemeSwitcher from "./ThemeSwitcher";
import { Navigation } from "./ui/Navigation";

export default function Header() {
  return (
    <header className='card p-4 rounded-lg'>
      <div className='flex justify-between items-center'>
        <div className='flex flex-col gap-4'>
          <h1 className='text-2xl font-bold text-primary'>DAO Voting</h1>
          <p className='text-sm text-gray-500 dark:text-gray-400'>
            Decentralized Governance
          </p>
        </div>

        <div className='flex items-center gap-4'>
          <Navigation />
          <ThemeSwitcher />
          <WalletConnect className='px-4 py-2 rounded' />
        </div>
      </div>
    </header>
  );
}
