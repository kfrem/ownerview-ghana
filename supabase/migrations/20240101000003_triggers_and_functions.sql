-- OwnerView Ghana - Triggers and Database Functions
-- This enforces business rules, photo requirements, and automatic alerts

-- ============================================================================
-- HELPER FUNCTION: Get org settings
-- ============================================================================

CREATE OR REPLACE FUNCTION get_org_setting(p_org_id UUID, p_key TEXT, p_default JSONB DEFAULT 'null'::jsonb)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT settings -> p_key INTO result
  FROM ownerview_gh_org_settings
  WHERE org_id = p_org_id;
  
  RETURN COALESCE(result, p_default);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGER: Enforce adjustment photo requirement
-- ============================================================================

CREATE OR REPLACE FUNCTION check_adjustment_photo_requirement()
RETURNS TRIGGER AS $$
DECLARE
  photo_count INTEGER;
  required_photos INTEGER;
  org_settings JSONB;
BEGIN
  -- Only check for ADJUSTMENT movements being submitted/posted/approved
  IF NEW.movement_type = 'ADJUSTMENT' 
     AND NEW.status IN ('SUBMITTED', 'POSTED', 'APPROVED') 
     AND (OLD.status IS NULL OR OLD.status = 'DRAFT') THEN
    
    -- Get org settings
    SELECT settings INTO ownerview_gh_org_settings 
    FROM ownerview_gh_org_settings
    WHERE org_id = NEW.org_id;
    
    -- Determine required photos based on reason code
    IF NEW.reason_code = 'THEFT_SUSPECTED' THEN
      required_photos := COALESCE(
        (org_settings->'photo_requirements'->>'theft_suspected')::INTEGER, 
        2
      );
    ELSE
      required_photos := COALESCE(
        (org_settings->'photo_requirements'->>'adjustment')::INTEGER, 
        1
      );
    END IF;
    
    -- Count attached photos
    SELECT COUNT(*)
    INTO photo_count
    FROM ownerview_gh_attachment_links al
    WHERE al.parent_type = 'inventory_movement' 
      AND al.parent_id = NEW.id;
    
    -- Block if insufficient photos
    IF photo_count < required_photos THEN
      RAISE EXCEPTION 'Adjustment requires % photo(s). Only % attached. Reason: %', 
        required_photos, 
        photo_count, 
        COALESCE(NEW.reason_code, 'NONE');
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_adjustment_photos
  BEFORE UPDATE OF status ON ownerview_gh_inventory_movements
  FOR EACH ROW
  EXECUTE FUNCTION check_adjustment_photo_requirement();

-- ============================================================================
-- TRIGGER: Theft suspected requires manager approval
-- ============================================================================

CREATE OR REPLACE FUNCTION check_theft_suspected_approval()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.movement_type = 'ADJUSTMENT'
     AND NEW.reason_code = 'THEFT_SUSPECTED'
     AND NEW.status = 'POSTED'
     AND NEW.approved_by IS NULL THEN
    RAISE EXCEPTION 'Theft suspected adjustments require manager approval before posting';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_theft_approval
  BEFORE UPDATE OF status ON ownerview_gh_inventory_movements
  FOR EACH ROW
  EXECUTE FUNCTION check_theft_suspected_approval();

-- ============================================================================
-- TRIGGER: Create alert for theft suspected
-- ============================================================================

