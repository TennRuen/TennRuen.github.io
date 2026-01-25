# PowerShell Script to Update Portfolio Gallery
# Fully synchronizes the gallery grid with the assets/images folder

$projectPath = "d:\Antigravity\portfolio"
$indexPath = "$projectPath\index.html"
$imagesPath = "$projectPath\assets\images"

Write-Host "Syncing gallery with folder..." -ForegroundColor Cyan

# 1. Get all image files (excluding hero image)
$files = Get-ChildItem -Path $imagesPath -Include *.jpg, *.png, *.jpeg -Exclude "hero.png" -Recurse

# 2. Generate HTML for all images
$newHtmlArray = @()
$delayCounter = 1

foreach ($file in $files) {
    $filename = $file.Name
    
    # Generate Title from filename (remove extension, replace _ with space, title case)
    $title = $file.BaseName -replace "_", " " -replace "-", " " 
    $title = (Get-Culture).TextInfo.ToTitleCase($title)
    
    # Cycle delays for nice animation (1, 2, 3, 1, 2...)
    $delayClass = "delay-$delayCounter"
    $delayCounter++
    if ($delayCounter -gt 3) { $delayCounter = 1 }

    # Create HTML Block
    $block = @"
                    <div class="gallery-item fade-in-up $delayClass">
                        <img src="assets/images/$filename" alt="$title" loading="lazy">
                        <div class="overlay">
                            <h3 class="overlay-title">$title</h3>
                        </div>
                    </div>
"@
    $newHtmlArray += $block
}

# Join with newlines
$finalHtml = $newHtmlArray -join "`n"

# 3. Read existing HTML
$html = Get-Content -Path $indexPath -Raw

# 4. Replace content between markers
# We look for content between <!-- GALLERY_START --> and <!-- GALLERY_END -->
if ($html -match "(?s)(?<=<!-- GALLERY_START -->).*(?=<!-- GALLERY_END -->)") {
    $html = $html -replace "(?s)(?<=<!-- GALLERY_START -->).*(?=<!-- GALLERY_END -->)", "`n$finalHtml`n                    "
    Set-Content -Path $indexPath -Value $html
    Write-Host "Gallery updated successfully!" -ForegroundColor Green
    Write-Host "Total images: $($files.Count)" -ForegroundColor Gray
    Write-Host "(Removed hero.png from gallery view)" -ForegroundColor DarkGray
}
else {
    Write-Host "Error: Markers <!-- GALLERY_START --> or <!-- GALLERY_END --> not found." -ForegroundColor Red
}

Start-Sleep -Seconds 3
