"use client";

import WalletConnect from "./WalletConnect";
import ThemeSwitcher from "./ThemeSwitcher";
import { Navigation } from "./ui/Navigation";
import Link from "next/link";

export default function Header() {
  return (
    <header className='card w-4/5 xl:w-3/4 my-4 p-4 rounded-lg mx-auto'>
      <div className='flex justify-between items-center'>
        <div className='flex flex-col gap-4'>
          <Link
            href='/'
            className='text-2xl font-bold text-primary dark:text-shadow-neon cursor-pointer'>
            DAO Voting
          </Link>
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
