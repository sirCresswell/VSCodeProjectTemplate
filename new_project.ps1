param([string]$ProjectName)

if (-not $ProjectName) {
    Write-Host "Usage: ./new_project.ps1 <ProjectName>"
    exit
}

Copy-Item -Recurse . $ProjectName
Remove-Item "$ProjectName/new_project.ps1"
Remove-Item "$ProjectName/new_project.sh"

Get-ChildItem -Recurse $ProjectName -File | ForEach-Object {
    (Get-Content $_.FullName) `
        -replace "brawui", $ProjectName |
        Set-Content $_.FullName
}

Write-Host "Created new project: $ProjectName"
