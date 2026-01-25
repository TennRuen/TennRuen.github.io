# PowerShell Script to Update Portfolio Gallery
# Scans assets/images and adds missing ones to index.html

$projectPath = "d:\Antigravity\portfolio"
$indexPath = "$projectPath\index.html"
$imagesPath = "$projectPath\assets\images"

Write-Host "Scanning for new images..." -ForegroundColor Cyan

# 1. Get all image files
$files = Get-ChildItem -Path $imagesPath -Include *.jpg, *.png, *.jpeg -Recurse

# 2. Read existing HTML
$html = Get-Content -Path $indexPath -Raw

# 3. Find missing images
$count = 0
$newHtmlrray = @()

foreach ($file in $files) {
    $filename = $file.Name
    # Check if image is already in HTML (simple string check)
    if ($html -notmatch $filename) {
        Write-Host "Found new image: $filename" -ForegroundColor Green
        
        # Generate Title from filename (remove extension, replace _ with space, title case)
        $title = $file.BaseName -replace "_", " " -replace "-", " " 
        $title = (Get-Culture).TextInfo.ToTitleCase($title)

        # Create HTML Block
        $newBlock = @"
            <div class="gallery-item fade-in-up">
                <img src="assets/images/$filename" alt="$title">
                <div class="overlay">
                    <h3 class="overlay-title">$title</h3>
                </div>
            </div>
"@
        $newHtmlrray += $newBlock
        $count++
    }
}

if ($count -eq 0) {
    Write-Host "No new images found." -ForegroundColor Yellow
} else {
    # 4. Insert into HTML
    # We look for the closing of the gallery grid and insert before it
    # Target: <div class="gallery-grid"> ... [INSERT HERE] </div>
    
    # Simple regex replace to insert before the last closing div of the gallery section logic
    # Actually, finding the specific div closing tag is risky with regex.
    # We can search for the line `<!-- END_GALLERY -->` if we added it, but let's try to find the closing tag content context.
    
    # Better approach for this user: Let's assume the gallery ends before the "contact" section.
    # Or strict string replacement if the structure allows.
    
    # Let's add an identifier comment to the HTML first to make this safe for the future.
    # But since I can't restart the user's file easily without editing it now, I'll use a specific anchor.
    # The gallery grid ends, and then `</div>` and then `</section>`.
    
    # We will search for the last </div> inside the gallery section. 
    # To be safe, let's look for `<section id="contact"` and insert *before* the closing tags of the previous section.
    # Actually, easiest way: <div class="gallery-grid"> ... </div>
    
    # Let's try to insert after the last "gallery-item" div closing.
    
    $joinedNewHtml = $newHtmlrray -join "`n"
    
    # Find the position of the closing tag for gallery-grid. 
    # We know the grid starts at `class="gallery-grid">`.
    # We can try to replace `</div>` that comes after the last `gallery-item`.
    
    # Let's try a safer replacement: insert at the end of the grid using a specific match sequence.
    # Replacing the LAST `</div>` in the `gallery-grid` block is hard without parsing.
    
    # Setup for success: I will edit index.html to have a marker `<!-- GALLERY_END -->` 
    # which is robust. The script will handle adding it if missing or just use it.
    
    if ($html -match "<!-- GALLERY_END -->") {
        $html = $html -replace "<!-- GALLERY_END -->", "$joinedNewHtml`n                    <!-- GALLERY_END -->"
        Set-Content -Path $indexPath -Value $html
        Write-Host "Successfully added $count images!" -ForegroundColor Cyan
    } else {
        Write-Host "Error: Could not find <!-- GALLERY_END --> marker in index.html." -ForegroundColor Red
        Write-Host "Please manually add <!-- GALLERY_END --> inside the <div class='gallery-grid'> before the closing </div>."
    }
}

Start-Sleep -Seconds 3
