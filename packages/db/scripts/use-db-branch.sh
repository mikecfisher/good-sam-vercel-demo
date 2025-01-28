#!/bin/bash

# Your Neon project ID
PROJECT_ID="bitter-sky-63813604"

# Get branch name from git or use provided argument
BRANCH_NAME=${1:-$(git branch --show-current)}

echo "Checking branch: $BRANCH_NAME"

# Check if branch exists using direct get command
if ! neonctl branches get --project-id $PROJECT_ID "$BRANCH_NAME" --output json > /dev/null 2>&1; then
    echo "Error: Branch '$BRANCH_NAME' does not exist"
    echo "Use 'pnpm db:new <branch-name>' to create a new branch"
    exit 1
fi

# Get the connection strings directly from neonctl command output
UNPOOLED_URL=$(neonctl connection-string --project-id $PROJECT_ID "$BRANCH_NAME")
# Create pooled URL with correct format (note the position of -pooler)
POOLED_URL=${UNPOOLED_URL/@ep-/@ep-}-pooler.us-east-1.aws.neon.tech/verceldb?sslmode=require}

if [ -z "$POOLED_URL" ] || [ -z "$UNPOOLED_URL" ]; then
    echo "Error: Failed to get connection strings for branch '$BRANCH_NAME'"
    exit 1
fi

# Create a temporary file with the new connection strings
cat > ../../.env.tmp << EOL
# Parameters for Vercel Postgres Templates
POSTGRES_URL="$POOLED_URL"
POSTGRES_URL_NON_POOLING="$UNPOOLED_URL"
POSTGRES_PRISMA_URL="$POOLED_URL?pgbouncer=true&connect_timeout=15"
POSTGRES_URL_NO_SSL="${UNPOOLED_URL//?sslmode=require/}"

# For uses requiring a connection without pgbouncer
DATABASE_URL_UNPOOLED="$UNPOOLED_URL"

# Recommended for most uses
DATABASE_URL="$POOLED_URL"
EOL

# If .env exists, copy all non-database variables from it
if [ -f "../../.env" ]; then
    grep -v "^POSTGRES_\|^DATABASE_URL" ../../.env >> ../../.env.tmp
fi

# Replace .env with our new file
mv ../../.env.tmp ../../.env

echo "Successfully switched to database branch: $BRANCH_NAME" 