CREATE OR REPLACE FUNCTION alert_on_theft_suspected()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.movement_type = 'ADJUSTMENT' 
     AND NEW.reason_code = 'THEFT_SUSPECTED' THEN
    INSERT INTO ownerview_gh_alerts (
      org_id,
      location_id,
      alert_type,
      severity,
      title,
      description,
      related_entity_type,
      related_entity_id
    ) VALUES (
      NEW.org_id,
      NEW.location_id,
      'THEFT_SUSPECTED',
      'HIGH',
      'Theft Suspected Adjustment Submitted',
      format('User %s submitted theft suspected adjustment for item at location', NEW.created_by),
      'inventory_movement',
      NEW.id
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER alert_theft
  AFTER INSERT ON ownerview_gh_inventory_movements
  FOR EACH ROW
  EXECUTE FUNCTION alert_on_theft_suspected();

-- ============================================================================
-- TRIGGER: Clearing claim photo requirement (total > threshold)
-- ============================================================================

CREATE OR REPLACE FUNCTION check_clearing_claim_photos()
RETURNS TRIGGER AS $$
DECLARE
  photo_count INTEGER;
  threshold DECIMAL;
  org_settings JSONB;
BEGIN
  IF NEW.status IN ('SUBMITTED', 'APPROVED') 
     AND (OLD.status IS NULL OR OLD.status = 'DRAFT') THEN
    
    -- Get org threshold
    SELECT settings INTO ownerview_gh_org_settings 
    FROM ownerview_gh_org_settings
    WHERE org_id = NEW.org_id;
    
    threshold := COALESCE(
      (org_settings->>'clearing_photo_threshold_ghs')::DECIMAL, 
      500
    );
    
    -- Check if total exceeds threshold
    IF NEW.total_amount > threshold THEN
      -- Count attached documents
      SELECT COUNT(*)
      INTO photo_count
      FROM ownerview_gh_attachment_links al
      WHERE al.parent_type = 'clearing_claim' 
        AND al.parent_id = NEW.id;
      
      IF photo_count < 1 THEN
        RAISE EXCEPTION 'Clearing claim total %.2f GHS exceeds threshold %.2f GHS. At least 1 document required.',
          NEW.total_amount, 
          threshold;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_clearing_photos
  BEFORE UPDATE OF status ON ownerview_gh_clearing_claims
  FOR EACH ROW
  EXECUTE FUNCTION check_clearing_claim_photos();

-- ============================================================================
-- TRIGGER: Compute clearing claim total from lines
-- ============================================================================

CREATE OR REPLACE FUNCTION update_clearing_claim_total()
RETURNS TRIGGER AS $$
DECLARE
  claim_id_to_update UUID;
BEGIN
  -- Determine which claim to update
  IF TG_OP = 'DELETE' THEN
    claim_id_to_update := OLD.claim_id;
  ELSE
    claim_id_to_update := NEW.claim_id;
  END IF;
  
  -- Update the claim total
  UPDATE ownerview_gh_clearing_claims
  SET 
    total_amount = (
      SELECT COALESCE(SUM(amount), 0)
      FROM ownerview_gh_clearing_claim_lines
      WHERE claim_id = claim_id_to_update
    ),
    updated_at = now()
  WHERE id = claim_id_to_update;
  
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_claim_total
  AFTER INSERT OR UPDATE OR DELETE ON ownerview_gh_clearing_claim_lines
  FOR EACH ROW
  EXECUTE FUNCTION update_clearing_claim_total();

-- ============================================================================
-- TRIGGER: Compute sales total from lines
-- ============================================================================

CREATE OR REPLACE FUNCTION update_sales_total()
RETURNS TRIGGER AS $$
DECLARE
  sale_id_to_update UUID;
BEGIN
  -- Determine which sale to update
  IF TG_OP = 'DELETE' THEN
    sale_id_to_update := OLD.sale_id;
  ELSE
    sale_id_to_update := NEW.sale_id;
  END IF;
  
  -- Update the sale totals
  UPDATE ownerview_gh_sales
  SET 
    subtotal = (
      SELECT COALESCE(SUM(line_total), 0)
      FROM ownerview_gh_sales_lines
      WHERE sale_id = sale_id_to_update
    ),
    total = (
      SELECT COALESCE(SUM(line_total), 0)
      FROM ownerview_gh_sales_lines
      WHERE sale_id = sale_id_to_update
    ) + COALESCE(tax, 0),
    updated_at = now()
  WHERE id = sale_id_to_update;
  
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_sale_total
  AFTER INSERT OR UPDATE OR DELETE ON ownerview_gh_sales_lines
  FOR EACH ROW
  EXECUTE FUNCTION update_sales_total();

-- ============================================================================
-- TRIGGER: Audit log for sensitive tables
-- ============================================================================

CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
DECLARE
  org_id_value UUID;
BEGIN
  -- Get org_id from the appropriate record
  IF TG_OP = 'DELETE' THEN
    org_id_value := OLD.org_id;
  ELSE
    org_id_value := NEW.org_id;
  END IF;
  
  -- Log the change
  IF TG_OP = 'UPDATE' THEN
    INSERT INTO ownerview_gh_audit_log (
      org_id, 
      table_name, 
      record_id, 
      action, 
      old_data, 
      new_data, 
      changed_by
    ) VALUES (
      org_id_value,
      TG_TABLE_NAME,
      NEW.id,
      'UPDATE',
      to_jsonb(OLD),
      to_jsonb(NEW),
      auth.uid()
    );
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO ownerview_gh_audit_log (
      org_id, 
      table_name, 
      record_id, 
      action, 
      old_data, 
      changed_by
    ) VALUES (
      org_id_value,
      TG_TABLE_NAME,
      OLD.id,
      'DELETE',
      to_jsonb(OLD),
      auth.uid()
    );
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO ownerview_gh_audit_log (
      org_id, 
      table_name, 
      record_id, 
      action, 
      new_data, 
      changed_by
    ) VALUES (
      org_id_value,
      TG_TABLE_NAME,
      NEW.id,
      'INSERT',
      to_jsonb(NEW),
      auth.uid()
    );
  END IF;
  
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Apply audit logging to sensitive tables
CREATE TRIGGER audit_inventory_movements
  AFTER INSERT OR UPDATE OR DELETE ON ownerview_gh_inventory_movements
  FOR EACH ROW
  EXECUTE FUNCTION log_changes();

CREATE TRIGGER audit_expenses
  AFTER INSERT OR UPDATE OR DELETE ON ownerview_gh_expenses
  FOR EACH ROW
  EXECUTE FUNCTION log_changes();

CREATE TRIGGER audit_clearing_claims
  AFTER INSERT OR UPDATE OR DELETE ON ownerview_gh_clearing_claims
  FOR EACH ROW
  EXECUTE FUNCTION log_changes();

CREATE TRIGGER audit_sales
  AFTER INSERT OR UPDATE OR DELETE ON ownerview_gh_sales
  FOR EACH ROW
  EXECUTE FUNCTION log_changes();

-- ============================================================================
-- TRIGGER: Update timestamps
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables with updated_at columns
CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_organizations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_locations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_user_memberships
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_inventory_movements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_shipments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_clearing_claims
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_sales
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_alerts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON ownerview_gh_org_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCTION: Refresh materialized view
-- ============================================================================

CREATE OR REPLACE FUNCTION refresh_daily_summary()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY daily_summary_by_location;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCTION: Calculate inventory balance
-- ============================================================================

CREATE OR REPLACE FUNCTION get_inventory_balance(
  p_item_id UUID,
  p_location_id UUID,
  p_as_of_date TIMESTAMPTZ DEFAULT now()
)
RETURNS DECIMAL AS $$
DECLARE
  balance DECIMAL;
BEGIN
  SELECT COALESCE(
    SUM(
      CASE 
        WHEN movement_type IN ('RECEIVE', 'TRANSFER_IN', 'ADJUSTMENT') 
        THEN quantity
        WHEN movement_type IN ('ISSUE', 'TRANSFER_OUT') 
        THEN -quantity
        ELSE 0
      END
    ),
    0
  )
  INTO balance
  FROM ownerview_gh_inventory_movements
  WHERE item_id = p_item_id
    AND location_id = p_location_id
    AND status = 'POSTED'
    AND created_at <= p_as_of_date;
  
  RETURN balance;
END;
$$ LANGUAGE plpgsql;
