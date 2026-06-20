# =====================================================================================
#  register_vscode_session_in_desktop.ps1
#  Make a VS-Code-born Claude Code chat show up in the Claude Code DESKTOP app sidebar.
# =====================================================================================
#
#  THE PUZZLE THIS SOLVES
#  ----------------------
#  Both apps share ONE transcript file (the "cabinet"):
#       %USERPROFILE%\.claude\projects\<drawer>\<sessionId>.jsonl
#
#  But the DESKTOP app only LISTS a chat in its sidebar if a tiny "sticky note"
#  wrapper exists for it:
#       %APPDATA%\Claude\claude-code-sessions\<acct>\<group>\local_<sessionId>.json
#
#       DESKTOP SIDEBAR            CABINET (shared transcript)
#       reads sticky notes   ──►   reads/writes the .jsonl
#       local_<id>.json            <id>.jsonl
#            │  cliSessionId ──────────►  points here
#
#  A chat BORN IN THE DESKTOP gets a sticky note automatically  -> shows up.        OK
#  A chat BORN IN VS CODE writes ONLY the .jsonl, no sticky note -> desktop is blind. <-- the gap
#
#  This script manufactures the missing sticky note(s), so VS-Code-born chats
#  appear in the desktop sidebar and open straight from the shared transcript.
#
#  USAGE
#  -----
#    Dry run (DEFAULT - writes NOTHING, just shows what it would do):
#        powershell -NoProfile -ExecutionPolicy Bypass -File register_vscode_session_in_desktop.ps1
#
#    Do it for real:
#        powershell -NoProfile -ExecutionPolicy Bypass -File register_vscode_session_in_desktop.ps1 -Apply
#
#    Scope it:
#        -ProjectPath "C:\path\to\the\folder\you\opened\in\vscode"   (default: current folder)
#        -SessionId   1969c36f-bb10-45e6-b765-1b4544f68193           (just one chat)
#        -AllProjects                                                 (every project's drawer)
# =====================================================================================

