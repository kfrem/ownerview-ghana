#!/usr/bin/env python3
"""
Add 'ownerview_gh_' prefix to all tables in SQL migration files
This ensures tables don't conflict with other projects in the same Supabase instance
"""

import re
import sys
from pathlib import Path

# Table names to be prefixed
TABLES = [
    'organizations',
    'business_lines',
    'towns',
    'locations',
    'user_memberships',
    'items',
    'inventory_movements',
    'attachments',
    'attachment_links',
    'expenses',
    'shipments',
    'clearing_claims',
    'clearing_claim_lines',
    'sales',
    'sales_lines',
    'alerts',
    'audit_log',
    'org_settings',
    'daily_summary_by_location'  # materialized view
]

PREFIX = 'ownerview_gh_'

def add_prefix_to_sql(content):
    """Add prefix to all table references in SQL content"""
    
    for table in TABLES:
        # CREATE TABLE statements
        content = re.sub(
            rf'\bCREATE TABLE {table}\b',
            f'CREATE TABLE {PREFIX}{table}',
            content,
            flags=re.IGNORECASE
        )
        
        # CREATE MATERIALIZED VIEW
        content = re.sub(
            rf'\bCREATE MATERIALIZED VIEW {table}\b',
            f'CREATE MATERIALIZED VIEW {PREFIX}{table}',
            content,
            flags=re.IGNORECASE
        )
        
        # ALTER TABLE statements
        content = re.sub(
            rf'\bALTER TABLE {table}\b',
            f'ALTER TABLE {PREFIX}{table}',
            content,
            flags=re.IGNORECASE
        )
        
        # CREATE POLICY statements
        content = re.sub(
            rf'\bON {table}\b',
            f'ON {PREFIX}{table}',
            content
        )
        
        # REFERENCES statements
        content = re.sub(
            rf'\bREFERENCES {table}\(',
            f'REFERENCES {PREFIX}{table}(',
            content,
            flags=re.IGNORECASE
        )
        
        # FROM statements
        content = re.sub(
            rf'\bFROM {table}\b',
            f'FROM {PREFIX}{table}',
            content,
            flags=re.IGNORECASE
        )
        
        # JOIN statements
        content = re.sub(
            rf'\bJOIN {table}\b',
            f'JOIN {PREFIX}{table}',
            content,
            flags=re.IGNORECASE
        )
        
        # INTO statements
        content = re.sub(
            rf'\bINTO {table}\b',
            f'INTO {PREFIX}{table}',
            content,
            flags=re.IGNORECASE
        )
        
        # UPDATE statements
        content = re.sub(
            rf'\bUPDATE {table}\b',
            f'UPDATE {PREFIX}{table}',
            content,
            flags=re.IGNORECASE
        )
        
        # CREATE INDEX statements (both with and without name)
        content = re.sub(
            rf'\bCREATE INDEX ([^ ]*) ON {table}\(',
            rf'CREATE INDEX \1 ON {PREFIX}{table}(',
            content,
            flags=re.IGNORECASE
        )
        
        content = re.sub(
            rf'\bCREATE UNIQUE INDEX ON {table}\(',
            f'CREATE UNIQUE INDEX ON {PREFIX}{table}(',
            content,
            flags=re.IGNORECASE
        )
        
        # Index names themselves
        content = re.sub(
            rf'\bCREATE INDEX idx_{table}_',
            f'CREATE INDEX idx_{PREFIX}{table}_',
            content,
            flags=re.IGNORECASE
        )
    
    return content

def main():
    migrations_dir = Path(__file__).parent.parent / 'supabase' / 'migrations'
    
    # Process backup files
    backup_files = list(migrations_dir.glob('*.sql.backup'))
    
    if not backup_files:
        print("No .sql.backup files found!")
        sys.exit(1)
    
    for backup_file in sorted(backup_files):
        print(f"Processing {backup_file.name}...")
        
        # Read backup content
        content = backup_file.read_text()
        
        # Add prefixes
        new_content = add_prefix_to_sql(content)
        
        # Write to new file (remove .backup extension)
        new_file = backup_file.with_suffix('')
        new_file.write_text(new_content)
        
        print(f"  ✅ Created {new_file.name}")
    
    print(f"\n✅ Successfully prefixed all tables with '{PREFIX}'")
    print(f"✅ Processed {len(backup_files)} migration files")

if __name__ == '__main__':
    main()
