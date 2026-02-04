export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <div className="card">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Owner Settings</h2>
        <p className="text-gray-600">
          Owner control panel features will be implemented here including:
        </p>
        <ul className="list-disc list-inside mt-4 space-y-2 text-gray-600">
          <li>Configure shrinkage threshold (default 5%)</li>
          <li>Configure expense spike threshold (default 25%)</li>
          <li>Set clearing photo threshold (default 500 GHS)</li>
          <li>Manage approval requirements</li>
          <li>Configure photo requirements</li>
          <li>Enable/disable biometric features</li>
          <li>Set lock period for past data</li>
        </ul>
      </div>
    </div>
  )
}
