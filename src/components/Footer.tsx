"use client";

export default function Footer() {
  return (
    <footer className='w-full bg-gray-200 border-t border-gray-300 mt-auto py-4'>
      <div className='max-w-4xl mx-auto px-6 text-center text-sm text-gray-800'>
        <p>
          © {new Date().getFullYear()} DAO Voting App. Built with ❤️ on Web3.
        </p>
      </div>
    </footer>
  );
}
