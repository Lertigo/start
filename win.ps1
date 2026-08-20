# Lertigo start (Windows) — stawia środowisko członka zespołu i oddaje ster agentowi.
#
#   irm https://raw.githubusercontent.com/Lertigo/start/main/win.ps1 | iex
#   $env:LERTIGO_CODEX='1'; irm https://raw.githubusercontent.com/Lertigo/start/main/win.ps1 | iex   # dodatkowo Codex
#   $env:LERTIGO_WISPR='1'; irm https://raw.githubusercontent.com/Lertigo/start/main/win.ps1 | iex   # dodatkowo Wispr Flow
#
# Idempotentny: dostawia tylko brakujące. Uruchamiaj w PowerShellu (prompt "PS C:\...").
$ErrorActionPreference = 'Stop'

function Krok($t) { Write-Host "`n== $t" -ForegroundColor Cyan }

# winget doinstalowuje pakiet albo mówi, że już jest — oba wyniki są OK
function Zainstaluj($id) {
  winget install -e --id $id --accept-source-agreements --accept-package-agreements
  if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) {  # -1978335189 = już zainstalowane
    throw "winget nie dal rady zainstalowac $id (kod $LASTEXITCODE)"
  }
}

Krok "Narzędzia: Git, gh, Node (+ Fork, Ente Auth)"
Zainstaluj Git.Git
Zainstaluj GitHub.cli
Zainstaluj OpenJS.NodeJS.LTS
try { Zainstaluj Fork.Fork } catch { Write-Host "(Fork nie wszedł — nieblokujące)" }
try { Zainstaluj ente-io.auth-desktop } catch { Write-Host "(Ente Auth nie wszedł — nieblokujące)" }
if ($env:LERTIGO_CODEX -eq '1') { npm i -g @openai/codex }

# Wispr Flow (dyktowanie głosem) nie ma pakietu w katalogu winget-pkgs
# (sprawdzone 20.08.2026), więc na Windowsie zostaje pobranie ze strony.
if ($env:LERTIGO_WISPR -eq '1') {
  Write-Host "Wispr Flow: pobierz z https://wisprflow.ai/get-started (winget nie ma tego pakietu)" -ForegroundColor Yellow
}

Krok "Claude Code"
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  irm https://claude.ai/install.ps1 | iex
}

# Pułapka Windows: świeżo zainstalowane binarki nie są widoczne w tej sesji,
# dopóki nie przeładujemy PATH z rejestru.
Krok "Odświeżenie PATH"
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path','User')
claude --version

Krok "Logowanie do GitHuba"
gh auth status 2>$null
if ($LASTEXITCODE -ne 0) { gh auth login --hostname github.com --git-protocol https --web }

Krok "Dostęp do organizacji Lertigo"
gh api orgs/Lertigo 1>$null 2>$null
if ($LASTEXITCODE -ne 0) {
  $login = gh api user --jq .login
  Write-Host "To konto GitHub nie widzi organizacji Lertigo."
  Write-Host "Poproś Michała o zaproszenie (podaj mu login: $login),"
  Write-Host "przyjmij je mailem i uruchom tę komendę jeszcze raz."
  exit 1
}

Krok "Start agenta"
$b64 = (gh api repos/Lertigo/claude-standard/contents/onboarding-agenta.md --jq .content) -replace "`n",''
$md  = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))
# prompt = wszystko pod pierwszą linią "---"
$prompt = ($md -split "(?m)^---$", 2)[1].Trim()
if ($env:LERTIGO_CODEX -eq '1') {
  $prompt += "`n`nDodatkowo: user chce też Codexa (binarka już zainstalowana) — wykonaj krok o Codexie bez pytania."
}
Write-Host "Otwieram Claude Code. Przy pierwszym starcie zaloguj się w przeglądarce, dalej prowadzi agent."
claude $prompt
