import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'OwnerView Ghana - Business Management',
  description: 'Mobile-first inventory and clearing compliance system for multi-business operations in Ghana',
  manifest: '/manifest.json',
  themeColor: '#2563eb',
  viewport: {
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
    userScalable: false,
  },
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: 'OwnerView Ghana',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="antialiased">
        {children}
      </body>
    </html>
  )
}
