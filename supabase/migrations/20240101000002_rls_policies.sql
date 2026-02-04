-- OwnerView Ghana - Row Level Security (RLS) Policies
-- This enforces all authorization at the database level

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE ownerview_gh_organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_business_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_towns ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_user_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_attachment_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_clearing_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_clearing_claim_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_sales_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownerview_gh_org_settings ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- ORGANIZATIONS
-- ============================================================================

CREATE POLICY "Users see their org" ON ownerview_gh_organizations
  FOR SELECT
  USING (
    id IN (
      SELECT org_id FROM ownerview_gh_user_memberships
      WHERE user_id = auth.uid() AND active = true
    )
  );

-- ============================================================================
-- BUSINESS LINES
-- ============================================================================

CREATE POLICY "Users see their org business lines" ON ownerview_gh_business_lines
  FOR SELECT
  USING (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships
      WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- TOWNS (Public Read)
-- ============================================================================

CREATE POLICY "Towns are publicly readable" ON ownerview_gh_towns
  FOR SELECT
  USING (true);

-- ============================================================================
-- LOCATIONS
-- ============================================================================

CREATE POLICY "Users see locations in their scope" ON ownerview_gh_locations
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND (
      -- OWNER sees all
      EXISTS (
        SELECT 1 FROM ownerview_gh_user_memberships 
        WHERE user_id = auth.uid() AND role = 'OWNER'
      )
      OR
      -- Others see only their assigned locations
      id IN (
        SELECT location_id FROM ownerview_gh_user_memberships
        WHERE user_id = auth.uid() AND location_id IS NOT NULL
      )
    )
  );

-- ============================================================================
-- USER MEMBERSHIPS
-- ============================================================================

CREATE POLICY "Users see their own memberships" ON ownerview_gh_user_memberships
  FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Owners manage memberships" ON ownerview_gh_user_memberships
  FOR ALL
  USING (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships
      WHERE user_id = auth.uid() AND role = 'OWNER'
    )
  );

-- ============================================================================
-- ITEMS
-- ============================================================================

CREATE POLICY "Users see items in their org" ON ownerview_gh_items
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
  );

CREATE POLICY "Managers can create items" ON ownerview_gh_items
  FOR INSERT
  WITH CHECK (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid() 
      AND role IN ('OWNER', 'HQ_ADMIN', 'LOCATION_MANAGER')
    )
  );

CREATE POLICY "Managers can UPDATE ownerview_gh_items" ON ownerview_gh_items
  FOR UPDATE
  USING (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid() 
      AND role IN ('OWNER', 'HQ_ADMIN', 'LOCATION_MANAGER')
    )
  );

-- ============================================================================
-- INVENTORY MOVEMENTS
-- ============================================================================

CREATE POLICY "Users see movements in their scope" ON ownerview_gh_inventory_movements
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND (
      -- OWNER sees all
      EXISTS (
        SELECT 1 FROM ownerview_gh_user_memberships 
        WHERE user_id = auth.uid() AND role = 'OWNER'
      )
      OR
      -- Others see only their locations
      location_id IN (
        SELECT location_id FROM ownerview_gh_user_memberships
        WHERE user_id = auth.uid() AND location_id IS NOT NULL
      )
    )
  );

CREATE POLICY "Staff can create movements" ON ownerview_gh_inventory_movements
  FOR INSERT
  WITH CHECK (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND location_id IN (
      SELECT location_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid()
    )
    AND created_by = auth.uid()
  );

CREATE POLICY "Managers can approve movements" ON ownerview_gh_inventory_movements
  FOR UPDATE
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND (
      EXISTS (
        SELECT 1 FROM ownerview_gh_user_memberships 
        WHERE user_id = auth.uid()
        AND role IN ('OWNER', 'HQ_ADMIN', 'LOCATION_MANAGER')
      )
    )
  );

-- ============================================================================
-- ATTACHMENTS
-- ============================================================================

CREATE POLICY "Users see attachments in their org" ON ownerview_gh_attachments
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can upload attachments" ON ownerview_gh_attachments
  FOR INSERT
  WITH CHECK (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND uploaded_by = auth.uid()
  );

