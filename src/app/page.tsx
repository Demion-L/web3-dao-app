import Dashboard from "@/components/Dashboard";

export default function Page() {
  return (
    <div className='min-h-screen bg-gradient-to-br from-[#0f2027] via-[#2c5364] to-[#232526] flex flex-col items-center justify-start pt-24 p-8'>
      <Dashboard />
      {/* You can add more components here later */}
    </div>
  );
}
