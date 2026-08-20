# start

Jedna linia stawia środowisko członka zespołu Lertigo: narzędzia (git, gh, Node,
Fork, Ente Auth na kody 2FA), Claude Code, logowanie do GitHuba, a na końcu
otwiera Claude Code z promptem onboardingu — dalej prowadzi agent (pluginy
standardu, warstwa osobista, zasady pracy).

To repo jest publiczne, bo uruchamiasz je ZANIM zalogujesz się do GitHuba.
Nie ma tu nic firmowego: właściwa treść (kanon `claude-standard`, szablon
warstwy osobistej) jest prywatna i ściąga się dopiero po zalogowaniu.

## macOS

Otwórz Terminal (Cmd+spacja → „Terminal") i wklej:

```bash
curl -fsSL https://raw.githubusercontent.com/Lertigo/start/main/mac.sh | bash
```

## Windows

Otwórz PowerShell (menu Start → „PowerShell") i wklej:

```powershell
irm https://raw.githubusercontent.com/Lertigo/start/main/win.ps1 | iex
```

## Co będzie potrzebne po drodze

- konto GitHub zaproszone do organizacji Lertigo (skrypt powie, kogo poprosić,
  jeśli zaproszenia brakuje),
- konto Claude z płatnym planem (Pro wystarcza) — logowanie w przeglądarce
  przy pierwszym starcie Claude Code,
- na macOS: hasło do komputera, gdy Homebrew o nie poprosi.

Dyktujesz do agenta zamiast pisać? Wispr Flow dochodzi flagą `--wispr`
(macOS: instaluje się sam; Windows: skrypt poda adres, bo winget nie ma pakietu).

Używasz też Codexa? Dołóż go od razu:

```bash
curl -fsSL https://raw.githubusercontent.com/Lertigo/start/main/mac.sh | bash -s -- --codex
```

```powershell
$env:LERTIGO_CODEX='1'; irm https://raw.githubusercontent.com/Lertigo/start/main/win.ps1 | iex
```

Skrypty są idempotentne: na maszynie, która ma już część narzędzi, dostawiają
tylko brakujące, więc ta sama linia obsługuje nową osobę i nową maszynę osoby,
która w zespole już jest.
