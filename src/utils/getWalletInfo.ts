import { ethers } from "ethers";

export async function getWalletInfo() {
  if (!window.ethereum) throw new Error("No crypto wallet found");
  const provider = new ethers.BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();
  const address = await signer.getAddress();
  return { provider, signer, address };
} 