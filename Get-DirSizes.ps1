## Get-DirSizes.ps1
#
# Author: Narvin Singh
#
# Gets the size of a directory and its contents.


param(
	[string]$dir = (Get-Location).Path,
	[int]$depth = -1
)

function Get-DirSizesWorker([string]$dir, [int]$currentDepth, [System.Collections.ArrayList]$items = $null)
{
	$dirSize = 0

	if ($items -eq $null)
	{
		$items = @()
	}

	$subdirs = Get-ChildItem -Path $dir -Directory -Force

	if ($depth -lt 0 -or $currentDepth -lt $depth)
	{
		foreach ($subdir in $subdirs)
		{
			$item = [PSCustomObject]@{
				'name' = $subdir.Name
				'd' = 'd'
				'parent' = $dir
				'size' = (Get-DirSizesWorker -dir $subdir.FullName -currentDepth ($currentDepth + 1) -items $items)
			}
			$items.Add($item) > $null
			$dirSize += $item.size
		}
	}
	else
	{
		foreach ($subdir in $subdirs)
		{
			$item = [PSCustomObject]@{
				'name' = $subdir.Name
				'd' = 'd'
				'parent' = $dir
				'size' = (Get-ChildItem -Path $subdir.FullName -Recurse -Force | Measure-Object -Property Length -Sum).Sum
			}
			$items.Add($item) > $null
			$dirSize += $item.size
		}
	}

	$files = Get-ChildItem -Path $dir -File -Force

	foreach ($file in $files)
	{
		$item = [PSCustomObject]@{
			'name' = $file.Name
			'd' = '-'
			'parent' = $dir
			'size' = $file.Length
		}
		$items.Add($item) > $null
		$dirSize += $item.size
	}

	return $dirSize
}

[System.Collections.ArrayList]$items = @()
$items.Add([PSCustomObject]@{
		'name' = Split-Path -Path $dir -Leaf
		'd' = 'd'
		'parent' = Split-Path -Path $dir -Parent
		'size' = (Get-DirSizesWorker -dir $dir -currentDepth 0 -items $items)
	}
)
$items | Sort-Object -Property 'size' -Descending | Format-Table -Property @('size', 'd', 'name', 'parent')
