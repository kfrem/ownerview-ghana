export default function ClearingPage() {
  return (
    <div className="space-y-6">
      <div className="card">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Shipments & Clearing</h2>
        <p className="text-gray-600">
          Clearing and shipment management features will be implemented here including:
        </p>
        <ul className="list-disc list-inside mt-4 space-y-2 text-gray-600">
          <li>Track import shipments</li>
          <li>Submit clearing claims</li>
          <li>Automatic photo requirement for claims &gt; 500 GHS</li>
          <li>Owner approval workflow</li>
          <li>Clearing cost analysis</li>
        </ul>
      </div>
    </div>
  )
}
