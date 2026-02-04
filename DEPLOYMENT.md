# Deployment Guide - OwnerView Ghana

This guide covers deploying the OwnerView Ghana application to Vercel (recommended for Next.js + Supabase projects).

## Prerequisites

Before deploying, ensure you have:

1. ✅ **Supabase Project** configured and running
2. ✅ **Database Migrations** applied successfully
3. ✅ **GitHub Repository** with latest code
4. ✅ **Vercel Account** (free tier works)

## Step 1: Configure Supabase

### 1.1 Create Supabase Project

1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Fill in details:
   - **Name**: ownerview-ghana
   - **Database Password**: (generate secure password)
   - **Region**: Choose closest to Ghana (EU Frankfurt or US East)
   - **Pricing Plan**: Free tier is sufficient to start

4. Wait for project to be ready (~2 minutes)

### 1.2 Get Supabase Credentials

From your Supabase project dashboard:

1. Go to **Project Settings** → **API**
2. Copy these values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Anon (public) key**: `eyJhbG...` (starts with eyJ)
   - **Service role key**: `eyJhbG...` (different from anon key)

⚠️ **Keep these secure!** Never commit to git.

### 1.3 Run Database Migrations

**Option A: Using Supabase SQL Editor (Recommended for first-time)**

1. Go to **SQL Editor** in Supabase Dashboard
2. Create new query
3. Copy and paste each migration file in order:

```sql
-- 1. Run: supabase/migrations/20240101000001_initial_schema.sql
-- (Copy entire content and execute)

-- 2. Run: supabase/migrations/20240101000002_rls_policies.sql
-- (Copy entire content and execute)

-- 3. Run: supabase/migrations/20240101000003_triggers_and_functions.sql
-- (Copy entire content and execute)

-- 4. Run: supabase/migrations/20240101000004_seed_ghana_towns.sql
-- (Copy entire content and execute)

-- 5. Run: supabase/migrations/20240101000005_demo_data.sql
-- (Copy entire content and execute)
```

4. Verify tables created: Go to **Table Editor** and confirm all tables exist

**Option B: Using Supabase CLI**

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

### 1.4 Verify Database Setup

Check in Supabase Dashboard:

1. **Table Editor**: Verify all 18+ tables exist
2. **Database** → **Policies**: Verify RLS policies are active
3. **Storage**: Verify "attachments" bucket exists

## Step 2: Push Code to GitHub

### 2.1 Create GitHub Repository

1. Go to https://github.com/new
2. Create repository:
   - **Name**: ownerview-ghana
   - **Visibility**: Private (recommended)
   - **Do NOT initialize** with README, .gitignore, or license

### 2.2 Push Code

```bash
# Ensure you're in the project directory
cd /home/user/webapp

# Add GitHub remote (replace with your URL)
git remote add origin https://github.com/yourusername/ownerview-ghana.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Deploy to Vercel

### 3.1 Connect to Vercel

1. Go to https://vercel.com
2. Sign in with your GitHub account
3. Click **"Add New..."** → **"Project"**
4. **Import Git Repository**:
   - Find and select `ownerview-ghana`
   - Click **Import**

### 3.2 Configure Project

Vercel will auto-detect Next.js. Verify settings:

- **Framework Preset**: Next.js
- **Root Directory**: ./
- **Build Command**: `npm run build`
- **Output Directory**: `.next` (auto-detected)
- **Install Command**: `npm install`
- **Development Command**: `npm run dev`

### 3.3 Add Environment Variables

Click **"Environment Variables"** and add:

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# App Configuration (optional)
NEXT_PUBLIC_APP_NAME=OwnerView Ghana
NEXT_PUBLIC_APP_URL=https://your-project.vercel.app
```

⚠️ **Important**:
- Add all three Supabase variables
- Select **"Production"**, **"Preview"**, and **"Development"** for each
- Do NOT commit these to git

### 3.4 Deploy

1. Click **"Deploy"**
2. Wait for build to complete (~2-5 minutes)
3. Vercel will provide URLs:
   - **Production**: `https://ownerview-ghana.vercel.app`
   - **Preview**: `https://ownerview-ghana-git-main-username.vercel.app`

## Step 4: Post-Deployment Configuration

### 4.1 Update Supabase Auth Settings

1. Go to Supabase Dashboard → **Authentication** → **URL Configuration**
2. Add your Vercel URLs to **Site URL**:
   ```
   https://your-project.vercel.app
   ```
3. Add to **Redirect URLs**:
   ```
   https://your-project.vercel.app/**
   https://*.vercel.app/**
   ```

### 4.2 Test the Deployment

1. Visit your production URL
2. Test user signup:
   - Go to `/signup`
   - Create a test account
   - Should receive confirmation email (if email enabled)

3. Test login:
   - Go to `/login`
   - Sign in with test account
   - Should redirect to `/dashboard`

4. Verify database connection:
   - Dashboard should load without errors
   - Check browser console for errors

### 4.3 Create First Organization

Since this is a fresh deployment, you need to set up the organization:

1. In Supabase Dashboard → **SQL Editor**, run:

