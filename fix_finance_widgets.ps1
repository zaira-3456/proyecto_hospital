Get-ChildItem "lib\screens\finanzas\finanzas\finanzas\widgets\*.dart" -File | Where-Object { $_.Name -ne "finance_colors.dart" } | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Add import if not exists
    if ($content -notmatch "import.*finance_colors\.dart") {
        $content = $content -replace "(import 'package:flutter/material.dart';)", "`$1`nimport 'finance_colors.dart';"
    }
    
    # Fix syntax errors from previous replacement (const kFColor)
    $content = $content -replace "\bconst kF", "kF"
    
    # Replace common hardcoded colors
    $content = $content -replace "Color\(0xFF00BCD4\)", "kFPrimaryBlue"
    $content = $content -replace "Color\(0xFF0288D1\)", "kFPrimaryBlue"
    $content = $content -replace "Color\(0xFF448AFF\)", "kFPrimaryBlue"
    $content = $content -replace "Color\(0xFF2196F3\)", "kFPrimaryBlue"
    $content = $content -replace "Color\(0xFF81D4FA\)", "kFLightBlue"
    $content = $content -replace "Color\(0xFFB3E5FC\)", "kFLightBlue"
    $content = $content -replace "Color\(0xFFE3F2FD\)", "kFBgLight"
    $content = $content -replace "Color\(0xFFFCE4EC\)", "kFBgLight"
    $content = $content -replace "Color\(0xFFF3E5F5\)", "kFBgLight"
    $content = $content -replace "Color\(0xFFF5F5F5\)", "kFGreyBg"
    
    Set-Content $_.FullName $content
}

Write-Host "Color replacement completed in widgets directory"
