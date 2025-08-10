import { useState, useCallback, useEffect } from 'react';
import { ethers } from 'ethers';
import { useWalletContext } from "@/context/WalletContext";
import { getWalletInfo } from '@/utils/getWalletInfo';
import { getCurrentblockNumberAndVotingPower } from '@/utils/tokenHelpers';

export const useToken = () => {
    const { account, provider } = useWalletContext();
    const  [balance, setBalance] = useState<string>('0');
    const [votingPower, setVotingPower] = useState<string>('0');
    const [isLoading, setIsLoading] = useState<boolean>(false);
    const [error, setError] = useState<string | null>(null);
    const [delegationStatus, setDelegationStatus] = useState<string>('');
    const [delegatee, setDelegatee] = useState<string>('');


    const getTokenData = useCallback(async () => {
        if (!account || !provider) return;
        try {
            setIsLoading(true);
            setError(null);
            const {
                getContract, 
                TOKEN_ABI, 
                CONTRACT_ADDRESSES
            } = await import('@/config/contracts');
            const token = getContract(
                CONTRACT_ADDRESSES.token, 
                TOKEN_ABI, provider
            );
            // Get balance
            const balanceResult = await token.balanceOf(account);
            const formattedBalance = ethers.formatEther(balanceResult);
            setBalance(formattedBalance);
            // Get delegatee
            const delegateeAddress = await token.delegates(account);
            setDelegatee(delegateeAddress);
            // Check if self delegated
            const isSelfDelegated = delegateeAddress.toLowerCase() === account.toLowerCase();
            // Get voting power and block number using utility
            const { votingPower } = await getCurrentblockNumberAndVotingPower(token, account, provider);
            setVotingPower(votingPower);
            // Set delegation status
            if (!isSelfDelegated) {
                setDelegationStatus('You have not delegated your voting power');
            } else if (votingPower === "0") {
                setDelegationStatus('Delegated but voting power not yet available');
            } else {
                setDelegationStatus('You have delegated your voting power');
            }
        } catch (err: unknown) {
            console.error(`Error fetching token data:  ${err}`);
            setError( err instanceof Error ? err.message : String(err));
        } finally {
            setIsLoading(false);
        }
    }, [account, provider]);

    useEffect(() => {
        if (account && provider) {
            getTokenData();
        }
    }, [account, provider, getTokenData]);

    // Add refreshVotingPower function
    const refreshVotingPower = useCallback(async () => {
        if (!account || !provider) return;
        try {
            const {
                getContract, 
                TOKEN_ABI, 
                CONTRACT_ADDRESSES
            } = await import('@/config/contracts');
            const token = getContract(
                CONTRACT_ADDRESSES.token, 
                TOKEN_ABI, provider
            );
            const { votingPower } = await getCurrentblockNumberAndVotingPower(token, account, provider);
            setVotingPower(votingPower);
        } catch (err) {
            console.error('Error refreshing voting power:', err);
        }
    }, [account, provider]);

const delegate = useCallback( async (to: string) => {
    if (!account || ! provider) return;

    try {
        setIsLoading(true);
        setError(null);
        setDelegationStatus('Delegating tokens...');

        const {getContract, TOKEN_ABI, CONTRACT_ADDRESSES
} = await import('@/config/contracts');

        const { signer } = await getWalletInfo();
        const token = getContract(CONTRACT_ADDRESSES
.token, TOKEN_ABI, signer);

        // Delegate tokens
        const tx = await token.delegate(to);
        setDelegationStatus('Waiting for transaction confirmation...');

        await tx.wait();
        setDelegationStatus('Delegation confirmed! Waiting for voting power...');

        // Wait for 3 blocks to ensure voting power is updated
        const currentBlock = await provider.getBlockNumber();
        const targetBlock = currentBlock + 3;

        // Poll for voting power update
        const pollBlocks = async () => {
            const latestBlock = await provider.getBlockNumber();
            if (latestBlock >= targetBlock) {
                // Refresh data after blocks are confirmed
                await getTokenData();
                return;
            }

            setDelegationStatus(`Waiting for block ${targetBlock} (current: ${latestBlock})`);
            setTimeout(pollBlocks, 3000);
        }

        await pollBlocks();
        await refreshVotingPower();
    } catch (err: unknown) {
        console.error(`Delegation failed: ${err}`);
        setError(err instanceof Error ? err.message : String(err));
    } finally {
        setIsLoading(false);
    }
},[account, provider, getTokenData, refreshVotingPower]);


// Self-delegate function
const delegateToSelf = useCallback( async () => {
    if (account) {
        return delegate(account);
    }
}, [ account, delegate ]);

// Refresh token data manually
const refreshTokenData = useCallback(() => {
    getTokenData();
}, [getTokenData]);

return {
    balance,
    votingPower,
    isLoading,
    error,
    delegationStatus,
    delegatee,
    getTokenData,
    delegate,
    delegateToSelf,
    refreshTokenData,
    refreshVotingPower
}
}