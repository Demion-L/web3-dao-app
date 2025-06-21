/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: 'class', // Enable class-based dark mode
  theme: {
    extend: {
      fontFamily: {
        sans: ["var(--font-orbitron)"],
        mono: ["var(--font-share-tech-mono)"],
      },
      boxShadow: {
        neon: "0 0 8px 2px #0ff, 0 0 16px 4px #f0f",
      },
      textShadow: {
        neon: "0 0 8px #0ff, 0 0 16px #f0f",
      },
    },
  },
  plugins: [
    function ({ addUtilities }) {
      addUtilities({
        ".text-shadow-neon": {
          textShadow: "0 0 8px #0ff, 0 0 16px #f0f",
        },
        ".text-shadow": {
          textShadow: "1px 1px 2px rgba(0, 0, 0, 0.5)",
        },
        ".text-shadow-md": {
          textShadow: "2px 2px 4px rgba(0, 0, 0, 0.5)",
        },
        ".text-shadow-lg": {
          textShadow: "4px 4px 8px rgba(0, 0, 0, 0.5)",
        },
      });
    },
  ],
}