-- ============================================================================
-- ATTACHMENT LINKS
-- ============================================================================

CREATE POLICY "Users see attachment links in their org" ON ownerview_gh_attachment_links
  FOR SELECT
  USING (
    attachment_id IN (
      SELECT id FROM ownerview_gh_attachments 
      WHERE org_id IN (
        SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Users can create attachment links" ON ownerview_gh_attachment_links
  FOR INSERT
  WITH CHECK (
    attachment_id IN (
      SELECT id FROM ownerview_gh_attachments 
      WHERE org_id IN (
        SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
      )
    )
  );

-- ============================================================================
-- EXPENSES
-- ============================================================================

CREATE POLICY "Users see expenses in their scope" ON ownerview_gh_expenses
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND (
      -- OWNER sees all
      EXISTS (
        SELECT 1 FROM ownerview_gh_user_memberships 
        WHERE user_id = auth.uid() AND role = 'OWNER'
      )
      OR
      -- Others see only their locations
      location_id IN (
        SELECT location_id FROM ownerview_gh_user_memberships
        WHERE user_id = auth.uid() AND location_id IS NOT NULL
      )
    )
  );

CREATE POLICY "Staff can submit expenses" ON ownerview_gh_expenses
  FOR INSERT
  WITH CHECK (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND location_id IN (
      SELECT location_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid()
    )
    AND created_by = auth.uid()
  );

CREATE POLICY "Managers can approve expenses" ON ownerview_gh_expenses
  FOR UPDATE
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND (
      EXISTS (
        SELECT 1 FROM ownerview_gh_user_memberships 
        WHERE user_id = auth.uid()
        AND role IN ('OWNER', 'HQ_ADMIN', 'LOCATION_MANAGER', 'ACCOUNTANT')
      )
    )
  );

-- ============================================================================
-- SHIPMENTS
-- ============================================================================

CREATE POLICY "Users see shipments in their org" ON ownerview_gh_shipments
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
  );

CREATE POLICY "Authorized users can create shipments" ON ownerview_gh_shipments
  FOR INSERT
  WITH CHECK (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid()
      AND role IN ('OWNER', 'HQ_ADMIN', 'CLEARING_AGENT')
    )
  );

CREATE POLICY "Authorized users can UPDATE ownerview_gh_shipments" ON ownerview_gh_shipments
  FOR UPDATE
  USING (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid()
      AND role IN ('OWNER', 'HQ_ADMIN', 'CLEARING_AGENT')
    )
  );

-- ============================================================================
-- CLEARING CLAIMS
-- ============================================================================

CREATE POLICY "Users see clearing claims in their org" ON ownerview_gh_clearing_claims
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
  );

CREATE POLICY "Clearing agents can create claims" ON ownerview_gh_clearing_claims
  FOR INSERT
  WITH CHECK (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid()
      AND role IN ('OWNER', 'HQ_ADMIN', 'CLEARING_AGENT')
    )
    AND created_by = auth.uid()
  );

CREATE POLICY "Owner approves clearing claims" ON ownerview_gh_clearing_claims
  FOR UPDATE
  USING (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid()
      AND role IN ('OWNER', 'HQ_ADMIN')
    )
  );

-- ============================================================================
-- CLEARING CLAIM LINES
-- ============================================================================

