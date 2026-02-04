# OwnerView Ghana - Table Prefix System

## ⚠️ IMPORTANT: Unique Table Naming

All database tables for OwnerView Ghana are prefixed with **`ownerview_gh_`** to ensure they **never conflict** with other projects in the same Supabase instance.

---

## 🎯 Why This Prefix System?

### Problem
If you have **multiple business applications** in one Supabase project:
- Tables from different apps might have the same names (e.g., `orders`, `users`, `items`)
- This causes conflicts and data mixing
- You can't tell which table belongs to which application

### Solution
**All OwnerView Ghana tables use the `ownerview_gh_` prefix:**
- `ownerview_gh_organizations`
- `ownerview_gh_items`
- `ownerview_gh_inventory_movements`
- `ownerview_gh_sales`
- etc.

This ensures **complete isolation** from other projects sharing the same Supabase database.

---

## 📋 Complete Table List

### Core Tables (18 total)

| Prefixed Table Name | Purpose |
|---------------------|---------|
| `ownerview_gh_organizations` | Business entities |
| `ownerview_gh_business_lines` | Heavy Machinery, Spare Parts, Mining |
| `ownerview_gh_towns` | Ghana towns reference (60+ towns) |
| `ownerview_gh_locations` | Physical business locations |
| `ownerview_gh_user_memberships` | Role-based user access |
| `ownerview_gh_items` | Product catalog |
| `ownerview_gh_inventory_movements` | All inventory transactions |
| `ownerview_gh_attachments` | File storage references |
| `ownerview_gh_attachment_links` | Links files to records |
| `ownerview_gh_expenses` | Business expenses |
| `ownerview_gh_shipments` | Import shipments |
| `ownerview_gh_clearing_claims` | Clearing agent claims |
| `ownerview_gh_clearing_claim_lines` | Claim line items |
| `ownerview_gh_sales` | Sales transactions |
| `ownerview_gh_sales_lines` | Sale line items |
| `ownerview_gh_alerts` | System alerts |
| `ownerview_gh_audit_log` | Complete change history |
| `ownerview_gh_org_settings` | Owner-configurable settings |

### Materialized Views (1 total)

| Prefixed View Name | Purpose |
|--------------------|---------|
| `ownerview_gh_daily_summary_by_location` | Dashboard aggregated data |

### Indexes

All indexes are also prefixed:
- `idx_ownerview_gh_user_memberships_user_id`
- `idx_ownerview_gh_locations_org_id`
- `idx_ownerview_gh_items_org_id`
- etc.

---

## 🚀 Running Migrations

### Step 1: Open Supabase SQL Editor
1. Go to https://supabase.com/dashboard
2. Select your project
3. Navigate to **SQL Editor**

### Step 2: Run Migration Files in Order

Copy and paste each file's content into the SQL Editor and execute:

1. **`20240101000001_initial_schema.sql`** (3 minutes)
   - Creates all 18 tables with `ownerview_gh_` prefix
   - Creates indexes
   - Creates materialized view

2. **`20240101000002_rls_policies.sql`** (2 minutes)
   - Enables Row Level Security on all tables
   - Creates security policies

3. **`20240101000003_triggers_and_functions.sql`** (2 minutes)
   - Creates database functions
   - Creates triggers for business logic

4. **`20240101000004_seed_ghana_towns.sql`** (1 minute)
   - Inserts 60+ Ghana towns into `ownerview_gh_towns`

5. **`20240101000005_demo_data.sql`** (1 minute)
   - Inserts demo organization and test data

**Total Time**: ~10 minutes

### Step 3: Verify Tables Created

In Supabase Dashboard → **Table Editor**, you should see:
- ✅ 18 tables starting with `ownerview_gh_`
- ✅ All tables have green RLS badge (security enabled)
- ✅ Data in `ownerview_gh_towns` table (60+ rows)

---

## 🔍 Querying the Database

### In Your Application Code

When querying from your Next.js app, use the **full prefixed table names**:

