-- OwnerView Ghana - Initial Schema Migration
-- This creates all core tables for the inventory and clearing compliance system

-- ============================================================================
-- CORE ORGANIZATION STRUCTURE
-- ============================================================================

-- Organizations table
CREATE TABLE ownerview_gh_organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  currency TEXT DEFAULT 'GHS',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Business lines (Heavy Machinery, Spare Parts, Mining)
CREATE TABLE ownerview_gh_business_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(org_id, slug)
);

-- Ghana towns reference table
CREATE TABLE ownerview_gh_towns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  region TEXT,
  country TEXT DEFAULT 'Ghana',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Business locations (shops, warehouses, mine sites)
CREATE TABLE ownerview_gh_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  business_line_id UUID REFERENCES ownerview_gh_business_lines(id) ON DELETE SET NULL,
  town_id UUID NOT NULL REFERENCES ownerview_gh_towns(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Shop', 'Warehouse', 'Mine Site', 'Office')),
  address TEXT,
  gps_lat DECIMAL(10,8),
  gps_lng DECIMAL(11,8),
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- USER MANAGEMENT
-- ============================================================================

-- User memberships with role-based access
CREATE TABLE ownerview_gh_user_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN (
    'OWNER', 
    'HQ_ADMIN', 
    'LOCATION_MANAGER',
    'WAREHOUSE_STAFF', 
    'SALES_STAFF', 
    'CLEARING_AGENT', 
    'ACCOUNTANT'
  )),
  business_line_id UUID REFERENCES ownerview_gh_business_lines(id),
  location_id UUID REFERENCES ownerview_gh_locations(id),
  can_manage_settings BOOLEAN DEFAULT false,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, org_id, location_id)
);

-- ============================================================================
-- INVENTORY SYSTEM
-- ============================================================================

-- Items catalog
CREATE TABLE ownerview_gh_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  business_line_id UUID REFERENCES ownerview_gh_business_lines(id),
  sku TEXT,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  unit TEXT DEFAULT 'pcs',
  cost_price DECIMAL(15,2),
  selling_price DECIMAL(15,2),
  reorder_level INTEGER DEFAULT 0,
  high_risk BOOLEAN DEFAULT false,
  track_serial BOOLEAN DEFAULT false,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(org_id, sku)
);

-- Inventory movements (receives, issues, adjustments, transfers, counts)
CREATE TABLE ownerview_gh_inventory_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  location_id UUID NOT NULL REFERENCES ownerview_gh_locations(id),
  item_id UUID NOT NULL REFERENCES ownerview_gh_items(id),
  movement_type TEXT NOT NULL CHECK (movement_type IN (
    'RECEIVE', 
    'ISSUE', 
    'TRANSFER_OUT', 
    'TRANSFER_IN', 
    'ADJUSTMENT', 
    'COUNT'
  )),
  quantity DECIMAL(15,3) NOT NULL,
  unit_cost DECIMAL(15,2),
  reference_id UUID,
  reason_code TEXT,
  notes TEXT,
  status TEXT DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'SUBMITTED', 'APPROVED', 'POSTED')),
  created_by UUID REFERENCES auth.users(id),
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- ATTACHMENTS SYSTEM (Photos, Receipts, Documents)
-- ============================================================================

-- File attachments stored in Supabase Storage
CREATE TABLE ownerview_gh_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  file_name TEXT NOT NULL,
  mime_type TEXT,
  size_bytes INTEGER,
  uploaded_by UUID REFERENCES auth.users(id),
  uploaded_at TIMESTAMPTZ DEFAULT now()
);

-- Links attachments to various entities
CREATE TABLE ownerview_gh_attachment_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attachment_id UUID NOT NULL REFERENCES ownerview_gh_attachments(id) ON DELETE CASCADE,
  parent_type TEXT NOT NULL,
  parent_id UUID NOT NULL,
  line_id UUID,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(attachment_id, parent_type, parent_id, line_id)
);

