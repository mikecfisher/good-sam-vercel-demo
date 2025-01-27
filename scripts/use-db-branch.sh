#!/bin/bash

# Get branch name from git or use provided argument
BRANCH_NAME=${1:-$(git branch --show-current)}

# Get the connection strings
POOLED_URL=$(neon connection-string $BRANCH_NAME --pooled)
UNPOOLED_URL=$(neon connection-string $BRANCH_NAME)

# Create/update .env.local with the new connection strings
cat > .env.local << EOL
# Parameters for Vercel Postgres Templates
POSTGRES_URL="$POOLED_URL"
POSTGRES_URL_NON_POOLING="$UNPOOLED_URL"
POSTGRES_PRISMA_URL="$POOLED_URL?pgbouncer=true&connect_timeout=15"
POSTGRES_URL_NO_SSL="${POOLED_URL//?sslmode=require/}"

# For uses requiring a connection without pgbouncer
DATABASE_URL_UNPOOLED="$UNPOOLED_URL"

# Recommended for most uses
DATABASE_URL="$POOLED_URL"
EOL

# Optional: Copy other env variables from .env
grep -v "POSTGRES_\|DATABASE_URL" .env >> .env.local

echo "Switched to database branch: $BRANCH_NAME" 