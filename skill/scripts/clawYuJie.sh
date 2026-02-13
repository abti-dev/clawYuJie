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
# Default reference image is hosted on CDN
# This corresponds to local file: clawYuJie/skill/assets/yujie.png
# Using the raw content URL from GitHub for direct access
REF_IMAGE="${4:-https://raw.githubusercontent.com/abti-dev/clawYuJie/main/skill/assets/yujie.png}"

if [ -z "$PROMPT" ] || [ -z "$CHANNEL" ]; then
    echo "Usage: $0 <prompt> <channel> [caption] [reference_image_url]"
    exit 1
fi

log_info "Generating image with Doubao Seedream (Image-to-Image)..."
log_info "Prompt: $PROMPT"
log_info "Reference Image: $REF_IMAGE"

# Process Reference Image (URL or Local File)
if [[ "$REF_IMAGE" =~ ^https?:// ]]; then
  # It's a URL
  IMAGE_PAYLOAD="\"image\": \"$REF_IMAGE\""
else
  # Check if file exists as is
  if [ ! -f "$REF_IMAGE" ]; then
    # Try resolving relative to script directory if it looks like a project path
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # If script is in scripts/ and image is in assets/, try ../assets/
    ALT_PATH="$SCRIPT_DIR/../assets/$(basename "$REF_IMAGE")"
    if [ -f "$ALT_PATH" ]; then
        log_info "Resolved image path to: $ALT_PATH"
        REF_IMAGE="$ALT_PATH"
    fi
  fi

  if [ -f "$REF_IMAGE" ]; then
    # It's a local file, convert to Base64
    if [[ "$OSTYPE" == "darwin"* ]]; then
      BASE64_DATA=$(base64 < "$REF_IMAGE")
    else
      BASE64_DATA=$(base64 -w 0 < "$REF_IMAGE")
    fi
    IMAGE_PAYLOAD="\"binary_data_base64\": [\"$BASE64_DATA\"]"
    log_info "Converted local image to Base64 (length: ${#BASE64_DATA})"
  else
    log_error "Reference image not found or invalid: $REF_IMAGE"
    exit 1
  fi
fi

# Generate image via Volcengine
# Using user provided structure for Image-to-Image
RESPONSE=$(curl -s -X POST "https://ark.cn-beijing.volces.com/api/v3/images/generations" \
   -H "Content-Type: application/json" \
   -H "Authorization: Bearer $ARK_API_KEY" \
   -d "{ 
     \"model\": \"doubao-seedream-4-5-251128\", 
     \"prompt\": $(echo "$PROMPT" | jq -Rs .), 
     $IMAGE_PAYLOAD,
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
    openclaw message send --action send --target "$CHANNEL" --message "$CAPTION" --media "$IMAGE_URL"
else
    # Fallback to direct API call if needed
    log_warn "Direct API call not fully implemented in this script version, please install openclaw CLI"
fi

log_info "Done!"
