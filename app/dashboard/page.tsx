import { createClient } from '@/lib/supabase/server'
import { formatCurrency } from '@/lib/utils'

export default async function DashboardPage() {
  const supabase = await createClient()
  
  const {
    data: { user },
  } = await supabase.auth.getUser()

  // Get user's organization memberships
  let memberships: any = null
  
  if (user) {
    const result = await supabase
      .from('user_memberships')
      .select(`
        *,
        organizations (
          id,
          name,
          slug,
          currency
        )
      `)
      .eq('user_id', user.id)
      .eq('active', true)
    memberships = result.data
  }

  const userRole = (memberships?.[0]?.role as string) || 'Unknown'
  const orgName = (memberships?.[0]?.organizations as any)?.name || 'No Organization'
  const isOwner = userRole === 'OWNER'

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="card">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Welcome back! 👋
        </h2>
        <p className="text-gray-600">
          {user?.user_metadata?.full_name || user?.email}
        </p>
        <div className="mt-4 flex items-center gap-2">
          <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
            {userRole}
          </span>
          <span className="text-sm text-gray-600">{orgName}</span>
        </div>
      </div>

      {/* Quick Stats - Owner View */}
      {isOwner && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="card">
            <h3 className="text-sm font-medium text-gray-600 mb-1">
              Total Sales (Today)
            </h3>
            <p className="text-2xl font-bold text-gray-900">
              {formatCurrency(0)}
            </p>
            <p className="text-xs text-gray-500 mt-1">
              0 transactions
            </p>
          </div>
          
          <div className="card">
            <h3 className="text-sm font-medium text-gray-600 mb-1">
              Total Expenses (Today)
            </h3>
            <p className="text-2xl font-bold text-gray-900">
              {formatCurrency(0)}
            </p>
            <p className="text-xs text-gray-500 mt-1">
              0 entries
            </p>
          </div>
          
          <div className="card">
            <h3 className="text-sm font-medium text-gray-600 mb-1">
              Pending Alerts
            </h3>
            <p className="text-2xl font-bold text-gray-900">0</p>
            <p className="text-xs text-gray-500 mt-1">
              No urgent items
            </p>
          </div>
        </div>
      )}

      {/* Recent Activity */}
      <div className="card">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Recent Activity
        </h3>
        <div className="text-center py-8 text-gray-500">
          <svg
            className="w-12 h-12 mx-auto mb-3 text-gray-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
            />
          </svg>
          <p>No recent activity</p>
          <p className="text-sm mt-1">
            Start by adding inventory, expenses, or shipments
          </p>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="card">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Quick Actions
        </h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          <a
            href="/inventory/adjust"
            className="flex flex-col items-center justify-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <svg className="w-8 h-8 text-blue-600 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            <span className="text-sm font-medium text-gray-900">
              Adjust Inventory
            </span>
          </a>
          
          <a
            href="/expenses/new"
            className="flex flex-col items-center justify-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <svg className="w-8 h-8 text-green-600 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span className="text-sm font-medium text-gray-900">
              Add Expense
            </span>
          </a>
          
          <a
            href="/clearing/new"
            className="flex flex-col items-center justify-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <svg className="w-8 h-8 text-purple-600 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <span className="text-sm font-medium text-gray-900">
              New Claim
            </span>
          </a>
          
          <a
            href="/settings"
            className="flex flex-col items-center justify-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <svg className="w-8 h-8 text-gray-600 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <span className="text-sm font-medium text-gray-900">
              Settings
            </span>
          </a>
        </div>
      </div>

      {/* Mobile Spacing for Bottom Nav */}
      <div className="h-20 md:hidden" />
    </div>
  )
}
