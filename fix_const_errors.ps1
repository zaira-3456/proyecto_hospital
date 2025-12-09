# Fix syntax errors by removing "const" before color constants
Get-ChildItem "lib\screens\finanzas\finanzas\finanzas\**\*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Remove "const" before kF color constants (they are already constants, not constructors)
    $content = $content -replace '\bconst (kF[A-Za-z]+)\b', '$1'
    
    Set-Content $_.FullName $content
}

Write-Host "Fixed const keyword before color constants"
