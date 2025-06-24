import Dashboard from "@/components/Dashboard";

export default function Page() {
  return (
    <div className='min-h-screen bg-gradient-to-br from-[#c058d5] via-[#174e65] to-[#db66db] flex flex-col items-center justify-start pt-24 p-8'>
      <Dashboard />
      {/* <Proposals list /> */}
    </div>
  );
}