-- ============================================================================
-- EXPENSES TRACKING
-- ============================================================================

-- Business expenses with receipt requirements
CREATE TABLE ownerview_gh_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  location_id UUID REFERENCES ownerview_gh_locations(id),
  business_line_id UUID REFERENCES ownerview_gh_business_lines(id),
  date DATE NOT NULL,
  category TEXT NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  currency TEXT DEFAULT 'GHS',
  payment_method TEXT,
  vendor TEXT,
  description TEXT,
  status TEXT DEFAULT 'SUBMITTED' CHECK (status IN ('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED')),
  created_by UUID REFERENCES auth.users(id),
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- SHIPMENTS & CLEARING
-- ============================================================================

-- Import shipments
CREATE TABLE ownerview_gh_shipments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  business_line_id UUID REFERENCES ownerview_gh_business_lines(id),
  supplier TEXT NOT NULL,
  container_number TEXT,
  bl_number TEXT,
  incoterm TEXT,
  port TEXT DEFAULT 'Tema',
  eta DATE,
  ata DATE,
  declared_value DECIMAL(15,2),
  declared_currency TEXT DEFAULT 'USD',
  fx_rate_to_ghs DECIMAL(10,4),
  status TEXT DEFAULT 'IN_TRANSIT' CHECK (status IN (
    'IN_TRANSIT', 
    'ARRIVED', 
    'CLEARING', 
    'CLEARED', 
    'DELIVERED'
  )),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Clearing agent claims (with 500 GHS photo threshold)
CREATE TABLE ownerview_gh_clearing_claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  shipment_id UUID NOT NULL REFERENCES ownerview_gh_shipments(id) ON DELETE CASCADE,
  agent_id UUID REFERENCES auth.users(id),
  total_amount DECIMAL(15,2) DEFAULT 0,
  currency TEXT DEFAULT 'GHS',
  status TEXT DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED')),
  submitted_at TIMESTAMPTZ,
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMPTZ,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Clearing claim line items (duties, handling, transport, etc.)
CREATE TABLE ownerview_gh_clearing_claim_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_id UUID NOT NULL REFERENCES ownerview_gh_clearing_claims(id) ON DELETE CASCADE,
  line_type TEXT NOT NULL,
  description TEXT,
  amount DECIMAL(15,2) NOT NULL,
  currency TEXT DEFAULT 'GHS',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- SALES TRACKING
-- ============================================================================

-- Sales transactions
CREATE TABLE ownerview_gh_sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  location_id UUID NOT NULL REFERENCES ownerview_gh_locations(id),
  business_line_id UUID REFERENCES ownerview_gh_business_lines(id),
  sale_date DATE NOT NULL,
  customer_name TEXT,
  payment_method TEXT,
  reference_number TEXT,
  subtotal DECIMAL(15,2) DEFAULT 0,
  tax DECIMAL(15,2) DEFAULT 0,
  total DECIMAL(15,2) DEFAULT 0,
  status TEXT DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'COMPLETED', 'APPROVED')),
  created_by UUID REFERENCES auth.users(id),
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Sales line items
CREATE TABLE ownerview_gh_sales_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES ownerview_gh_sales(id) ON DELETE CASCADE,
  item_id UUID REFERENCES ownerview_gh_items(id),
  description TEXT,
  quantity DECIMAL(15,3) NOT NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  discount DECIMAL(15,2) DEFAULT 0,
  line_total DECIMAL(15,2) NOT NULL,
  serial_number TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- ALERTS & NOTIFICATIONS
-- ============================================================================

-- System alerts for owner monitoring
CREATE TABLE ownerview_gh_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  location_id UUID REFERENCES ownerview_gh_locations(id),
  business_line_id UUID REFERENCES ownerview_gh_business_lines(id),
  alert_type TEXT NOT NULL,
  severity TEXT DEFAULT 'MEDIUM' CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  title TEXT NOT NULL,
  description TEXT,
  related_entity_type TEXT,
  related_entity_id UUID,
  status TEXT DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'ACKNOWLEDGED', 'RESOLVED', 'DISMISSED')),
  owner_notes TEXT,
  resolved_by UUID REFERENCES auth.users(id),
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- AUDIT LOG
-- ============================================================================

