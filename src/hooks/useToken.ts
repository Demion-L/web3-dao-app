import { useState, useCallback, useEffect } from 'react';
import { ethers } from 'ethers';
import { useWalletContext } from "@/context/WalletContext";
import { getWalletInfo } from '@/utils/getWalletInfo';

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

            // Check if selfe delegated
            const isSelfDelegated = delegateeAddress.toLowerCase() === account.toLowerCase();


            // Get voting power - check both current and historical
            const currentBlock = await provider.getBlockNumber();
            let votes = ethers.ZeroAddress; // Default to zero address if no votes found

            // Try to get votes at current block
            try {
                votes = await token.getVotes(account, "latest");
            } catch (error) {
                console.warn("Failed to get latest votes, trying historical blocks: ", error);
            }

            // If no votes found at latest, try historical blocks
            if (votes.toString() === "0" && isSelfDelegated) {
                // Check up to 10 blocks back
                for (let i = 1; i <=10; i++) {
                    const checkBlock = currentBlock - i;
                    if (checkBlock < 0) break;

                    try {
                        const historicalVotes = await token.getVotes(account, checkBlock);
                        if (historicalVotes.toString() !== "0") {
                            votes = historicalVotes;
                            setDelegationStatus(`Voting power available from block ${checkBlock + 1}`);
                            break;
                    }
                } catch(error) {
                    console.warn(`Failed to get votes for block ${checkBlock}: ${error}`);
                }
            }
        } 
         // Update voting power
        const formattedVotes = ethers.formatEther(votes);
        setVotingPower(formattedVotes);

        // Set delegation status
        if (!isSelfDelegated) {
            setDelegationStatus('You have not delegated your voting power');
        } else if (votes.toString() === "0") {
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
    } catch (err: unknown) {
        console.error(`Delegation failed: ${err}`);
        setError(err instanceof Error ? err.message : String(err));
    } finally {
        setIsLoading(false);
    }
},[account, provider, getTokenData]);


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
    refreshTokenData

}
}