$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$indexPath = Join-Path $PSScriptRoot 'questions.index'

Get-Content $indexPath | Select-Object -Skip 1 | ForEach-Object {
    $parts = $_ -split '\|', 4
    $number = $parts[0]
    $directory = $parts[1]
    $target = Join-Path $repoRoot $directory

    New-Item -ItemType Directory -Force -Path $target | Out-Null

    $setup = @"
#!/usr/bin/env bash
set -euo pipefail
repo_root="`$(cd "`$(dirname "`${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "`$repo_root/scripts/setup-question.sh" "$number"
"@

    $question = @"
#!/usr/bin/env bash
set -euo pipefail
repo_root="`$(cd "`$(dirname "`${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "`$repo_root/scripts/print-question.sh" "$number"
"@

    $solution = @"
#!/usr/bin/env bash
set -euo pipefail
repo_root="`$(cd "`$(dirname "`${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "`$repo_root/scripts/print-solution.sh" "$number"
"@

    [IO.File]::WriteAllText((Join-Path $target 'LabSetUp.bash'), $setup.Replace("`r`n", "`n"))
    [IO.File]::WriteAllText((Join-Path $target 'Questions.bash'), $question.Replace("`r`n", "`n"))
    [IO.File]::WriteAllText((Join-Path $target 'SolutionNotes.bash'), $solution.Replace("`r`n", "`n"))
}

Write-Host 'Generated lab wrapper files from scripts/questions.index.'
