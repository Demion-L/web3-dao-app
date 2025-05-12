export default function ThemeSwitcher() {
  const { theme, setTheme } = useTheme();

  return (
    <div className='flex items-center gap-2'>
      <button
        onClick={() => setTheme("light")}
        className={`p-2 rounded-full ${
          theme === "light" ? "bg-gray-300" : "bg-gray-700"
        }`}>
        Light
      </button>
      <button
        onClick={() => setTheme("dark")}
        className={`p-2 rounded-full ${
          theme === "dark" ? "bg-gray-300" : "bg-gray-700"
        }`}>
        Dark
      </button>
    </div>
  );
}
