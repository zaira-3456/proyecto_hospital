Get-ChildItem "lib\screens\finanzas\finanzas\finanzas\screens\*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Add import if not exists
    if ($content -notmatch "import.*finance_colors\.dart") {
        $content = $content -replace "(import 'package:flutter/material.dart';)", "`$1`nimport '../widgets/finance_colors.dart';"
    }
    
    # Fix syntax errors from previous replacement (const kFColor)
    $content = $content -replace "\bconst kF", "kF"
    
    # Replace remaining hardcoded colors
    $content = $content -replace "Color\(0xFF2196F3\)", "kFPrimaryBlue"
    $content = $content -replace "Color\(0xFFF5F5F5\)", "kFGreyBg"
    
    Set-Content $_.FullName $content
}

Write-Host "Color replacement completed in screens directory"
