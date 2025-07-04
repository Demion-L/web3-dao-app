"use client";

import { useWallet } from "@/hooks/useWallet";
import { WalletConnectProps } from "@/types/IWallet";
import { useEffect, useState } from "react";
import { formatAddress } from "@/utils/format";
import NeonButton from "@/components/ui/NeonButton";

export default function WalletConnect({ className }: WalletConnectProps) {
  const { account, connectWallet, disconnectWallet } = useWallet();
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
      {account ? (
        <div className='flex items-center gap-4'>
          <div className='flex items-center gap-2'>
            <div className='w-2 h-2 rounded-full bg-green-500'></div>
            <span className='text-sm font-mono text-primary'>
              {formatAddress(account)}
            </span>
          </div>
          <NeonButton
            onClick={disconnectWallet}
            variant='danger'
            size='sm'>
            Disconnect
          </NeonButton>
        </div>
      ) : (
        <NeonButton
          onClick={handleConnect}
          variant='primary'>
          Connect Wallet
        </NeonButton>
      )}
    </div>
  );
}
