export default function ExpensesPage() {
  return (
    <div className="space-y-6">
      <div className="card">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Expenses</h2>
        <p className="text-gray-600">
          Expense tracking features will be implemented here including:
        </p>
        <ul className="list-disc list-inside mt-4 space-y-2 text-gray-600">
          <li>Submit expenses with receipt upload</li>
          <li>Track expenses by location and category</li>
          <li>Manager approval workflow</li>
          <li>Alert on expense spikes (25% threshold)</li>
          <li>Monthly expense reports</li>
        </ul>
      </div>
    </div>
  )
}