param(
  [string]$ProjectPath = (Get-Location).Path,
  [string]$SessionId   = "",
  [switch]$AllProjects,
  [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$projRoot = Join-Path $env:USERPROFILE '.claude\projects'

# cwd path -> cabinet drawer name: every non-[A-Za-z0-9] char becomes a dash.
function Convert-ToDrawer([string]$p) {
  -join ($p.ToCharArray() | ForEach-Object { if ($_ -match '[A-Za-z0-9]') { $_ } else { '-' } })
}

# .NET DateTime -> Unix epoch milliseconds (what the wrapper stores).
$epoch = [datetime]::SpecifyKind([datetime]'1970-01-01 00:00:00', 'Utc')
function Get-EpochMs([datetime]$dt) {
  [long](($dt.ToUniversalTime() - $epoch).TotalMilliseconds)
}

# Minimal, safe JSON string escaper (we hand-build the wrapper so empty {} and [] stay exact).
function ConvertTo-JsonString([string]$s) {
  if ($null -eq $s) { return "" }
  $s = $s -replace '\\', '\\'
  $s = $s -replace '"', '\"'
  $s = $s -replace "`r", '\r'
  $s = $s -replace "`n", '\n'
  $s = $s -replace "`t", '\t'
  return $s
}

# --- 1) Find the desktop "sticky note" folder (acct-guid\group-guid) -------------------
$wrapRoot = Join-Path $env:APPDATA 'Claude\claude-code-sessions'
$anyWrap  = Get-ChildItem -Path $wrapRoot -Recurse -Filter 'local_*.json' -File -ErrorAction SilentlyContinue |
            Select-Object -First 1
if (-not $anyWrap) {
  Write-Host "X  No desktop sticky-notes found under $wrapRoot"
  Write-Host "   Open the desktop app once (start ANY chat) so the folder exists, then re-run."
  exit 1
}
$sessDir = $anyWrap.Directory.FullName

# --- 2) Which transcripts ALREADY have a sticky note (so we skip them) -----------------
$registered = @{}
Get-ChildItem -Path $wrapRoot -Recurse -Filter 'local_*.json' -File | ForEach-Object {
  $head = Get-Content $_.FullName -TotalCount 1
  if ($head -match '"cliSessionId":"([^"]+)"') { $registered[$matches[1]] = $true }
}

# --- 3) Gather candidate transcripts (.jsonl directly in the drawer, NOT subagents) ----
$drawers = @()
if ($AllProjects) {
  $drawers = Get-ChildItem $projRoot -Directory
} else {
  $d = Join-Path $projRoot (Convert-ToDrawer $ProjectPath)
  if (-not (Test-Path $d)) {
    Write-Host "X  No cabinet drawer for: $ProjectPath"
    Write-Host "   (looked for: $d)"
    exit 1
  }
  $drawers = @(Get-Item $d)
}
$jsonls = foreach ($dr in $drawers) { Get-ChildItem $dr.FullName -Filter *.jsonl -File }
if ($SessionId) { $jsonls = $jsonls | Where-Object { $_.BaseName -eq $SessionId } }

# --- 4) For each unregistered transcript, build + (optionally) write the sticky note ----
$mode = if ($Apply) { "APPLY (writing files)" } else { "DRY RUN (writing nothing)" }
Write-Host ""
Write-Host "Sticky-note folder : $sessDir"
Write-Host "Mode               : $mode"
Write-Host "Candidates scanned : $($jsonls.Count) transcript(s)"
Write-Host ("-" * 78)

$made = 0; $skipped = 0
foreach ($j in $jsonls) {
  $id = $j.BaseName
  if ($registered.ContainsKey($id)) { $skipped++; continue }   # already in desktop sidebar

  # Read just the head of the transcript to recover cwd + a friendly title.
  $lines = Get-Content $j.FullName -TotalCount 50 -ErrorAction SilentlyContinue
  $cwd = $null; $title = $null; $titleSource = "user"; $firstUser = $null
  foreach ($ln in $lines) {
    $o = $null; try { $o = $ln | ConvertFrom-Json } catch { continue }
    if (-not $cwd   -and $o.cwd)                                   { $cwd = [string]$o.cwd }
    if (-not $title -and $o.type -eq 'summary' -and $o.summary)    { $title = [string]$o.summary; $titleSource = "summary" }
    if (-not $firstUser -and $o.type -eq 'user') {
      $c = $o.message.content
      if     ($c -is [string]) { $firstUser = $c }
      elseif ($c)              { $t = ($c | Where-Object { $_.type -eq 'text' } | Select-Object -First 1).text
                                 if ($t) { $firstUser = [string]$t } }
    }
  }
  if (-not $cwd) { $cwd = $ProjectPath }
  if (-not $title) {
    if ($firstUser) {
      $tt = $firstUser -replace '(?s)<system-reminder>.*$', ''
      $tt = ($tt -replace '\s+', ' ').Trim()
      if ($tt.Length -gt 50) { $tt = $tt.Substring(0, 50) + [char]0x2026 }
      $title = if ($tt) { $tt } else { "VS Code session $($id.Substring(0,8))" }
    } else { $title = "VS Code session $($id.Substring(0,8))" }
  }
  # Prefix a short date so chats that share the same first message stay distinguishable.
  $datePrefix = $j.CreationTime.ToString('[MMM d] ')
  $title = $datePrefix + $title

  $createdMs  = Get-EpochMs $j.CreationTime
  $activityMs = Get-EpochMs $j.LastWriteTime

  $cwdJ = ConvertTo-JsonString $cwd
  $ttlJ = ConvertTo-JsonString $title
  $json = '{"sessionId":"local_' + $id + '","cliSessionId":"' + $id + '","cwd":"' + $cwdJ +
          '","originCwd":"' + $cwdJ + '","lastFocusedAt":' + $activityMs + ',"createdAt":' + $createdMs +
          ',"lastActivityAt":' + $activityMs + ',"model":"claude-opus-4-8","effort":"high",' +
          '"sessionSettings":{"ultracode":false},"isArchived":false,"title":"' + $ttlJ +
          '","titleSource":"' + $titleSource + '","permissionMode":"default",' +
          '"enabledMcpTools":{},"remoteMcpServersConfig":[]}'

  $outPath = Join-Path $sessDir ("local_" + $id + ".json")

  if ($Apply) {
    [IO.File]::WriteAllText($outPath, $json, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host ("WROTE  {0,-12}  {1}" -f $id.Substring(0,8), $title)
  } else {
    Write-Host ("WOULD  {0,-12}  {1}" -f $id.Substring(0,8), $title)
  }
  $made++
}

Write-Host ("-" * 78)
Write-Host ("Result: {0} new sticky-note(s), {1} already registered (skipped)." -f $made, $skipped)
if (-not $Apply -and $made -gt 0) {
  Write-Host "Re-run with  -Apply  to actually create them, then RESTART the desktop app to see them."
}