-- Comprehensive audit trail
CREATE TABLE ownerview_gh_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
  old_data JSONB,
  new_data JSONB,
  changed_by UUID REFERENCES auth.users(id),
  changed_at TIMESTAMPTZ DEFAULT now(),
  ip_address INET
);

-- ============================================================================
-- ORGANIZATION SETTINGS
-- ============================================================================

-- Owner-configurable settings
CREATE TABLE ownerview_gh_org_settings (
  org_id UUID PRIMARY KEY REFERENCES ownerview_gh_organizations(id) ON DELETE CASCADE,
  settings JSONB DEFAULT '{
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
  }'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_ownerview_gh_user_memberships_user_id ON ownerview_gh_user_memberships(user_id);
CREATE INDEX idx_ownerview_gh_user_memberships_org_id ON ownerview_gh_user_memberships(org_id);
CREATE INDEX idx_ownerview_gh_locations_org_id ON ownerview_gh_locations(org_id);
CREATE INDEX idx_ownerview_gh_items_org_id ON ownerview_gh_items(org_id);
CREATE INDEX idx_ownerview_gh_inventory_movements_location ON ownerview_gh_inventory_movements(location_id);
CREATE INDEX idx_ownerview_gh_inventory_movements_item ON ownerview_gh_inventory_movements(item_id);
CREATE INDEX idx_ownerview_gh_inventory_movements_created_at ON ownerview_gh_inventory_movements(created_at DESC);
CREATE INDEX idx_ownerview_gh_expenses_org_id ON ownerview_gh_expenses(org_id);
CREATE INDEX idx_ownerview_gh_expenses_date ON ownerview_gh_expenses(date DESC);
CREATE INDEX idx_ownerview_gh_sales_location ON ownerview_gh_sales(location_id);
CREATE INDEX idx_ownerview_gh_sales_date ON ownerview_gh_sales(sale_date DESC);
CREATE INDEX idx_ownerview_gh_alerts_org_id ON ownerview_gh_alerts(org_id);
CREATE INDEX idx_ownerview_gh_alerts_status ON ownerview_gh_alerts(status);
CREATE INDEX idx_ownerview_gh_audit_log_org_id ON ownerview_gh_audit_log(org_id);
CREATE INDEX idx_ownerview_gh_audit_log_table_record ON ownerview_gh_audit_log(table_name, record_id);

-- ============================================================================
-- MATERIALIZED VIEW FOR DASHBOARD
-- ============================================================================

CREATE MATERIALIZED VIEW ownerview_gh_daily_summary_by_location AS
SELECT
  l.id AS location_id,
  l.org_id,
  DATE(s.sale_date) AS summary_date,
  COALESCE(SUM(s.total), 0) AS total_sales,
  COALESCE(SUM(s.total - COALESCE(sl.cost_total, 0)), 0) AS gross_profit,
  COALESCE(SUM(e.amount), 0) AS total_expenses
FROM ownerview_gh_locations l
LEFT JOIN ownerview_gh_sales s ON s.location_id = l.id AND s.status = 'APPROVED'
LEFT JOIN (
  SELECT sale_id, SUM(quantity * COALESCE(i.cost_price, 0)) AS cost_total
  FROM ownerview_gh_sales_lines sl
  LEFT JOIN ownerview_gh_items i ON i.id = sl.item_id
  GROUP BY sale_id
) sl ON sl.sale_id = s.id
LEFT JOIN ownerview_gh_expenses e ON e.location_id = l.id AND e.status = 'APPROVED'
GROUP BY l.id, l.org_id, DATE(s.sale_date);

CREATE UNIQUE INDEX ON ownerview_gh_daily_summary_by_location(location_id, summary_date);
