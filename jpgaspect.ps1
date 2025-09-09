# Interactive JPG Aspect Ratio Analysis Script
# Identifies JPG files that don't conform to 16:9 aspect ratio (with 2% tolerance)
# Recursively scans all subfolders from a root directory
# Outputs full paths to a simple text file

# Add the necessary assembly to work with images
Add-Type -AssemblyName System.Drawing

# Function to check if aspect ratio is within tolerance of 16:9
function Test-AspectRatio {
    param (
        [double]$Width,
        [double]$Height,
        [double]$TolerancePercent
    )
    
    # Target aspect ratio (16:9 = 1.7777...)
    $targetRatio = 16.0 / 9.0
    
    # Calculate actual ratio
    $actualRatio = $Width / $Height
    
    # Calculate tolerance range
    $toleranceFactor = $TolerancePercent / 100
    $minAcceptable = $targetRatio * (1 - $toleranceFactor)
    $maxAcceptable = $targetRatio * (1 + $toleranceFactor)
    
    # Check if within tolerance
    return ($actualRatio -ge $minAcceptable) -and ($actualRatio -le $maxAcceptable)
}

# Function to get valid directory path from user
function Get-ValidDirectory {
    param([string]$PromptMessage)
    
    do {
        $path = Read-Host $PromptMessage
        if ([string]::IsNullOrWhiteSpace($path)) {
            Write-Host "Please enter a valid directory path." -ForegroundColor Yellow
            continue
        }
        
        # Expand relative paths and environment variables
        $path = [System.Environment]::ExpandEnvironmentVariables($path)
        $path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
        
        if (Test-Path -Path $path -PathType Container) {
            return $path
        } else {
            Write-Host "Directory not found: $path" -ForegroundColor Red
            Write-Host "Please enter a valid directory path." -ForegroundColor Yellow
        }
    } while ($true)
}

# Welcome message
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "JPG Aspect Ratio Analyzer (16:9 Detection)" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Interactive prompts
Write-Host "This script will scan JPG files for 16:9 aspect ratio compliance." -ForegroundColor Green
Write-Host "Files that don't match 16:9 (±2% tolerance) will be listed in the output file." -ForegroundColor Green
Write-Host ""

# Get root directory
Write-Host "STEP 1: Choose the directory to scan" -ForegroundColor Yellow
Write-Host "Enter the full path to the directory you want to scan (including all subfolders):"
$RootDirectory = Get-ValidDirectory "Root directory path"

# Get search string
Write-Host ""
Write-Host "STEP 2: Specify the filename filter" -ForegroundColor Yellow
Write-Host "Enter a search string to filter JPG filenames (only files containing this text will be analyzed)."
Write-Host "This helps narrow down the search to specific types of images."
Write-Host "Examples: 'fanart', 'poster', 'thumbnail', 'cover'" -ForegroundColor Gray
$searchInput = Read-Host "Search string (press Enter for default 'fanart')"
$SearchString = if ([string]::IsNullOrWhiteSpace($searchInput)) { "fanart" } else { $searchInput }
Write-Host "Using search string: '$SearchString'" -ForegroundColor Green

# Get output file name
Write-Host ""
Write-Host "STEP 3: Choose the output filename" -ForegroundColor Yellow
Write-Host "Enter the filename for the results (files that don't match 16:9 ratio)."
$outputInput = Read-Host "Output filename (press Enter for default '16x9results.txt')"
$OutputFile = if ([string]::IsNullOrWhiteSpace($outputInput)) { "16x9results.txt" } else { $outputInput }
Write-Host "Results will be saved to: $OutputFile" -ForegroundColor Green

# Set tolerance (keeping the default from original script)
$TolerancePercent = 2.0

# Display summary
Write-Host ""
Write-Host "SCAN SUMMARY:" -ForegroundColor Cyan
Write-Host "Directory: $RootDirectory"
Write-Host "Search filter: *$SearchString*"
Write-Host "Output file: $OutputFile"
Write-Host "Tolerance: ±${TolerancePercent}%"
Write-Host ""

# Ask for confirmation
$confirm = Read-Host "Proceed with scan? (Y/N)"
if ($confirm -notmatch '^[Yy]') {
    Write-Host "Scan cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting scan..." -ForegroundColor Green

# Initialize array for storing file paths
$nonConformingPaths = @()

# Get all JPG files in the root directory and all subfolders that contain the search string
Write-Host "Scanning $RootDirectory and all subfolders for JPG files containing '$SearchString'..."
$files = Get-ChildItem -Path $RootDirectory -Filter "*.jpg" -Recurse | Where-Object { $_.Name -like "*$SearchString*" }

if ($files.Count -eq 0) {
    Write-Host "No JPG files found matching the search criteria." -ForegroundColor Yellow
    "" | Out-File -FilePath $OutputFile
    Write-Host "Created empty output file $OutputFile"
    exit 0
}

Write-Host "Found $($files.Count) JPG files to analyze..."

$processedCount = 0
$totalFiles = $files.Count

foreach ($file in $files) {
    $processedCount++
    
    # Display progress every 10 files or show percentage
    if ($processedCount % 10 -eq 0 -or $processedCount -eq $totalFiles) {
        $percentComplete = [math]::Round(($processedCount / $totalFiles) * 100, 1)
        Write-Progress -Activity "Analyzing JPG files" -Status "$processedCount of $totalFiles ($percentComplete%)" -PercentComplete $percentComplete
    }
    
    try {
        # Load the image
        $image = [System.Drawing.Image]::FromFile($file.FullName)
        
        # Get dimensions
        $width = $image.Width
        $height = $image.Height
        
        # Check if the image conforms to 16:9 with tolerance
        $isConforming = Test-AspectRatio -Width $width -Height $height -TolerancePercent $TolerancePercent
        
        # If not conforming, add its path to our results
        if (-not $isConforming) {
            $nonConformingPaths += $file.FullName
        }
        
        # Clean up
        $image.Dispose()
    }
    catch {
        Write-Warning "Error processing file $($file.FullName): $_"
    }
}

Write-Progress -Activity "Analyzing JPG files" -Completed

# Output results
Write-Host ""
Write-Host "SCAN COMPLETE!" -ForegroundColor Green
Write-Host "=" * 40 -ForegroundColor Cyan

if ($nonConformingPaths.Count -gt 0) {
    Write-Host "Found $($nonConformingPaths.Count) files that don't conform to 16:9 aspect ratio (+/-${TolerancePercent}%)." -ForegroundColor Red
    
    # Export paths to a simple text file (one path per line)
    $nonConformingPaths | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "File paths exported to $OutputFile" -ForegroundColor Green
    
    # Show first few results as preview
    if ($nonConformingPaths.Count -le 5) {
        Write-Host ""
        Write-Host "Non-conforming files:" -ForegroundColor Yellow
        $nonConformingPaths | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    } else {
        Write-Host ""
        Write-Host "First 5 non-conforming files:" -ForegroundColor Yellow
        $nonConformingPaths[0..4] | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        Write-Host "  ... and $($nonConformingPaths.Count - 5) more (see $OutputFile)" -ForegroundColor Gray
    }
}
else {
    Write-Host "All files conform to 16:9 aspect ratio (+/-${TolerancePercent}%)!" -ForegroundColor Green
    # Create an empty file
    "" | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "Created empty output file $OutputFile"
}

Write-Host ""
Read-Host "Press Enter to exit"