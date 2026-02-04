-- OwnerView Ghana - Demo Data for Testing
-- This creates a complete test organization with sample data

-- Create demo organization
INSERT INTO ownerview_gh_organizations (id, name, slug, currency)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Ghana Multi-Business Holdings',
  'ghana-multi-biz',
  'GHS'
) ON CONFLICT (id) DO NOTHING;

-- Create business lines
INSERT INTO ownerview_gh_business_lines (id, org_id, name, slug, active) VALUES
('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000001', 'Heavy Machinery', 'heavy-machinery', true),
('00000000-0000-0000-0001-000000000002', '00000000-0000-0000-0000-000000000001', 'Car Spare Parts', 'spare-parts', true),
('00000000-0000-0000-0001-000000000003', '00000000-0000-0000-0000-000000000001', 'Mining Operations', 'mining', true)
ON CONFLICT (id) DO NOTHING;

-- Create organization settings
INSERT INTO ownerview_gh_org_settings (org_id, settings)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  '{
    "shrinkage_threshold_percent": 5,
    "expense_spike_threshold_percent": 25,
    "clearing_photo_threshold_ghs": 500,
    "require_manager_approval": {
      "adjustments": true,
      "theft_suspected": true,
      "expenses_above": 1000
    },
    "photo_requirements": {
      "adjustment": 1,
      "theft_suspected": 2,
      "expense": 1
    },
    "biometric": {
      "enabled": false,
      "require_for_inventory": false,
      "require_for_expenses": false,
      "require_for_clearing": false
    },
    "negative_stock_behavior": "WARN",
    "lock_period_days": 7,
    "missing_report_cutoff_hour": 18
  }'::jsonb
) ON CONFLICT (org_id) DO NOTHING;

-- Note: Users must be created through Supabase Auth
-- After creating users via signup, run this to set up memberships:
-- 
-- Example SQL to add user memberships (replace with actual user_ids):
-- 
-- INSERT INTO ownerview_gh_user_memberships (user_id, org_id, role, business_line_id, location_id, can_manage_settings, active)
-- VALUES
-- -- Owner
-- ('<owner-user-id>', '00000000-0000-0000-0000-000000000001', 'OWNER', NULL, NULL, true, true),
-- 
-- -- Manager for Accra Shop
-- ('<manager-user-id>', '00000000-0000-0000-0000-000000000001', 'LOCATION_MANAGER', 
--  '00000000-0000-0000-0001-000000000002', '<accra-location-id>', false, true),
-- 
-- -- Warehouse Staff for Tema
-- ('<staff-user-id>', '00000000-0000-0000-0000-000000000001', 'WAREHOUSE_STAFF',
--  '00000000-0000-0000-0001-000000000001', '<tema-location-id>', false, true);

-- Get town IDs for demo locations
DO $$
DECLARE
  accra_town_id UUID;
  tema_town_id UUID;
  kumasi_town_id UUID;
  obuasi_town_id UUID;
  takoradi_town_id UUID;
BEGIN
  -- Get town IDs
  SELECT id INTO accra_town_id FROM ownerview_gh_towns WHERE name = 'Accra' LIMIT 1;
  SELECT id INTO tema_town_id FROM ownerview_gh_towns WHERE name = 'Tema' LIMIT 1;
  SELECT id INTO kumasi_town_id FROM ownerview_gh_towns WHERE name = 'Kumasi' LIMIT 1;
  SELECT id INTO obuasi_town_id FROM ownerview_gh_towns WHERE name = 'Obuasi' LIMIT 1;
  SELECT id INTO takoradi_town_id FROM ownerview_gh_towns WHERE name = 'Sekondi-Takoradi' LIMIT 1;

  -- Create demo locations
  INSERT INTO ownerview_gh_locations (org_id, business_line_id, town_id, name, type, address, active) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000002', accra_town_id, 'Accra Spare Parts Shop', 'Shop', 'Abossey Okai, Accra', true),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000001', tema_town_id, 'Tema Machinery Warehouse', 'Warehouse', 'Industrial Area, Tema', true),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000002', kumasi_town_id, 'Kumasi Spare Parts Branch', 'Shop', 'Suame Magazine, Kumasi', true),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000003', obuasi_town_id, 'Obuasi Mine Site', 'Mine Site', 'Obuasi Mining Area', true),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000001', takoradi_town_id, 'Takoradi Port Warehouse', 'Warehouse', 'Near Takoradi Port', true)
  ON CONFLICT DO NOTHING;
END $$;

-- Create demo items
INSERT INTO ownerview_gh_items (org_id, business_line_id, sku, name, description, category, unit, cost_price, selling_price, reorder_level, high_risk, active) VALUES
-- Heavy Machinery
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000001', 'EXC-CAT-320', 'Caterpillar 320 Excavator', 'Heavy duty excavator', 'Excavators', 'unit', 450000.00, 550000.00, 1, true, true),
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000001', 'BLD-CAT-D6', 'Caterpillar D6 Bulldozer', 'Track-type bulldozer', 'Bulldozers', 'unit', 380000.00, 480000.00, 1, true, true),
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000001', 'GEN-CAT-500', 'Caterpillar 500kVA Generator', 'Diesel generator', 'Generators', 'unit', 85000.00, 120000.00, 2, false, true),

-- Car Spare Parts
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000002', 'BRK-PAD-001', 'Brake Pads Set', 'Front brake pads', 'Brakes', 'set', 120.00, 250.00, 50, false, true),
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000002', 'OIL-FLT-002', 'Oil Filter', 'Engine oil filter', 'Filters', 'pcs', 25.00, 55.00, 100, false, true),
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000002', 'AIR-FLT-003', 'Air Filter', 'Air intake filter', 'Filters', 'pcs', 30.00, 65.00, 80, false, true),
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000002', 'SPK-PLG-004', 'Spark Plugs (4pc)', 'Platinum spark plugs', 'Ignition', 'set', 80.00, 160.00, 40, false, true),
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000002', 'BAT-12V-005', '12V Car Battery', 'Maintenance-free battery', 'Electrical', 'pcs', 280.00, 450.00, 20, true, true),

-- Mining Equipment
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000003', 'DRL-BT-001', 'Drill Bits Set', 'Carbide drill bits', 'Drilling', 'set', 450.00, 750.00, 15, false, true),
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000003', 'SFT-HLM-002', 'Safety Helmets', 'Mining safety helmets', 'Safety', 'pcs', 45.00, 80.00, 100, false, true)
ON CONFLICT (org_id, sku) DO NOTHING;
