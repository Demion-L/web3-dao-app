"use client";

import { Button } from "@/components/ui/Button";
import { useState } from "react";

export default function ContactPage() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    subject: "",
    message: "",
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle form submission
    console.log("Form submitted:", formData);
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  return (
    <div className='container mx-auto px-4 py-8'>
      <div className='card p-6 max-w-3xl mx-auto'>
        <h1 className='text-3xl font-bold mb-8 text-primary'>Contact Us</h1>

        <div className='grid md:grid-cols-2 gap-8'>
          <div>
            <h2 className='text-xl font-semibold mb-4'>Get in Touch</h2>
            <p className='text-gray-600 dark:text-gray-300 mb-6'>
              Have questions about our DAO voting platform? We&apos;re here to
              help! Fill out the form and we&apos;ll get back to you as soon as
              possible.
            </p>

            <div className='space-y-4'>
              <div>
                <h3 className='font-medium'>Email</h3>
                <p className='text-gray-600 dark:text-gray-300'>
                  support@daovoting.com
                </p>
              </div>
              <div>
                <h3 className='font-medium'>Discord</h3>
                <p className='text-gray-600 dark:text-gray-300'>
                  Join our community
                </p>
              </div>
              <div>
                <h3 className='font-medium'>Twitter</h3>
                <p className='text-gray-600 dark:text-gray-300'>@DAOVoting</p>
              </div>
            </div>
          </div>

          <form
            onSubmit={handleSubmit}
            className='space-y-4'>
            <div>
              <label
                htmlFor='name'
                className='block text-sm font-medium mb-1'>
                Name
              </label>
              <input
                type='text'
                id='name'
                name='name'
                value={formData.name}
                onChange={handleChange}
                className='w-full p-2 border rounded-lg bg-white/50 dark:bg-gray-800/50'
                required
              />
            </div>

            <div>
              <label
                htmlFor='email'
                className='block text-sm font-medium mb-1'>
                Email
              </label>
              <input
                type='email'
                id='email'
                name='email'
                value={formData.email}
                onChange={handleChange}
                className='w-full p-2 border rounded-lg bg-white/50 dark:bg-gray-800/50'
                required
              />
            </div>

            <div>
              <label
                htmlFor='subject'
                className='block text-sm font-medium mb-1'>
                Subject
              </label>
              <input
                type='text'
                id='subject'
                name='subject'
                value={formData.subject}
                onChange={handleChange}
                className='w-full p-2 border rounded-lg bg-white/50 dark:bg-gray-800/50'
                required
              />
            </div>

            <div>
              <label
                htmlFor='message'
                className='block text-sm font-medium mb-1'>
                Message
              </label>
              <textarea
                id='message'
                name='message'
                value={formData.message}
                onChange={handleChange}
                rows={4}
                className='w-full p-2 border rounded-lg bg-white/50 dark:bg-gray-800/50'
                required
              />
            </div>

            <Button
              type='submit'
              variant='primary'>
              Send Message
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
}
