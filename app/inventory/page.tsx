export default function InventoryPage() {
  return (
    <div className="space-y-6">
      <div className="card">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Inventory Management</h2>
        <p className="text-gray-600">
          Inventory management features will be implemented here including:
        </p>
        <ul className="list-disc list-inside mt-4 space-y-2 text-gray-600">
          <li>View inventory levels by location</li>
          <li>Make inventory adjustments</li>
          <li>Track theft-suspected items (requires 2 photos)</li>
          <li>Inventory counts and reconciliation</li>
          <li>Transfer between locations</li>
        </ul>
      </div>
    </div>
  )
}
