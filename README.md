# OwnerView Ghana - Inventory and Clearing Compliance System

A mobile-first Progressive Web App (PWA) for managing multi-business operations in Ghana, including heavy machinery imports, car spare parts, and mining operations.

## 📋 Overview

**Project**: OwnerView Ghana  
**Tech Stack**: Next.js 15, TypeScript, Tailwind CSS, Supabase  
**Deployment**: Vercel (recommended)  
**Status**: ✅ Initial Setup Complete - Ready for Supabase Configuration

## ⚠️ IMPORTANT: Database Table Prefix

**All database tables use the prefix `ownerview_gh_`** to prevent conflicts when running multiple projects in the same Supabase instance.

- ✅ Example: `ownerview_gh_organizations`, `ownerview_gh_items`, `ownerview_gh_sales`
- 📚 **See**: `TABLE_PREFIX_SUMMARY.md` for complete guide
- 🔧 **See**: `DATABASE_TABLE_PREFIX_GUIDE.md` for developer documentation

### Currently Completed Features

- ✅ **Project Setup**: Next.js 15 with TypeScript and Tailwind CSS
- ✅ **Database Schema**: Complete PostgreSQL schema with all tables
- ✅ **Row Level Security (RLS)**: Comprehensive security policies
- ✅ **Database Triggers**: Photo enforcement, auto-calculations, audit logging
- ✅ **Authentication**: Email/password signup and login
- ✅ **Dashboard Layout**: Mobile-first responsive layout with bottom navigation
- ✅ **Owner Dashboard**: Role-based dashboard with quick actions
- ✅ **PWA Configuration**: Progressive Web App setup with manifest

### Functional Entry URIs (Paths and Parameters)

**Authentication**:
- `GET /login` - User login page
- `GET /signup` - New user registration
- Query params: `?redirect=/path` - Redirect after successful login

**Dashboard**:
- `GET /dashboard` - Owner/Manager home page (requires authentication)
- Shows role-based stats, recent activity, quick actions

**Inventory Management** (Placeholder):
- `GET /inventory` - Inventory list and levels
- `GET /inventory/adjust` - Adjustment form (will require 1-2 photos based on reason)
- `GET /inventory/movements/[id]` - Movement details

**Expenses** (Placeholder):
- `GET /expenses` - Expense list
- `GET /expenses/new` - Submit new expense (requires receipt photo)

**Clearing Claims** (Placeholder):
- `GET /clearing` - Shipments list
- `GET /clearing/new` - Create clearing claim (requires docs if >500 GHS)
- `GET /clearing/[id]` - Claim details

**Alerts** (Placeholder):
- `GET /alerts` - View all alerts (theft, shrinkage, expense spikes)

**Settings** (Placeholder):
- `GET /settings` - Owner controls and thresholds

### Features Not Yet Implemented

The following features are defined in the database schema but need UI implementation:

1. **Inventory Management**:
   - Item catalog management
   - Inventory adjustments with photo upload
   - Theft suspected reporting (requires 2 photos)
   - Stock transfers between locations
   - Inventory counting

2. **Expenses Module**:
   - Expense submission with receipt upload
   - Manager approval workflow
   - Expense spike alerts
   - Category-based tracking

3. **Shipments & Clearing**:
   - Shipment tracking
   - Clearing claim submission
   - Photo requirement enforcement (>500 GHS)
   - Owner approval workflow

4. **Alerts System**:
   - Real-time alert display
   - Alert acknowledgment and resolution
   - Push notifications

5. **Owner Settings**:
   - Configurable thresholds
   - Approval workflow settings
   - Photo requirements configuration

6. **Reports & Analytics**:
   - Sales reports by location
   - Profit/loss analysis
   - Shrinkage tracking
   - Daily summaries

### Data Models and Storage

**Primary Data Structures** (all prefixed with `ownerview_gh_`):
- **ownerview_gh_organizations**: Multi-business entity container
- **ownerview_gh_business_lines**: Heavy Machinery, Spare Parts, Mining
- **ownerview_gh_locations**: Shops, Warehouses, Mine Sites (linked to Ghana towns)
- **ownerview_gh_user_memberships**: Role-based access (OWNER, MANAGER, STAFF, etc.)
- **ownerview_gh_items**: Product catalog with SKU, pricing, risk flags
- **ownerview_gh_inventory_movements**: RECEIVE, ISSUE, ADJUSTMENT, COUNT, TRANSFER
- **ownerview_gh_attachments**: Photos and documents with links to parent records
- **ownerview_gh_expenses**: Business expenses with receipt requirements
- **ownerview_gh_shipments & ownerview_gh_clearing_claims**: Import tracking with clearing costs
- **ownerview_gh_sales**: Transaction records with line items
- **ownerview_gh_alerts**: System-generated notifications
- **ownerview_gh_audit_log**: Complete change history