CREATE POLICY "Users see claim lines in their org" ON ownerview_gh_clearing_claim_lines
  FOR SELECT
  USING (
    claim_id IN (
      SELECT id FROM ownerview_gh_clearing_claims 
      WHERE org_id IN (
        SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Users can manage claim lines" ON ownerview_gh_clearing_claim_lines
  FOR ALL
  USING (
    claim_id IN (
      SELECT id FROM ownerview_gh_clearing_claims 
      WHERE org_id IN (
        SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
      )
    )
  );

-- ============================================================================
-- SALES
-- ============================================================================

CREATE POLICY "Users see sales in their scope" ON ownerview_gh_sales
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND (
      -- OWNER sees all
      EXISTS (
        SELECT 1 FROM ownerview_gh_user_memberships 
        WHERE user_id = auth.uid() AND role = 'OWNER'
      )
      OR
      -- Others see only their locations
      location_id IN (
        SELECT location_id FROM ownerview_gh_user_memberships
        WHERE user_id = auth.uid() AND location_id IS NOT NULL
      )
    )
  );

CREATE POLICY "Sales staff can create sales" ON ownerview_gh_sales
  FOR INSERT
  WITH CHECK (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND location_id IN (
      SELECT location_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid()
    )
    AND created_by = auth.uid()
  );

CREATE POLICY "Managers can approve sales" ON ownerview_gh_sales
  FOR UPDATE
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND (
      EXISTS (
        SELECT 1 FROM ownerview_gh_user_memberships 
        WHERE user_id = auth.uid()
        AND role IN ('OWNER', 'HQ_ADMIN', 'LOCATION_MANAGER')
      )
    )
  );

-- ============================================================================
-- SALES LINES
-- ============================================================================

CREATE POLICY "Users see sales lines in their scope" ON ownerview_gh_sales_lines
  FOR SELECT
  USING (
    sale_id IN (
      SELECT id FROM ownerview_gh_sales 
      WHERE org_id IN (
        SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Users can manage sales lines" ON ownerview_gh_sales_lines
  FOR ALL
  USING (
    sale_id IN (
      SELECT id FROM ownerview_gh_sales 
      WHERE org_id IN (
        SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
      )
    )
  );

-- ============================================================================
-- ALERTS
-- ============================================================================

CREATE POLICY "Users see alerts in their scope" ON ownerview_gh_alerts
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
    AND (
      -- OWNER sees all
      EXISTS (
        SELECT 1 FROM ownerview_gh_user_memberships 
        WHERE user_id = auth.uid() AND role = 'OWNER'
      )
      OR
      -- Others see only their location alerts
      location_id IN (
        SELECT location_id FROM ownerview_gh_user_memberships
        WHERE user_id = auth.uid() AND location_id IS NOT NULL
      )
    )
  );

CREATE POLICY "Owner can UPDATE ownerview_gh_alerts" ON ownerview_gh_alerts
  FOR UPDATE
  USING (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid() AND role = 'OWNER'
    )
  );

-- ============================================================================
-- AUDIT LOG
-- ============================================================================

CREATE POLICY "Owner sees audit log" ON ownerview_gh_audit_log
  FOR SELECT
  USING (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid() AND role = 'OWNER'
    )
  );

-- ============================================================================
-- ORG SETTINGS
-- ============================================================================

CREATE POLICY "Users see their org settings" ON ownerview_gh_org_settings
  FOR SELECT
  USING (
    org_id IN (SELECT org_id FROM ownerview_gh_user_memberships WHERE user_id = auth.uid())
  );

CREATE POLICY "Owner updates org settings" ON ownerview_gh_org_settings
  FOR UPDATE
  USING (
    org_id IN (
      SELECT org_id FROM ownerview_gh_user_memberships 
      WHERE user_id = auth.uid() 
      AND role = 'OWNER'
      AND can_manage_settings = true
    )
  );

-- ============================================================================
-- STORAGE BUCKET POLICIES
-- ============================================================================

-- Create attachments bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('attachments', 'attachments', false)
ON CONFLICT (id) DO NOTHING;

-- Users can upload to their org folder
CREATE POLICY "Users upload to their org"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'attachments'
    AND (storage.foldername(name))[1] IN (
      SELECT org_id::text FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
    )
  );

-- Users can read their org attachments
CREATE POLICY "Users read their org attachments"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'attachments'
    AND (storage.foldername(name))[1] IN (
      SELECT org_id::text FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
    )
  );

-- Users can update their org attachments
CREATE POLICY "Users update their org attachments"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'attachments'
    AND (storage.foldername(name))[1] IN (
      SELECT org_id::text FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
    )
  );

-- Users can delete their org attachments
CREATE POLICY "Users delete their org attachments"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'attachments'
    AND (storage.foldername(name))[1] IN (
      SELECT org_id::text FROM ownerview_gh_user_memberships WHERE user_id = auth.uid()
    )
  );
