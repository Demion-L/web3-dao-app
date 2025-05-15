"use client";

import { ThemeProvider } from "next-themes";
import { Provider } from "react-redux";
import { store } from "@/store/store";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <Provider store={store}>
      <ThemeProvider
        attribute='class'
        defaultTheme='light'
        enableSystem>
        {children}
      </ThemeProvider>
    </Provider>
  );
}
