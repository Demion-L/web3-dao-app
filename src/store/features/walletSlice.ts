import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import { WalletState } from '../../types/wallet';
import { getEthBalance } from '../../utils/ethereum';

const initialState: WalletState = {
  account: null,
  isConnected: false,
  balance:null,
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
    connectWallet: (state, action: PayloadAction<string>) => {
      state.account = action.payload;
      state.isConnected = true;
    },
    disconnectWallet: (state) => {
      state.account = null;
      state.isConnected = false;
    },
  },
   extraReducers: (builder) => {
    builder.addCase(fetchBalance.fulfilled, (state, action) => {
      state.balance = action.payload;
    });
  },
});

export const { connectWallet, disconnectWallet } = walletSlice.actions;
export default walletSlice.reducer; 