$path = "c:\Users\USER\Desktop\lumenvestasset.com"
$files = Get-ChildItem -Path $path -Include *.html,*.htm -Recurse

foreach ($file in $files) {
    Write-Host "Fixing $($file.Name)..."
    $content = Get-Content $file.FullName -Raw

    # 1. Backgrounds
    $content = $content -replace 'bg-gray-900', 'bg-[#0f0f0f]'
    $content = $content -replace 'from-gray-900', 'from-[#0f0f0f]'
    $content = $content -replace 'to-gray-900', 'to-[#0f0f0f]'
    # Also fix explicit hex if present (unlikely but safe)
    
    # 2. Blue Buttons -> Orange
    $content = $content -replace 'bg-blue-600', 'bg-orange-500'
    $content = $content -replace 'hover:bg-blue-700', 'hover:bg-orange-600'
    $content = $content -replace 'focus:ring-blue-600', 'focus:ring-orange-500'
    
    # 3. Config Colors
    # Standard format
    $content = $content -replace 'primary: "#3B82F6"', 'primary: "#F97316"'
    # Register format (Indigo hexes)
    $content = $content -replace '"#6366f1"', '"#F97316"' # 500
    $content = $content -replace '"#4f46e5"', '"#ea580c"' # 600
    $content = $content -replace '"#4338ca"', '"#c2410c"' # 700
    
    # 4. Text Contrast
    # Fix @apply block
    if ($content -match '@apply bg-primary') {
         $content = [Regex]::Replace($content, '(@apply bg-primary.*?)text-white', '$1text-[#0f0f0f]')
    }
    # Fix inline
    $content = [Regex]::Replace($content, 'class="([^"\r\n]*)text-white([^"\r\n]*)bg-orange-500', 'class="$1text-[#0f0f0f]$2bg-orange-500')
    $content = [Regex]::Replace($content, 'class="([^"\r\n]*)bg-orange-500([^"\r\n]*)text-white', 'class="$1bg-orange-500$2text-[#0f0f0f]')

    # 5. Fix focus rings offset
    $content = $content -replace 'focus:ring-offset-gray-900', 'focus:ring-offset-[#0f0f0f]'

    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
Write-Host "Fix Complete!"
