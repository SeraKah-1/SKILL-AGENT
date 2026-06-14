#!/bin/bash
# token-monitor.sh — Token usage estimator for Antigravity CLI sessions
# Usage: ./token-monitor.sh [conversation-id]
# If no conversation-id is provided, it will scan the latest session.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

BRAIN_DIR="$HOME/.gemini/antigravity-cli/brain"

# ─── Resolve conversation ────────────────────────────────────────────────
if [ -n "$1" ]; then
  CONV_ID="$1"
else
  # Find the most recently modified conversation
  CONV_ID=$(ls -t "$BRAIN_DIR" 2>/dev/null | head -1)
fi

if [ -z "$CONV_ID" ]; then
  echo -e "${RED}✗${NC} No sessions found in $BRAIN_DIR"
  exit 1
fi

TRANSCRIPT="$BRAIN_DIR/$CONV_ID/.system_generated/logs/transcript.jsonl"
TRANSCRIPT_FULL="$BRAIN_DIR/$CONV_ID/.system_generated/logs/transcript_full.jsonl"

if [ ! -f "$TRANSCRIPT" ]; then
  echo -e "${RED}✗${NC} No transcript found for session: $CONV_ID"
  exit 1
fi

# ─── Parse session data ──────────────────────────────────────────────────
TOTAL_STEPS=$(grep -c '"step_index"' "$TRANSCRIPT" 2>/dev/null || echo "0")
USER_MSGS=$(grep -c '"USER_INPUT"' "$TRANSCRIPT" 2>/dev/null || echo "0")
MODEL_RESPONSES=$(grep -c '"PLANNER_RESPONSE"' "$TRANSCRIPT" 2>/dev/null || echo "0")
TOOL_CALLS=$(grep -o '"tool_calls"' "$TRANSCRIPT" 2>/dev/null | wc -l || echo "0")

# Size-based token estimation (industry standard: ~4 chars per token)
TRANSCRIPT_BYTES=$(wc -c < "$TRANSCRIPT" 2>/dev/null || echo "0")
FULL_BYTES=$(wc -c < "$TRANSCRIPT_FULL" 2>/dev/null || echo "0")

EST_TOKENS_COMPACT=$((TRANSCRIPT_BYTES / 4))
EST_TOKENS_FULL=$((FULL_BYTES / 4))

# Detect model changes from transcript (only from USER_INPUT lines containing settings changes)
MODELS_USED=$(grep '"USER_INPUT"' "$TRANSCRIPT" 2>/dev/null | grep -o 'from [A-Z].* to [A-Z].*\. No need' | sed 's/.*to //;s/\. No need//' | sort -u)
CURRENT_MODEL=$(grep '"USER_INPUT"' "$TRANSCRIPT" 2>/dev/null | grep -o 'from [A-Z].* to [A-Z].*\. No need' | sed 's/.*to //;s/\. No need//' | tail -1)
[ -z "$CURRENT_MODEL" ] && CURRENT_MODEL="unknown"

# Session timestamps
FIRST_TS=$(head -1 "$TRANSCRIPT" | grep -oP '"created_at":"[^"]+' | head -1 | cut -d'"' -f4)
LAST_TS=$(tail -1 "$TRANSCRIPT" | grep -oP '"created_at":"[^"]+' | head -1 | cut -d'"' -f4)

# ─── Model limit database ────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║          🛰️  ANTIGRAVITY TOKEN MONITOR                      ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}Session:${NC}  $CONV_ID"
echo -e "${CYAN}Started:${NC}  $FIRST_TS"
echo -e "${CYAN}Latest:${NC}   $LAST_TS"
echo -e "${CYAN}Model:${NC}    $CURRENT_MODEL"
echo ""

echo -e "${BOLD}── Session Activity ──────────────────────────────────────────${NC}"
printf "  %-28s %s\n" "Total steps:" "$TOTAL_STEPS"
printf "  %-28s %s\n" "User messages:" "$USER_MSGS"
printf "  %-28s %s\n" "Model responses:" "$MODEL_RESPONSES"
printf "  %-28s %s\n" "Tool invocations:" "$TOOL_CALLS"
echo ""

