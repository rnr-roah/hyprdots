#!/bin/bash

# ─────────────────────────────────────────
#  hyprdots - status.sh
#  Interactive TUI for repo status
# ─────────────────────────────────────────

REPO="/home/roah/git-files/hyprdots"
TOKEN_FILE="/home/roah/git-files/github-token"
GH_USER="rnr-roah"
REPO_NAME="hyprdots"

# ── Colors ────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Read token ────────────────────────────
if [ ! -f "$TOKEN_FILE" ]; then
    echo -e "${RED}Error: Token file not found at $TOKEN_FILE${RESET}"
    exit 1
fi
TOKEN=$(cat "$TOKEN_FILE" | tr -d '[:space:]')

# ── Helpers ───────────────────────────────
clear_screen() { clear; }

draw_line() {
    printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '─'
}

draw_double_line() {
    printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '═'
}

center_text() {
    local text="$1"
    local width="${COLUMNS:-80}"
    local padding=$(( (width - ${#text}) / 2 ))
    printf '%*s%s\n' "$padding" '' "$text"
}

# ── Fetch remote info via GitHub API ──────
fetch_remote_info() {
    REMOTE_INFO=$(curl -s \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$GH_USER/$REPO_NAME")

    REMOTE_DEFAULT_BRANCH=$(echo "$REMOTE_INFO" | grep '"default_branch"' | cut -d'"' -f4)
    REMOTE_LAST_PUSH=$(echo "$REMOTE_INFO" | grep '"pushed_at"' | cut -d'"' -f4)
    REMOTE_STARS=$(echo "$REMOTE_INFO" | grep '"stargazers_count"' | grep -o '[0-9]*' | head -1)
    REMOTE_VISIBILITY=$(echo "$REMOTE_INFO" | grep '"private"' | grep -o 'true\|false' | head -1)
    [ "$REMOTE_VISIBILITY" = "false" ] && REMOTE_VISIBILITY="public" || REMOTE_VISIBILITY="private"
}

# ── Gather git info ───────────────────────
gather_info() {
    cd "$REPO" || exit 1

    # Fetch remote silently
    git fetch origin &>/dev/null

    BRANCH=$(git branch --show-current)
    LAST_COMMIT_HASH=$(git log -1 --format="%h")
    LAST_COMMIT_MSG=$(git log -1 --format="%s")
    LAST_COMMIT_AUTHOR=$(git log -1 --format="%an")
    LAST_COMMIT_DATE=$(git log -1 --format="%cr")

    UNCOMMITTED=$(git status --porcelain)
    UNCOMMITTED_COUNT=$(echo "$UNCOMMITTED" | grep -c . || true)
    [ -z "$UNCOMMITTED" ] && UNCOMMITTED_COUNT=0

    UNPUSHED=$(git log origin/$BRANCH..HEAD --oneline 2>/dev/null)
    UNPUSHED_COUNT=$(echo "$UNPUSHED" | grep -c . || true)
    [ -z "$UNPUSHED" ] && UNPUSHED_COUNT=0

    UNPULLED=$(git log HEAD..origin/$BRANCH --oneline 2>/dev/null)
    UNPULLED_COUNT=$(echo "$UNPULLED" | grep -c . || true)
    [ -z "$UNPULLED" ] && UNPULLED_COUNT=0

    STAGED=$(git diff --cached --name-only)
    MODIFIED=$(git diff --name-only)
    UNTRACKED=$(git ls-files --others --exclude-standard)
}

# ── Status indicator ──────────────────────
status_icon() {
    local count=$1
    if [ "$count" -eq 0 ]; then
        echo -e "${GREEN}✓${RESET}"
    else
        echo -e "${YELLOW}⚠ $count${RESET}"
    fi
}

# ── Main dashboard ────────────────────────
show_dashboard() {
    clear_screen
    gather_info
    fetch_remote_info

    local width="${COLUMNS:-80}"

    echo ""
    echo -e "${CYAN}${BOLD}"
    center_text "󰊢  hyprdots status"
    echo -e "${RESET}"
    draw_double_line

    # ── Repo Info ─────────────────────────
    echo -e "\n${BOLD}${BLUE}  REPO${RESET}"
    draw_line
    printf "  %-20s ${CYAN}%s${RESET}\n" "Branch:" "$BRANCH"
    printf "  %-20s ${CYAN}%s${RESET}\n" "Visibility:" "$REMOTE_VISIBILITY"
    printf "  %-20s ${CYAN}%s${RESET}\n" "Stars:" "${REMOTE_STARS:-0}"
    printf "  %-20s ${CYAN}%s${RESET}\n" "Last pushed:" "$REMOTE_LAST_PUSH"

    # ── Last Commit ───────────────────────
    echo -e "\n${BOLD}${BLUE}  LAST COMMIT${RESET}"
    draw_line
    printf "  %-20s ${MAGENTA}%s${RESET}\n" "Hash:" "$LAST_COMMIT_HASH"
    printf "  %-20s %s\n" "Message:" "$LAST_COMMIT_MSG"
    printf "  %-20s %s\n" "Author:" "$LAST_COMMIT_AUTHOR"
    printf "  %-20s ${DIM}%s${RESET}\n" "When:" "$LAST_COMMIT_DATE"

    # ── Sync Status ───────────────────────
    echo -e "\n${BOLD}${BLUE}  SYNC STATUS${RESET}"
    draw_line
    printf "  %-20s %s\n" "Uncommitted:" "$(status_icon $UNCOMMITTED_COUNT) changes"
    printf "  %-20s %s\n" "Unpushed:" "$(status_icon $UNPUSHED_COUNT) commits"
    printf "  %-20s %s\n" "Unpulled:" "$(status_icon $UNPULLED_COUNT) commits"

    # ── Changed Files ─────────────────────
    if [ -n "$MODIFIED" ] || [ -n "$STAGED" ] || [ -n "$UNTRACKED" ]; then
        echo -e "\n${BOLD}${BLUE}  CHANGED FILES${RESET}"
        draw_line
        if [ -n "$STAGED" ]; then
            echo -e "  ${GREEN}Staged:${RESET}"
            echo "$STAGED" | while read -r f; do
                echo -e "    ${GREEN}+ $f${RESET}"
            done
        fi
        if [ -n "$MODIFIED" ]; then
            echo -e "  ${YELLOW}Modified:${RESET}"
            echo "$MODIFIED" | while read -r f; do
                echo -e "    ${YELLOW}~ $f${RESET}"
            done
        fi
        if [ -n "$UNTRACKED" ]; then
            echo -e "  ${RED}Untracked:${RESET}"
            echo "$UNTRACKED" | while read -r f; do
                echo -e "    ${RED}? $f${RESET}"
            done
        fi
    fi

    # ── Unpushed commits ──────────────────
    if [ -n "$UNPUSHED" ]; then
        echo -e "\n${BOLD}${BLUE}  UNPUSHED COMMITS${RESET}"
        draw_line
        echo "$UNPUSHED" | while read -r line; do
            echo -e "  ${YELLOW}↑ $line${RESET}"
        done
    fi

    # ── Unpulled commits ──────────────────
    if [ -n "$UNPULLED" ]; then
        echo -e "\n${BOLD}${BLUE}  UNPULLED COMMITS${RESET}"
        draw_line
        echo "$UNPULLED" | while read -r line; do
            echo -e "  ${CYAN}↓ $line${RESET}"
        done
    fi

    # ── Menu ──────────────────────────────
    echo ""
    draw_double_line
    echo -e "  ${BOLD}[d]${RESET} view diff    ${BOLD}[c]${RESET} commit all    ${BOLD}[p]${RESET} push    ${BOLD}[u]${RESET} pull    ${BOLD}[r]${RESET} refresh    ${BOLD}[q]${RESET} quit"
    draw_line
    echo -ne "\n  ${BOLD}Choose an option:${RESET} "
}

# ── View diff ─────────────────────────────
show_diff() {
    clear_screen
    echo -e "\n${BOLD}${BLUE}  DIFF${RESET}"
    draw_line
    cd "$REPO" || exit 1
    if git diff --stat | grep -q .; then
        git diff --stat
        echo ""
        echo -ne "${BOLD}  Show full diff? [y/n]:${RESET} "
        read -r choice
        if [ "$choice" = "y" ]; then
            git diff | less -R
        fi
    else
        echo -e "  ${GREEN}No unstaged changes.${RESET}"
        sleep 1
    fi
}

# ── Commit all ────────────────────────────
commit_all() {
    cd "$REPO" || exit 1
    if [ -z "$(git status --porcelain)" ]; then
        echo -e "\n  ${GREEN}Nothing to commit.${RESET}"
        sleep 1
        return
    fi
    echo -ne "\n  ${BOLD}Commit message (leave blank for date):${RESET} "
    read -r msg
    [ -z "$msg" ] && msg="dots: $(date +%F)"
    git add .
    git commit -m "$msg"
    echo -e "\n  ${GREEN}✓ Committed!${RESET}"
    sleep 1
}

# ── Push ──────────────────────────────────
push_changes() {
    cd "$REPO" || exit 1
    echo -e "\n  ${CYAN}Pushing to origin/$BRANCH...${RESET}"
    git push https://$GH_USER:$TOKEN@github.com/$GH_USER/$REPO_NAME.git $BRANCH
    echo -e "\n  ${GREEN}✓ Pushed!${RESET}"
    sleep 1
}

# ── Pull ──────────────────────────────────
pull_changes() {
    cd "$REPO" || exit 1
    echo -e "\n  ${CYAN}Pulling from origin/$BRANCH...${RESET}"
    git pull https://$GH_USER:$TOKEN@github.com/$GH_USER/$REPO_NAME.git $BRANCH
    echo -e "\n  ${GREEN}✓ Pulled!${RESET}"
    sleep 1
}

# ── Main loop ─────────────────────────────
while true; do
    show_dashboard
    read -r -n1 key
    case "$key" in
        d) show_diff ;;
        c) commit_all ;;
        p) push_changes ;;
        u) pull_changes ;;
        r) continue ;;
        q) clear_screen; echo -e "${GREEN}bye!${RESET}\n"; exit 0 ;;
        *) ;;
    esac
done
