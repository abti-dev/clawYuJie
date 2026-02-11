#!/bin/bash
# clawYuJie.sh
# Generate an image with Doubao Seedream and send it via OpenClaw
#
# Usage: ./clawYuJie.sh "<prompt>" "<channel>" ["<caption>"]
#
# Environment variables required:
#   ARK_API_KEY - Your Volcengine Ark API key
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check required environment variables
if [ -z "${ARK_API_KEY:-}" ]; then
    log_error "ARK_API_KEY environment variable not set"
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    log_error "jq is required but not installed"
    echo "Install with: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
fi

# Check for openclaw
if ! command -v openclaw &> /dev/null; then
    log_warn "openclaw CLI not found - will attempt direct API call"
    USE_CLI=false
else
    USE_CLI=true
fi

# Parse arguments
PROMPT="${1:-}"
CHANNEL="${2:-}"
CAPTION="${3:-Generated with Doubao Seedream}"

if [ -z "$PROMPT" ] || [ -z "$CHANNEL" ]; then
    echo "Usage: $0 <prompt> <channel> [caption]"
    exit 1
fi

log_info "Generating image with Doubao Seedream..."
log_info "Prompt: $PROMPT"

# Generate image via Volcengine
# Note: "sequential_image_generation": "disabled" is passed as string in user example? or boolean?
# User example: "sequential_image_generation": "disabled"
# Also "stream": false
RESPONSE=$(curl -s -X POST "https://ark.cn-beijing.volces.com/api/v3/images/generations" \
   -H "Content-Type: application/json" \
   -H "Authorization: Bearer $ARK_API_KEY" \
   -d "{ 
     \"model\": \"doubao-seedream-4-5-251128\", 
     \"prompt\": $(echo "$PROMPT" | jq -Rs .), 
     \"sequential_image_generation\": \"disabled\", 
     \"response_format\": \"url\", 
     \"size\": \"2K\", 
     \"stream\": false, 
     \"watermark\": true 
 }")

# Debug response
# echo "DEBUG: $RESPONSE"

# Check for errors in response
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message // "Unknown error"')
    log_error "Image generation failed: $ERROR_MSG"
    exit 1
fi

# Extract image URL
# Volcengine/OpenAI compatible structure: data[0].url
IMAGE_URL=$(echo "$RESPONSE" | jq -r '.data[0].url // empty')

if [ -z "$IMAGE_URL" ]; then
    log_error "No image URL found in response"
    echo "$RESPONSE"
    exit 1
fi

log_info "Image generated: $IMAGE_URL"
log_info "Sending to channel: $CHANNEL"

# Send via OpenClaw
if [ "$USE_CLI" = true ]; then
    openclaw message send --action send --channel "$CHANNEL" --message "$CAPTION" --media "$IMAGE_URL"
else
    # Fallback to direct API call if needed
    log_warn "Direct API call not fully implemented in this script version, please install openclaw CLI"
fi

log_info "Done!"
