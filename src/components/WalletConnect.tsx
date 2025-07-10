"use client";

import { useWallet } from "@/hooks/useWallet";
import { WalletConnectProps } from "@/types/IWallet";
import { useEffect, useState } from "react";
import { formatAddress } from "@/utils/format";
import NeonButton from "@/components/ui/NeonButton";

export default function WalletConnect({ className }: WalletConnectProps) {
  const { account, connectWallet, disconnectWallet, isConnecting, error } =
    useWallet();
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  const handleConnect = async () => {
    try {
      await connectWallet();
    } catch (error) {
      console.error("Failed to connect wallet:", error);
    }
  };

  if (!isMounted) {
    return null;
  }

  return (
    <div className={className}>
      {/* Error Display */}
      {error && (
        <div className='mb-4 p-3 bg-red-500/10 border border-red-500/50 rounded-lg'>
          <p className='text-red-400 text-sm'>{error}</p>
        </div>
      )}

      {account ? (
        <div className='flex items-center gap-4'>
          <div className='flex items-center gap-2'>
            <div className='w-2 h-2 rounded-full bg-green-500 animate-pulse'></div>
            <span className='text-sm font-mono text-primary'>
              {formatAddress(account)}
            </span>
          </div>
          <NeonButton
            onClick={disconnectWallet}
            variant='danger'
            size='sm'
            disabled={isConnecting}>
            Disconnect
          </NeonButton>
        </div>
      ) : (
        <NeonButton
          onClick={handleConnect}
          variant='primary'
          disabled={isConnecting}>
          {isConnecting ? "Connecting..." : "Connect Wallet"}
        </NeonButton>
      )}
    </div>
  );
}
