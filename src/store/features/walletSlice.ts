import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import { Provider, Signer } from 'ethers';
import { getEthBalance } from '../../utils/ethereum';
import { WalletState } from '@/types/Iwallet';

const initialState: WalletState = {
  account: null,
  provider: null,
  signer: null,
  isConnected: false,
  balance: null,
};

export const fetchBalance = createAsyncThunk(
  'wallet/fetchBalance',
  async (account: string) => {
    const balance = await getEthBalance(account);
    return balance;
  }
);

const walletSlice = createSlice({
  name: 'wallet',
  initialState,
  reducers: {
    connectWallet: (state, action: PayloadAction<{ account: string; provider: Provider; signer: Signer }>) => {
      state.account = action.payload.account;
      state.provider = action.payload.provider;
      state.signer = action.payload.signer;
      state.isConnected = true;
    },
    disconnectWallet: (state) => {
      state.account = null;
      state.provider = null;
      state.signer = null;
      state.isConnected = false;
      state.balance = null;
    },
    setAccount: (state, action: PayloadAction<string | null>) => {
      state.account = action.payload;
      state.isConnected = !!action.payload;
    },
    setProvider: (state, action: PayloadAction<Provider | null>) => {
      state.provider = action.payload;
    },
    setSigner: (state, action: PayloadAction<Signer | null>) => {
      state.signer = action.payload;
    },
  },
  extraReducers: (builder) => {
    builder.addCase(fetchBalance.fulfilled, (state, action) => {
      state.balance = action.payload;
    });
  },
});

export const { connectWallet, disconnectWallet, setAccount, setProvider, setSigner } = walletSlice.actions;
export default walletSlice.reducer; 