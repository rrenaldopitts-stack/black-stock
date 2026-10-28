[CmdletBinding()]
param(
    [string]$GitExecutable = 'git',
    [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
$env:GIT_TERMINAL_PROMPT = '0'
$env:GCM_INTERACTIVE = 'Never'
$repository = $PSScriptRoot
$logPath = Join-Path $repository '.git\tradex-autosave.log'
$allowedRoots = @(
    '.gitignore',
    'tradex-autosave.ps1',
    'tradex-global.css',
    'tradex-learning.css',
    'tradex-app.css',
    'tradex-journey.css',
    'stock-option-demo.css',
    'workspace stock market.code-workspace',
    '100 most popular/',
    'Altcoins/',
    'Cannabis/',
    'Daily movers/',
    'dashboard/',
    'Early dividend stocks/',
    'Energy/',
    'ETF.html/',
    'homepage/',
    'culture/',
    'numbers/',
    'images/',
    'IPO Access/',
    'Newly listed crypto/',
    'stock market/',
    'Tech,media,& telecom/',
    'Technology/',
    'Tradeable crypto/',
    'Upcoming earnings/'
)

function Write-AutosaveLog {
    param([string]$Message)
    $entry = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -LiteralPath $logPath -Value $entry -Encoding UTF8
    Write-Output $entry
}

function Invoke-Git {
    param([string[]]$GitArguments)
    # Native Git writes progress to stderr even on success.
    $ErrorActionPreference = 'Continue'
    $output = @(& $GitExecutable -C $repository @GitArguments 2>&1 |
        ForEach-Object { "$_" })
    $ErrorActionPreference = 'Stop'
    if ($LASTEXITCODE -ne 0) {
        throw "git $($GitArguments -join ' ') failed: $($output -join [Environment]::NewLine)"
    }
    return ($output -join "`n")
}

function Test-TradeXPath {
    param([string]$Path)
    foreach ($root in $allowedRoots) {
        if ($root.EndsWith('/')) {
            if ($Path.StartsWith($root, [StringComparison]::Ordinal)) {
                return $true
            }
        } elseif ($Path -ceq $root) {
            return $true
        }
    }
    return $false
}

try {
    if ((Test-Path -LiteralPath $logPath) -and
        (Get-Item -LiteralPath $logPath).Length -gt 1MB) {
        Move-Item -LiteralPath $logPath -Destination "$logPath.previous" -Force
    }
    $GitExecutable = (Get-Command $GitExecutable -CommandType Application -ErrorAction Stop).Source
    $branch = Invoke-Git -GitArguments @('branch', '--show-current')
    if ($branch -cne 'main') {
        throw "Expected branch main, found '$branch'. Switch back to main to resume autosaving."
    }
    $remote = Invoke-Git -GitArguments @('remote', 'get-url', 'origin')
    if ($remote -cne 'https://github.com/rrenaldopitts-stack/black-stock.git') {
        throw "The origin URL has changed. Review the autosave configuration before continuing."
    }
    foreach ($operation in @('MERGE_HEAD', 'CHERRY_PICK_HEAD', 'REVERT_HEAD', 'rebase-merge', 'rebase-apply')) {
        if (Test-Path -LiteralPath (Join-Path $repository ".git\$operation")) {
            throw "Git operation '$operation' is in progress. Complete it before autosaving."
        }
    }
    $staged = Invoke-Git -GitArguments @('diff', '--cached', '--name-only')
    if ($staged) {
        throw 'Files are already staged. Commit or unstage them manually before autosaving.'
    }

    $candidates = Invoke-Git -GitArguments @(
        'ls-files', '--modified', '--deleted', '--others', '--exclude-standard', '-z'
    )
    $paths = @($candidates.Split([char]0) |
        Where-Object { $_ -and (Test-TradeXPath -Path $_) } |
        Sort-Object -Unique)
    foreach ($path in $paths) {
        if ($path -match '(?i)(^|/)(\.env(?:\..*)?|node_modules|\.next|\.git|credentials[^/]*|secrets?[^/]*)(/|$)' -or
            $path -match '(?i)\.(pem|key|pfx|p12|log|err)$') {
            throw "Potentially sensitive or generated file needs manual review: $path"
        }
    }
    if ($CheckOnly) {
        Write-AutosaveLog "CHECK: $($paths.Count) TradeX file(s) eligible for the next autosave."
        $result = Invoke-Git -GitArguments @('push', '--dry-run', 'origin', 'main:main')
        Write-AutosaveLog "CHECK: GitHub push access verified. $result"
        exit 0
    }
    if ($paths.Count -gt 0) {
        $null = Invoke-Git -GitArguments (@('--literal-pathspecs', 'add', '-A', '--') + $paths)
        $stagedPaths = Invoke-Git -GitArguments @('diff', '--cached', '--name-only', '-z')
        foreach ($path in $stagedPaths.Split([char]0)) {
            if ($path -and $paths -cnotcontains $path) {
                throw "An unexpected file was staged concurrently: $path. Review the index manually."
            }
        }
        if ($stagedPaths) {
            $message = 'Save TradeX changes ({0})' -f (Get-Date -Format 'yyyy-MM-dd HH:mm')
            $result = Invoke-Git -GitArguments @(
                'commit', '-m', $message,
                '-m', 'Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>'
            )
            Write-AutosaveLog "COMMITTED: $result"
        }
    }
    # Retry a previous failed push even when no new files changed; never force or merge.
    $result = Invoke-Git -GitArguments @('push', 'origin', 'main:main')
    Write-AutosaveLog "OK: $result"
    exit 0
} catch {
    $message = $_.Exception.Message
    Write-AutosaveLog "ERROR: $message"
    Write-Error -Message $message -ErrorAction Continue
    try {
        $shell = New-Object -ComObject WScript.Shell
        $null = $shell.Popup("TradeX autosave failed:`n$message`n`nLog: $logPath", 20, 'TradeX Git Autosave', 48)
    } catch {
        Write-AutosaveLog "ERROR: Could not display notification: $($_.Exception.Message)"
    }
    exit 1
}
