# Bundles src/MawyxxHub into dist/MawyxxHub.lua for game:HttpGet + loadstring.

$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot '..\src\MawyxxHub'
$outDir = Join-Path $PSScriptRoot '..\dist'
$outFile = Join-Path $outDir 'MawyxxHub.lua'

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Get-ModuleId([string]$fullPath) {
	$rel = $fullPath.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
	if ($rel -eq 'init.lua') { return 'init' }
	return $rel -replace '\.lua$', ''
}

function Get-DirParts([string]$moduleId) {
	if ($moduleId -eq 'init') { return @() }
	$parts = $moduleId -split '/'
	if ($parts.Length -le 1) { return @() }
	return $parts[0..($parts.Length - 2)]
}

function Resolve-RequirePath([string]$moduleId, [string]$expr) {
	# expr like: script.Parent.Parent.config.Defaults  OR  script.hub.MawyxxHub
	$tokens = ($expr -replace '^script\.?', '' -split '\.') | Where-Object { $_ -ne '' }
	$dir = New-Object System.Collections.Generic.List[string]
	foreach ($p in (Get-DirParts $moduleId)) { [void]$dir.Add($p) }

	# For init.lua (Rojo root ModuleScript), script IS the package root — no auto Parent folder.
	# For other files, script.Parent is the containing folder (= dir parts already).
	# Starting point for navigation: the ModuleScript's parent chain.
	# Roblox: script.Parent = folder containing the .lua file.
	# So we start AT the file's directory (dir), and first .Parent pops once... 
	# Wait: script refers to ModuleScript. script.Parent = containing folder = dir.
	# So before processing tokens, current = dir (the Parent of script conceptually for child access)?
	#
	# require(script.Parent.X): go to Parent (dir's parent), then X
	# Starting location for "script" as ModuleScript: path = dir + [filename]
	# script.Parent = dir
	#
	# Initialize cursor to the ModuleScript path parts including filename? 
	# Better: cursor = dir (meaning we're at script.Parent already when we see first Parent)? 
	#
	# Standard algorithm used by bundlers:
	# start = directory of current module (Get-DirParts)
	# But script.Parent means: from ModuleScript, go to parent folder.
	# ModuleScript lives IN directory `dir`, so script.Parent = dir's... 
	# File hub/MawyxxHub.lua -> ModuleScript parent Folder "hub" -> path parts ["hub"]
	# script.Parent = Folder hub... actually Parent of ModuleScript is Folder hub, whose name is hub.
	# script.Parent.Parent = package root []
	# script.Parent.Parent.config = ["config"]
	#
	# Start cursor at ModuleScript location as [dir..., filename] then .Parent pops?
	# ModuleScript path = dir + [name]
	# .Parent -> dir
	# .Parent -> parent(dir)
	#
	$name = if ($moduleId -eq 'init') { $null } else { ($moduleId -split '/')[-1] }
	$cursor = New-Object System.Collections.Generic.List[string]
	foreach ($p in (Get-DirParts $moduleId)) { [void]$cursor.Add($p) }
	if ($moduleId -ne 'init' -and $null -ne $name) {
		# cursor is at containing folder; script itself is not on the path for Parent walks
		# For init, script is root: cursor starts empty, script.hub pushes hub
	}

	# Correct start: for non-init, we begin as if at the ModuleScript node.
	# First .Parent pops to containing folder which equals Get-DirParts — so we need
	# an extra synthetic segment for the file, OR start with dir and interpret differently.
	#
	# Start with path = dir + ['__file__']; Parent pops __file__ to dir.
	if ($moduleId -ne 'init') {
		[void]$cursor.Add('__mod__')
	}

	foreach ($t in $tokens) {
		if ($t -eq 'Parent') {
			if ($cursor.Count -eq 0) { throw "Parent past root in $moduleId :: $expr" }
			$cursor.RemoveAt($cursor.Count - 1)
		} else {
			[void]$cursor.Add($t)
		}
	}

	$resolved = ($cursor -join '/')
	$resolved = $resolved -replace '/__mod__$', '' -replace '^__mod__$', 'init'
	if ([string]::IsNullOrEmpty($resolved)) { $resolved = 'init' }
	return $resolved
}

$files = Get-ChildItem -Path $root -Recurse -Filter *.lua | Sort-Object FullName
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('-- MawyxxHub bundled for HttpGet/loadstring. Auto-generated; do not edit.')
[void]$sb.AppendLine('local __modules = {}')
[void]$sb.AppendLine('local __loaded = {}')
[void]$sb.AppendLine('local function __require(id)')
[void]$sb.AppendLine('	if __loaded[id] then return __loaded[id] end')
[void]$sb.AppendLine('	local loader = __modules[id]')
[void]$sb.AppendLine('	if not loader then error("[MawyxxHub] module not found: " .. tostring(id), 2) end')
[void]$sb.AppendLine('	local export = loader(__require)')
[void]$sb.AppendLine('	__loaded[id] = export')
[void]$sb.AppendLine('	return export')
[void]$sb.AppendLine('end')
[void]$sb.AppendLine('')

foreach ($f in $files) {
	$id = Get-ModuleId $f.FullName
	$src = Get-Content -Path $f.FullName -Raw -Encoding UTF8

	# Replace require(script....) 
	$pattern = 'require\((script(?:\.[A-Za-z_][A-Za-z0-9_]*)+)\)'
	$src = [regex]::Replace($src, $pattern, {
		param($m)
		$expr = $m.Groups[1].Value
		$resolved = Resolve-RequirePath $id $expr
		return "__require(`"$resolved`")"
	})

	# Wrap module
	[void]$sb.AppendLine("__modules[`"$id`"] = function(__require)")
	# indent source lightly
	foreach ($line in ($src -split "`r?`n")) {
		[void]$sb.AppendLine("`t$line")
	}
	[void]$sb.AppendLine('end')
	[void]$sb.AppendLine('')
}

[void]$sb.AppendLine('return __require("init")')

[System.IO.File]::WriteAllText($outFile, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $outFile"
Write-Host "Modules: $($files.Count)"