```sql
-- Get your user ID first
SELECT id, email FROM auth.users;

-- Create organization
INSERT INTO organizations (id, name, slug, currency)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Ghana Multi-Business Holdings',
  'ghana-multi-biz',
  'GHS'
);

-- Add yourself as OWNER (replace <your-user-id>)
INSERT INTO user_memberships (
  user_id, 
  org_id, 
  role, 
  can_manage_settings, 
  active
) VALUES (
  '<your-user-id>',
  '00000000-0000-0000-0000-000000000001',
  'OWNER',
  true,
  true
);

-- Create org settings
INSERT INTO org_settings (org_id)
VALUES ('00000000-0000-0000-0000-000000000001');
```

2. Refresh your dashboard - you should now see "OWNER" role

## Step 5: Custom Domain (Optional)

### 5.1 Add Domain in Vercel

1. Go to your project in Vercel
2. Click **"Settings"** → **"Domains"**
3. Click **"Add Domain"**
4. Enter your domain (e.g., `ownerview.gh`)
5. Vercel will show DNS configuration instructions

### 5.2 Configure DNS

Add these records to your DNS provider:

**For root domain** (`ownerview.gh`):
```
Type: A
Name: @
Value: 76.76.21.21
```

**For www subdomain**:
```
Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

### 5.3 Update Supabase URLs

Add your custom domain to Supabase Auth settings (Step 4.1).

## Troubleshooting

### Build Fails

**Error**: `Module not found`
- **Fix**: Check `package.json` dependencies
- Run `npm install` locally to verify
- Check build logs for specific missing module

**Error**: `TypeScript error in build`
- **Fix**: Run `npm run build` locally first
- Fix TypeScript errors before deploying
- Check `tsconfig.json` configuration

### Environment Variables Not Working

**Symptom**: `undefined` errors in console
- **Fix**: Verify environment variables in Vercel:
  - Settings → Environment Variables
  - Ensure variables start with `NEXT_PUBLIC_` for client-side
  - Redeploy after adding variables

### Authentication Not Working

**Symptom**: Cannot login or signup
- **Fix**: Check Supabase:
  - Verify `NEXT_PUBLIC_SUPABASE_URL` is correct
  - Check Auth → URL Configuration includes Vercel URLs
  - Verify RLS policies are enabled

### Database Connection Error

**Symptom**: "Failed to fetch" or database errors
- **Fix**: 
  - Verify Supabase credentials in environment variables
  - Check Supabase project is active (not paused)
  - Verify RLS policies allow access
  - Check user has `user_membership` record

### Photos Not Uploading

**Symptom**: File upload fails
- **Fix**:
  - Verify Storage bucket "attachments" exists
  - Check Storage RLS policies (see migration 20240101000002)
  - Verify file size is under limit (50MB default)

## Maintenance

### Updating the Application

```bash
# Make changes locally
git add .
git commit -m "Your changes"
git push origin main

# Vercel auto-deploys on push to main branch
```

### Database Schema Updates

For future schema changes:

1. Create new migration file: `supabase/migrations/YYYYMMDD_description.sql`
2. Test locally first
3. Apply to production via Supabase SQL Editor
4. Document changes in commit message

### Monitoring

**Vercel Dashboard**:
- **Analytics**: Page views, user engagement
- **Logs**: Runtime errors and warnings
- **Speed Insights**: Performance metrics

**Supabase Dashboard**:
- **Database**: Table sizes, query performance
- **Auth**: User signups, login activity
- **Storage**: File usage and bandwidth

### Backup Strategy

**Automated**:
- Supabase automatically backs up database daily
- Vercel maintains deployment history

**Manual**:
```bash
# Export database
supabase db dump -f backup.sql

# Or use Supabase Dashboard → Database → Backups
```

## Security Checklist

Before going to production:

- [ ] All environment variables are set in Vercel (not in code)
- [ ] `.env.local` is in `.gitignore` (it is)
- [ ] RLS policies are enabled on all tables
- [ ] Supabase service role key is kept secret
- [ ] Auth redirect URLs are properly configured
- [ ] Password requirements are enforced (6+ characters)
- [ ] API routes are protected by middleware
- [ ] File upload limits are configured
- [ ] CORS is properly configured
- [ ] Database backup strategy is in place

## Production Checklist

- [ ] Supabase project created and configured
- [ ] All 5 database migrations applied successfully
- [ ] Environment variables added to Vercel
- [ ] Application deployed to Vercel
- [ ] Custom domain configured (optional)
- [ ] First organization and owner user created
- [ ] Authentication tested (signup/login)
- [ ] Dashboard loads correctly
- [ ] Photo upload tested (when feature implemented)
- [ ] Mobile responsive design verified
- [ ] PWA installation tested on mobile device

## Support

For deployment issues:

1. **Vercel Support**: https://vercel.com/support
2. **Supabase Support**: https://supabase.com/support
3. **Next.js Docs**: https://nextjs.org/docs

## Next Steps

After successful deployment:

1. ✅ **Invite Team Members**: Create accounts for managers and staff
2. ✅ **Configure Organization Settings**: Set thresholds and rules
3. ✅ **Add Locations**: Create business locations in Ghana
4. ✅ **Import Items**: Add product catalog
5. ✅ **Train Users**: Onboard staff to the system

---

**Deployment complete! Your OwnerView Ghana system is now live. 🚀**