echo -e "${BOLD}── Token Estimation ─────────────────────────────────────────${NC}"
printf "  %-28s %s tokens\n" "Compact transcript:" "~$(printf '%'\'d "$EST_TOKENS_COMPACT")"
printf "  %-28s %s tokens\n" "Full transcript:" "~$(printf '%'\'d "$EST_TOKENS_FULL")"
printf "  %-28s %s\n" "Transcript size:" "$(numfmt --to=iec $FULL_BYTES 2>/dev/null || echo "${FULL_BYTES}B")"
echo ""

if [ "$MODELS_USED" != "unknown" ] && [ -n "$MODELS_USED" ]; then
  echo -e "${BOLD}── Models Used This Session ──────────────────────────────────${NC}"
  echo "$MODELS_USED" | while read -r model; do
    echo -e "  ${GREEN}●${NC} $model"
  done
  echo ""
fi

echo -e "${BOLD}── Model Rate Limits Reference ───────────────────────────────${NC}"
echo -e "${DIM}  (Limits vary by tier. Below are typical free/pro baselines.)${NC}"
echo ""
printf "  ${BOLD}%-32s %-12s %-14s %-10s${NC}\n" "Model" "RPM" "TPM" "RPD"
echo "  ─────────────────────────────────────────────────────────────"
printf "  %-32s %-12s %-14s %-10s\n" "Gemini 2.5 Pro" "10" "250,000" "50"
printf "  %-32s %-12s %-14s %-10s\n" "Gemini 2.5 Flash" "15" "1,000,000" "500"
printf "  %-32s %-12s %-14s %-10s\n" "Gemini 3.1 Pro (High)" "10" "250,000" "50"
printf "  %-32s %-12s %-14s %-10s\n" "Gemini 3.5 Flash (High)" "30" "1,000,000" "1,500"
printf "  %-32s %-12s %-14s %-10s\n" "Claude Sonnet 4.5" "5" "40,000" "~varies"
printf "  %-32s %-12s %-14s %-10s\n" "Claude Opus 4.6 (Thinking)" "5" "32,000" "~varies"
echo ""
echo -e "${DIM}  RPM=Requests/Min  TPM=Tokens/Min  RPD=Requests/Day${NC}"
echo -e "${DIM}  Claude limits depend on Anthropic plan tier (Free/Pro/Team).${NC}"
echo -e "${DIM}  Gemini limits depend on Google AI Studio tier (Free/Pay-as-you-go).${NC}"
echo ""

# ─── Burn rate & warnings ────────────────────────────────────────────────
echo -e "${BOLD}── Health Check ─────────────────────────────────────────────${NC}"

if [ "$EST_TOKENS_FULL" -gt 500000 ]; then
  echo -e "  ${RED}⚠ HIGH USAGE${NC} — Full transcript exceeds 500K tokens estimated."
  echo -e "  ${YELLOW}→${NC} Consider starting a new session to avoid context window bloat."
elif [ "$EST_TOKENS_FULL" -gt 200000 ]; then
  echo -e "  ${YELLOW}⚡ MODERATE USAGE${NC} — Full transcript ~${EST_TOKENS_FULL} tokens."
  echo -e "  ${YELLOW}→${NC} Watch for checkpoint truncations. Session memory is still healthy."
else
  echo -e "  ${GREEN}✓ LOW USAGE${NC} — Full transcript ~${EST_TOKENS_FULL} tokens. Plenty of headroom."
fi

if [ "$TOTAL_STEPS" -gt 300 ]; then
  echo -e "  ${YELLOW}⚡ LONG SESSION${NC} — $TOTAL_STEPS steps. Consider archiving or starting fresh."
fi

echo ""
echo -e "${BOLD}── Quick Links ──────────────────────────────────────────────${NC}"
echo "  Google AI Studio Usage:    https://aistudio.google.com/usage"
echo "  Anthropic Console Usage:   https://console.anthropic.com/settings/usage"
echo "  GCP Quota Dashboard:       https://console.cloud.google.com/iam-admin/quotas"
echo ""