**Storage Services**:
- **Database**: Supabase PostgreSQL (all structured data)
- **File Storage**: Supabase Storage (photos, receipts, documents)
- **Authentication**: Supabase Auth (email/password, JWT sessions)

**Key Business Rules** (enforced by database triggers):
- Inventory adjustments require 1 photo (2 for theft suspected)
- Clearing claims >500 GHS require documentation
- Manager approval required for theft-suspected items
- Expense approval required for amounts >1000 GHS
- Automatic alert generation for shrinkage >5%
- Audit logging on all sensitive tables

### Recommended Next Steps

1. **Configure Supabase Project**:
   - Create Supabase project at https://supabase.com
   - Run database migrations
   - Configure environment variables
   - Generate TypeScript types

2. **Implement Inventory Module**:
   - Build adjustment form with photo upload
   - Implement inventory list with filters
   - Add movement history view
   - Create theft reporting flow

3. **Build Expenses Module**:
   - Create expense submission form
   - Implement receipt upload
   - Add approval workflow
   - Build expense list with filters

4. **Develop Clearing Module**:
   - Shipment tracking interface
   - Claim submission form
   - Document upload for >500 GHS claims
   - Owner approval interface

5. **Alert System**:
   - Real-time alert display
   - Alert detail views
   - Resolution workflow
   - Push notification setup

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ and npm
- **Supabase Account** (free tier works)
- **Git**

### Installation

```bash
# Clone repository
git clone <repo-url>
cd webapp

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your Supabase credentials
```

### Supabase Setup

1. **Create Supabase Project**:
   - Go to https://supabase.com/dashboard
   - Create new project: "ownerview-ghana"
   - Choose region closest to Ghana (EU/Frankfurt recommended)
   - Note your credentials:
     - Project URL
     - Anon (public) key
     - Service role key (keep secret)

2. **Configure Environment Variables**:

Edit `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

3. **Run Database Migrations**:

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push

# Or manually via SQL Editor in Supabase Dashboard:
# - Copy and run each migration file in order:
#   - 20240101000001_initial_schema.sql
#   - 20240101000002_rls_policies.sql
#   - 20240101000003_triggers_and_functions.sql
#   - 20240101000004_seed_ghana_towns.sql
#   - 20240101000005_demo_data.sql
```

4. **Generate TypeScript Types** (optional):

```bash
npm run generate:types
```

### Development

```bash
# Start development server
npm run dev

# Open http://localhost:3000
```

### Testing

```bash
# Run unit tests
npm test

# Run e2e tests
npm run test:e2e

# Run e2e tests with UI
npm run test:e2e:ui
```

## 📦 Deployment to Vercel

### Step 1: Prepare Repository

```bash
# Ensure all changes are committed
git add .
git commit -m "Ready for Vercel deployment"

# Push to GitHub
git branch -M main
git remote add origin https://github.com/yourusername/ownerview-ghana.git
git push -u origin main
```

### Step 2: Deploy to Vercel

1. Go to https://vercel.com and sign in with GitHub
2. Click "Add New Project"
3. Import your repository
4. Configure project:
   - **Framework Preset**: Next.js
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`
   - **Install Command**: `npm install`

5. Add Environment Variables:
   ```
   NEXT_PUBLIC_SUPABASE_URL
   NEXT_PUBLIC_SUPABASE_ANON_KEY
   SUPABASE_SERVICE_ROLE_KEY
   ```

6. Click "Deploy"

### Step 3: Verify Deployment

- Production URL: `https://your-project.vercel.app`
- Test authentication and navigation
- Verify database connections

### Step 4: Configure Custom Domain (Optional)

In Vercel dashboard:
1. Go to Project Settings → Domains
2. Add your custom domain
3. Follow DNS configuration instructions

## 🗄️ Database Schema

### Core Tables (All prefixed with `ownerview_gh_`)

