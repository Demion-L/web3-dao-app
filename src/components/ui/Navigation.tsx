"use client";

import Link from "next/link";
import { useState, useEffect } from "react";
import ReactDOM from "react-dom";

interface NavigationProps {
  className?: string;
}

export function Navigation({ className = "" }: NavigationProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [mounted, setMounted] = useState(false);

  const links = [
    { href: "/", label: "Home" },
    { href: "/about", label: "About" },
    { href: "/faq", label: "FAQ" },
    { href: "/contact", label: "Contact" },
    { href: "/docs", label: "Docs" },
  ];

  useEffect(() => {
    setMounted(true);
    document.body.style.overflow = isOpen ? "hidden" : "";

    return () => {
      document.body.style.overflow = "";
    };
  }, [isOpen]);

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div className='relative'>
      {/* Burger Menu Button */}
      <button
        onClick={toggleMenu}
        className='lg:hidden p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors'
        aria-label='Toggle menu'
        aria-expanded={isOpen}>
        <div className='w-6 h-5 relative flex flex-col justify-between'>
          <span
            className={`w-full h-0.5 bg-gray-700 dark:bg-gray-300 transform transition-all duration-300 ${
              isOpen ? "rotate-45 translate-y-2" : ""
            }`}
          />
          <span
            className={`w-full h-0.5 bg-gray-700 dark:bg-gray-300 transition-all duration-300 ${
              isOpen ? "opacity-0" : ""
            }`}
          />
          <span
            className={`w-full h-0.5 bg-gray-700 dark:bg-gray-300 transform transition-all duration-300 ${
              isOpen ? "-rotate-45 -translate-y-2.5" : ""
            }`}
          />
        </div>
      </button>

      {/* Desktop Navigation */}
      <nav className={`hidden lg:flex items-center gap-4 ${className} mr-6`}>
        {links.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className='text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors'>
            {link.label}
          </Link>
        ))}
      </nav>

      {/* Mobile Navigation Overlay - Rendered via Portal */}
      {mounted &&
        isOpen &&
        ReactDOM.createPortal(
          <div
            className='fixed inset-0 bg-black/50 z-40 lg:hidden'
            onClick={toggleMenu}
            aria-hidden='true'
          />,
          document.body
        )}

      {/* Mobile Navigation Panel - Rendered via Portal */}
      {mounted &&
        ReactDOM.createPortal(
          <div
            className={`fixed top-0 right-0 h-full w-64 bg-white dark:bg-gray-900 shadow-lg z-50 lg:hidden transform transition-transform duration-300 ease-in-out ${
              isOpen ? "translate-x-0" : "translate-x-full"
            }`}>
            <div className='p-6'>
              <div className='flex justify-end mb-8'>
                <button
                  onClick={toggleMenu}
                  className='p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors'
                  aria-label='Close menu'>
                  <svg
                    className='w-6 h-6 text-gray-700 dark:text-gray-300'
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
                    className='text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors py-2'>
                    {link.label}
                  </Link>
                ))}
              </nav>
            </div>
          </div>,
          document.body
        )}
    </div>
  );
}
