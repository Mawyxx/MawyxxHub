# Adapter boundary gate
# Fails if game:GetService appears outside src/MawyxxHub/adapters/

$root = Join-Path $PSScriptRoot '..\src\MawyxxHub'
$bad = @()
Get-ChildItem -Path $root -Recurse -Filter *.lua | Where-Object {
    $_.FullName -notmatch '\\adapters\\'
} | ForEach-Object {
    $hits = Select-String -Path $_.FullName -Pattern 'game:GetService' -SimpleMatch
    if ($hits) {
        $bad += $hits
    }
}

if ($bad.Count -gt 0) {
    Write-Host 'FAIL: GetService outside adapters/'
    $bad | ForEach-Object { Write-Host $_.Path ':' $_.LineNumber ':' $_.Line.Trim() }
    exit 1
}

Write-Host 'OK: GetService only in adapters/'
exit 0
