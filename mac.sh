#!/bin/bash
# Lertigo start (macOS) — stawia środowisko członka zespołu i oddaje ster agentowi.
#
#   curl -fsSL https://raw.githubusercontent.com/Lertigo/start/main/mac.sh | bash
#   ... | bash -s -- --codex     # dodatkowo Codex
#   ... | bash -s -- --wispr     # dodatkowo Wispr Flow (dyktowanie głosem)
#
# Flagi można łączyć: bash -s -- --codex --wispr
#
# Idempotentny: na maszynie, która ma już część narzędzi, dostawia brakujące.
set -e

CODEX=0
WISPR=0
for a in "$@"; do
  case "$a" in
    --codex) CODEX=1 ;;
    --wispr) WISPR=1 ;;
  esac
done

krok() { printf '\n\033[1m== %s\033[0m\n' "$1"; }

krok "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# brew bywa poza PATH w świeżej powłoce
command -v brew >/dev/null 2>&1 || eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

krok "Narzędzia: git, gh, node (+ Fork)"
brew install git gh node
brew install --cask fork || echo "(Fork nie wszedł — nieblokujące, doinstalujesz później)"
[ "$CODEX" = 1 ] && brew install codex
[ "$WISPR" = 1 ] && brew install --cask wispr-flow

krok "Claude Code"
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
export PATH="$HOME/.local/bin:$PATH"
claude --version

krok "Logowanie do GitHuba"
if ! gh auth status >/dev/null 2>&1; then
  gh auth login --hostname github.com --git-protocol https --web
fi

krok "Dostęp do organizacji Lertigo"
if ! gh api orgs/Lertigo >/dev/null 2>&1; then
  echo "To konto GitHub nie widzi organizacji Lertigo."
  echo "Poproś Michała o zaproszenie (podaj mu swój login: $(gh api user --jq .login)),"
  echo "przyjmij je mailem i uruchom tę komendę jeszcze raz."
  exit 1
fi

krok "Start agenta"
PROMPT="$(gh api repos/Lertigo/claude-standard/contents/onboarding-agenta.md --jq .content | base64 -d | sed -n '/^---$/,$p' | tail -n +2)"
echo "Otwieram Claude Code. Przy pierwszym starcie zaloguj się w przeglądarce, dalej prowadzi agent."
[ "$CODEX" = 1 ] && PROMPT="$PROMPT

Dodatkowo: user chce też Codexa (binarka już zainstalowana) — wykonaj krok o Codexie bez pytania."
exec claude "$PROMPT"
