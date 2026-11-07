import { Oswald, Inter } from 'next/font/google';
import './globals.css';

const display = Oswald({
  subsets: ['latin'],
  variable: '--font-display',
  weight: ['500', '600', '700'],
  display: 'swap',
});

const body = Inter({
  subsets: ['latin'],
  variable: '--font-body',
  display: 'swap',
});

export const metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'),
  title: {
    default: 'JerseyWala.pk | Wear Your Passion.',
    template: '%s | JerseyWala.pk',
  },
  description:
    'Pakistan’s online football jersey store. Your favourite clubs. Your football identity. Order easily via Instagram.',
};

export const viewport = {
  themeColor: '#0a0a0a',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${display.variable} ${body.variable}`}>
      <body>{children}</body>
    </html>
  );
}
