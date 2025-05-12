import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import WalletConnect from "../components/WalletConnect";
import ThemeSwitcher from "../components/ThemeSwitcher"; // we'll create this
import Link from "next/link";
import { Provider } from "react-redux";
import { store } from "../store/store";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Web3 DAO App",
  description: "Decentralized Autonomous Organization Voting DApp",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang='en'>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased bg-gray-100 text-gray-900`}>
        <Provider store={store}>
          <div className='flex flex-col min-h-screen'>
            {/* Header */}
            <header className='bg-white shadow-sm py-4 px-6 flex justify-between items-center'>
              <Link
                href='/'
                className='text-xl font-bold'>
                🗳️ DAO Voting
              </Link>
              <div className='flex items-center gap-4'>
                <ThemeSwitcher />
                <WalletConnect />
              </div>
            </header>

            {/* Page Content */}
            <main className='flex-1 p-4'>{children}</main>

            {/* Footer */}
            <footer className='bg-white text-center text-sm text-gray-500 py-4 border-t'>
              © {new Date().getFullYear()} DAO Voting App. Built with ❤️ on
              Web3.
            </footer>
          </div>
        </Provider>
      </body>
    </html>
  );
}
