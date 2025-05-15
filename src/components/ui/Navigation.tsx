import Link from "next/link";
import { useState } from "react";

interface NavigationProps {
  className?: string;
}

export function Navigation({ className = "" }: NavigationProps) {
  const [isOpen, setIsOpen] = useState(false);

  const links = [
    { href: "/about", label: "About" },
    { href: "/faq", label: "FAQ" },
    { href: "/contact", label: "Contact" },
    { href: "/docs", label: "Docs" },
  ];

  const toggleMenu = () => {
    setIsOpen(!isOpen);
    document.body.style.overflow = !isOpen ? "hidden" : "unset";
  };

  return (
    <>
      {/* Burger Menu Button - Only visible on mobile */}
      <button
        onClick={toggleMenu}
        className='lg:hidden p-2 hover:bg-gray-100 rounded-lg transition-colors'
        aria-label='Toggle menu'>
        <div className='w-6 h-5 relative flex flex-col justify-between'>
          <span
            className={`w-full h-0.5 bg-gray-700 transform transition-all duration-300 ${
              isOpen ? "rotate-45 translate-y-2" : ""
            }`}
          />
          <span
            className={`w-full h-0.5 bg-gray-700 transition-all duration-300 ${
              isOpen ? "opacity-0" : ""
            }`}
          />
          <span
            className={`w-full h-0.5 bg-gray-700 transform transition-all duration-300 ${
              isOpen ? "-rotate-45 -translate-y-2" : ""
            }`}
          />
        </div>
      </button>

      {/* Desktop Navigation */}
      <nav className={`hidden lg:flex items-center gap-4 ${className}`}>
        {links.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className='text-gray-700 hover:text-gray-900 transition-colors'>
            {link.label}
          </Link>
        ))}
      </nav>

      {/* Mobile Navigation Overlay */}
      <div
        className={`fixed inset-0 bg-black/50 z-40 lg:hidden transition-opacity duration-300 ${
          isOpen ? "opacity-100" : "opacity-0 pointer-events-none"
        }`}
        onClick={toggleMenu}
      />

      {/* Mobile Navigation Panel */}
      <div
        className={`fixed top-0 right-0 h-full w-64 bg-white shadow-lg z-50 lg:hidden transform transition-transform duration-300 ease-in-out ${
          isOpen ? "translate-x-0" : "translate-x-full"
        }`}>
        <div className='p-6'>
          <div className='flex justify-end mb-8'>
            <button
              onClick={toggleMenu}
              className='p-2 hover:bg-gray-100 rounded-lg transition-colors'
              aria-label='Close menu'>
              <svg
                className='w-6 h-6 text-gray-700'
                fill='none'
                stroke='currentColor'
                viewBox='0 0 24 24'>
                <path
                  strokeLinecap='round'
                  strokeLinejoin='round'
                  strokeWidth={2}
                  d='M6 18L18 6M6 6l12 12'
                />
              </svg>
            </button>
          </div>
          <nav className='flex flex-col gap-4'>
            {links.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={toggleMenu}
                className='text-gray-700 hover:text-gray-900 transition-colors py-2'>
                {link.label}
              </Link>
            ))}
          </nav>
        </div>
      </div>
    </>
  );
}
