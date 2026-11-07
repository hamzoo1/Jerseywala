'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useState } from 'react';

const LINKS = [
  { href: '/', label: 'Home' },
  { href: '/shop', label: 'Shop' },
  { href: '/about', label: 'About' },
  { href: '/contact', label: 'Contact' },
];

export default function Navbar({ instagramProfile }) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  const isActive = (href) => (href === '/' ? pathname === '/' : pathname.startsWith(href));

  return (
    <header className="sticky top-0 z-40 border-b border-line bg-ink/85 backdrop-blur-md">
      <div className="container-x flex h-16 items-center justify-between">
        <Link href="/" className="font-heading text-2xl font-bold leading-none" onClick={() => setOpen(false)}>
          Jersey<span className="text-brand">Wala</span>
          <span className="text-white/50">.pk</span>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          {LINKS.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              className={`text-sm font-medium uppercase tracking-wider transition hover:text-white ${
                isActive(l.href) ? 'text-white' : 'text-white/60'
              }`}
            >
              {l.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-3">
          <a
            href={instagramProfile}
            target="_blank"
            rel="noopener noreferrer"
            className="hidden rounded-lg border border-line px-3 py-2 text-xs font-semibold uppercase tracking-wider text-white/80 transition hover:border-brand hover:text-white sm:inline-block"
          >
            Instagram
          </a>
          <Link href="/shop" className="btn-red hidden px-4 py-2 sm:inline-flex">
            Shop Now
          </Link>
          <button
            type="button"
            aria-label="Toggle menu"
            aria-expanded={open}
            onClick={() => setOpen((v) => !v)}
            className="flex h-10 w-10 items-center justify-center rounded-lg border border-line md:hidden"
          >
            <span className="sr-only">Menu</span>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              {open ? (
                <path d="M6 6l12 12M18 6L6 18" />
              ) : (
                <path d="M4 7h16M4 12h16M4 17h16" />
              )}
            </svg>
          </button>
        </div>
      </div>

      {open && (
        <nav className="border-t border-line bg-charcoal md:hidden">
          <div className="container-x flex flex-col py-2">
            {LINKS.map((l) => (
              <Link
                key={l.href}
                href={l.href}
                onClick={() => setOpen(false)}
                className={`border-b border-line/60 py-3 text-sm font-medium uppercase tracking-wider ${
                  isActive(l.href) ? 'text-brand' : 'text-white/80'
                }`}
              >
                {l.label}
              </Link>
            ))}
            <a
              href={instagramProfile}
              target="_blank"
              rel="noopener noreferrer"
              className="py-3 text-sm font-medium uppercase tracking-wider text-white/80"
            >
              Instagram
            </a>
          </div>
        </nav>
      )}
    </header>
  );
}
