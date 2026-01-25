# PowerShell Script to Compress Images for Web
# Reduces file size by resizing huge images and applying JPEG compression.

Add-Type -AssemblyName System.Drawing

$imagesPath = "d:\Antigravity\portfolio\assets\images"
$backupPath = "$imagesPath\_backup"
$maxWidth = 2500
$quality = 85

# Create backup directory
if (-not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath | Out-Null
    Write-Host "Created backup folder: $backupPath" -ForegroundColor Cyan
}

$files = Get-ChildItem -Path $imagesPath -Include *.jpg, *.jpeg, *.png -Exclude "hero.png"

foreach ($file in $files) {
    Write-Host "Processing $($file.Name)..." -NoNewline

    # 1. Back up original if not exists
    $backupFile = Join-Path $backupPath $file.Name
    if (-not (Test-Path $backupFile)) {
        Copy-Item $file.FullName $backupFile
    }

    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)
        
        # 2. Check dimensions
        $newWidth = $img.Width
        $newHeight = $img.Height
        
        if ($img.Width -gt $maxWidth) {
            $scale = $maxWidth / $img.Width
            $newWidth = $maxWidth
            $newHeight = [int]($img.Height * $scale)
        }

        # 3. Resize/Compress
        $bmp = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graph = [System.Drawing.Graphics]::FromImage($bmp)
        $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graph.DrawImage($img, 0, 0, $newWidth, $newHeight)
        
        # JPEG Encoder Parameters
        $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $quality)

        # Save (overwriting original as JPEG to save space, changing extension if needed)
        $img.Dispose() # Release original file handle
        
        # We always save as .jpg for consistency and compression
        $newPath = $file.FullName -replace "\.png$", ".jpg"
        $bmp.Save($newPath, $codec, $encoderParams)
        $bmp.Dispose()
        $graph.Dispose()

        Write-Host " Done." -ForegroundColor Green
    }
    catch {
        Write-Host " Error: $_" -ForegroundColor Red
    }
}

Write-Host "`nOptimization Complete!" -ForegroundColor Cyan
Start-Sleep -Seconds 3
