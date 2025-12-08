# Cloudflare KV Sync Setup Guide

## Prerequisites

1. A Cloudflare account
2. An active Cloudflare KV namespace

## Setup Steps

### 1. Create KV Namespace

1. Log in to Cloudflare Dashboard
2. Go to Workers & Pages → KV
3. Click "Create a namespace"
4. Give it a name (e.g., "cardio-tracker-sync")
5. Copy the Namespace ID

### 2. Get API Token

1. Go to My Profile → API Tokens
2. Click "Create Token"
3. Use "Custom token" template
4. Set permissions:
   - Account: `Cloudflare KV:Edit`
   - Account Resources: Include your account
5. Copy the generated token

### 3. Configure in App

1. Open Cardio Tracker app
2. Go to Settings → Cloudflare Sync
3. Enter:
   - Account ID (from Cloudflare dashboard URL)
   - Namespace ID (from step 1)
   - API Token (from step 2)
4. Tap "Save"

### 4. Sync Your Data

1. Tap "Sync Now" button
2. Wait for sync to complete
3. Check sync results

## Sync Behavior

- Manual sync only (user triggered)
- Last-write-wins conflict resolution
- Soft deletes (deleted items stay for 30 days)
- All data encrypted in transit (HTTPS)

## Troubleshooting

- **"Not configured" error**: Check all credentials are entered correctly
- **Sync fails**: Verify API token has KV:Edit permission
- **Partial sync**: Check network connection and try again

## Privacy

- Data is stored in Cloudflare's global network
- Data encrypted at rest in KV
- Only you have access with your API token