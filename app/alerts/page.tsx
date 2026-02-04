export default function AlertsPage() {
  return (
    <div className="space-y-6">
      <div className="card">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Alerts & Notifications</h2>
        <p className="text-gray-600">
          Alert monitoring features will be implemented here including:
        </p>
        <ul className="list-disc list-inside mt-4 space-y-2 text-gray-600">
          <li>Theft suspected alerts (HIGH priority)</li>
          <li>Inventory shrinkage alerts (&gt;5% threshold)</li>
          <li>Expense spike alerts (&gt;25% increase)</li>
          <li>Missing daily reports</li>
          <li>Alert resolution and notes</li>
        </ul>
      </div>
    </div>
  )
}