- **ownerview_gh_organizations** - Business entities
- **ownerview_gh_business_lines** - Heavy Machinery, Spare Parts, Mining
- **ownerview_gh_towns** - Ghana towns reference (60+ pre-seeded)
- **ownerview_gh_locations** - Physical business locations
- **ownerview_gh_user_memberships** - Role-based user access
- **ownerview_gh_items** - Product catalog
- **ownerview_gh_inventory_movements** - All inventory transactions
- **ownerview_gh_attachments** - File storage references
- **ownerview_gh_attachment_links** - Links files to records
- **ownerview_gh_expenses** - Business expenses
- **ownerview_gh_shipments** - Import shipments
- **ownerview_gh_clearing_claims** - Clearing agent claims
- **ownerview_gh_clearing_claim_lines** - Claim line items
- **ownerview_gh_sales** - Sales transactions
- **ownerview_gh_sales_lines** - Sale line items
- **ownerview_gh_alerts** - System alerts
- **ownerview_gh_audit_log** - Change history
- **ownerview_gh_org_settings** - Owner-configurable settings

**📚 Note**: The `ownerview_gh_` prefix ensures zero conflicts when running multiple projects in the same Supabase instance. See `TABLE_PREFIX_SUMMARY.md` for details.

### Key Features

- **Row Level Security (RLS)**: All tables protected by RLS policies
- **Database Triggers**: Automatic photo enforcement, calculations, alerts
- **Audit Logging**: Complete change history on sensitive tables
- **Materialized View**: Daily summaries for dashboard

## 👥 User Roles

- **OWNER**: Full access, sees all data, manages settings
- **HQ_ADMIN**: Administrative access across all locations
- **LOCATION_MANAGER**: Manages specific location
- **WAREHOUSE_STAFF**: Inventory management at location
- **SALES_STAFF**: Sales entry at location
- **CLEARING_AGENT**: Shipment and clearing claim management
- **ACCOUNTANT**: Expense review and approval

## 🔐 Security

- **Authentication**: Supabase Auth with email/password
- **Authorization**: Row Level Security (RLS) enforced at database level
- **File Storage**: Org-scoped storage buckets with RLS policies
- **Audit Trail**: All changes to sensitive data are logged
- **Photo Enforcement**: Database triggers enforce photo requirements

## 📱 PWA Features

- **Installable**: Can be installed on mobile devices
- **Offline Capable**: Service worker caches static assets
- **Mobile-First**: Optimized for phone screens
- **Bottom Navigation**: Easy thumb-friendly navigation

## 🤝 User Guide

### For Business Owners

1. **Dashboard**: View real-time business metrics across all locations
2. **Inventory**: Monitor stock levels and theft-suspected items
3. **Expenses**: Review and approve expenses, track spending patterns
4. **Clearing**: Approve clearing claims and monitor import costs
5. **Alerts**: Respond to critical business alerts
6. **Settings**: Configure thresholds and approval workflows

### For Location Managers

1. **Submit Expenses**: Upload receipts and submit for approval
2. **Adjust Inventory**: Make adjustments with photo evidence
3. **Report Issues**: Flag theft-suspected items
4. **View Reports**: Access location-specific reports

### For Warehouse Staff

1. **Receive Inventory**: Record incoming stock
2. **Issue Items**: Process sales and transfers
3. **Count Stock**: Perform periodic inventory counts
4. **Transfer Items**: Move stock between locations

## 📊 Business Rules

### Photo Requirements

- **Inventory Adjustments**: 1 photo required
- **Theft Suspected**: 2 photos required
- **Clearing Claims >500 GHS**: 1 document required
- **Expenses**: 1 receipt photo required

### Approval Workflows

- **Inventory Adjustments**: Manager approval required
- **Theft Suspected**: OWNER approval required
- **Expenses >1000 GHS**: Manager approval required
- **Clearing Claims**: OWNER approval required

### Alert Thresholds

- **Shrinkage**: Alert when >5% variance
- **Expense Spike**: Alert when >25% increase
- **Missing Reports**: Alert at 6PM if no daily report

## 🛠️ Troubleshooting

### Cannot Login

- Verify Supabase credentials in `.env.local`
- Check Supabase project is running
- Ensure user has been created via signup

### Database Connection Error

- Verify `NEXT_PUBLIC_SUPABASE_URL` is correct
- Check Supabase project status
- Ensure migrations have been run

### RLS Policy Errors

- Verify user has `user_membership` record
- Check user role assignments
- Review RLS policies in Supabase dashboard

### Photos Not Uploading

- Check storage bucket "attachments" exists
- Verify storage RLS policies are configured
- Ensure file size is under 50MB

## 📝 License

This project is proprietary software for Ghana Multi-Business Holdings.

## 🙋‍♂️ Support

For technical support, contact the development team.

---

**Built with ❤️ for Ghana Multi-Business Holdings**
