import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import { getEthBalance } from '../../utils/ethereum';
import { WalletState } from '@/types/IWallet';

const initialState: WalletState = {
  account: null,
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
    connectWallet: (state, action: PayloadAction<{ account: string }>) => {
      state.account = action.payload.account;
      state.isConnected = true;
    },
    disconnectWallet: (state) => {
      state.account = null;
      state.isConnected = false;
      state.balance = null;
    },
    setAccount: (state, action: PayloadAction<string | null>) => {
      state.account = action.payload;
      state.isConnected = !!action.payload;
    },
  },
  extraReducers: (builder) => {
    builder.addCase(fetchBalance.fulfilled, (state, action) => {
      state.balance = action.payload;
    });
  },
});

export const { connectWallet, disconnectWallet, setAccount } = walletSlice.actions;
export default walletSlice.reducer; 