```typescript
// ✅ CORRECT - Use prefixed names
const { data } = await supabase
  .from('ownerview_gh_organizations')
  .select('*')

const { data } = await supabase
  .from('ownerview_gh_items')
  .select('*')

const { data } = await supabase
  .from('ownerview_gh_inventory_movements')
  .select(`
    *,
    ownerview_gh_locations(name),
    ownerview_gh_items(name)
  `)
```

```typescript
// ❌ WRONG - Without prefix (table not found)
const { data } = await supabase
  .from('organizations')  // ❌ This table doesn't exist
  .select('*')
```

### In SQL Editor

```sql
-- ✅ CORRECT - Use prefixed names
SELECT * FROM ownerview_gh_organizations;

SELECT * FROM ownerview_gh_items 
WHERE org_id = 'some-uuid';

-- Check RLS policies
SELECT tablename, policyname 
FROM pg_policies 
WHERE tablename LIKE 'ownerview_gh_%';
```

---

## 🛡️ Benefits of This System

### 1. **Zero Conflicts**
- Run multiple business apps in one Supabase project
- Tables never overlap or mix data
- Clean separation of concerns

### 2. **Clear Ownership**
- Instantly identify which tables belong to OwnerView Ghana
- Easy to filter in SQL queries: `WHERE tablename LIKE 'ownerview_gh_%'`
- Simplifies database management

### 3. **Safe Migrations**
- Other projects' migrations won't affect OwnerView tables
- Can drop all OwnerView tables easily if needed:
  ```sql
  -- Drop all OwnerView Ghana tables (be careful!)
  DROP TABLE IF EXISTS ownerview_gh_organizations CASCADE;
  DROP TABLE IF EXISTS ownerview_gh_business_lines CASCADE;
  -- ... etc
  ```

### 4. **Better Organization**
- Professional naming convention
- Follows multi-tenant best practices
- Easier debugging and maintenance

---

## 🔧 Maintenance

### Updating the Prefix Script

If you need to change the prefix (e.g., from `ownerview_gh_` to `ov_ghana_`):

1. Edit `scripts/add_table_prefix.py`
2. Change the `PREFIX` variable
3. Re-run the script on backup files

### Adding New Tables

When creating new tables, **always use the prefix**:

```sql
-- ✅ CORRECT
CREATE TABLE ownerview_gh_new_feature (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID REFERENCES ownerview_gh_organizations(id),
  ...
);

-- ❌ WRONG
CREATE TABLE new_feature (  -- Missing prefix!
  ...
);
```

---

## 📊 Table Statistics

| Metric | Count |
|--------|-------|
| **Total Tables** | 18 |
| **Materialized Views** | 1 |
| **Indexes** | 15+ |
| **RLS Policies** | 30+ |
| **Database Triggers** | 5 |
| **Functions** | 3 |

---

## 🎯 Summary

✅ **All OwnerView Ghana tables use `ownerview_gh_` prefix**  
✅ **Zero conflicts with other projects**  
✅ **Clean, organized database structure**  
✅ **Professional multi-tenant design**  
✅ **Easy to maintain and debug**

---

## 🆘 Troubleshooting

### "Table doesn't exist" Error

**Problem**: `relation "organizations" does not exist`

**Solution**: Use the full prefixed name:
```typescript
// Change this:
.from('organizations')

// To this:
.from('ownerview_gh_organizations')
```

### Can't Find Tables in Supabase Dashboard

**Problem**: Tables not showing up

**Solution**: 
1. Check you ran all migration files
2. Refresh the Table Editor page
3. Look for tables starting with `ownerview_gh_`

### RLS Policies Not Working

**Problem**: "Row Level Security policy violation"

**Solution**: 
1. Verify user has `ownerview_gh_user_memberships` record
2. Check policies reference correct prefixed tables
3. Review migration file `20240101000002_rls_policies.sql`

---

**Last Updated**: February 4, 2026  
**Prefix**: `ownerview_gh_`  
**Total Tables**: 18 core + 1 materialized view
