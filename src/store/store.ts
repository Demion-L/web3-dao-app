import { configureStore } from '@reduxjs/toolkit';
import { walletReducer } from '@/store/features';

export const store = configureStore({
  reducer: {
    wallet: walletReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch; 