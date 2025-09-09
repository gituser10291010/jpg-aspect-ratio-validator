# JPG Aspect Ratio Analyzer

A PowerShell script that identifies JPG images that don't conform to the 16:9 aspect ratio standard, designed for media library maintenance and batch processing workflows.

## Purpose

This tool helps maintain consistent aspect ratios in large image collections by identifying files that deviate from the 16:9 standard (1.7777:1 ratio). It's particularly useful for:

- **Media Center Management**: Ensuring fanart, posters, and thumbnails conform to display standards
- **Digital Asset Organization**: Maintaining consistent aspect ratios across image libraries
- **Batch Processing Preparation**: Generating file lists for automated image processing workflows
- **Quality Assurance**: Identifying images that may need manual review or correction

## Key Features

- **Interactive Interface**: Step-by-step prompts with sensible defaults
- **Recursive Scanning**: Searches through entire directory trees
- **Flexible Filtering**: Target specific image types using filename patterns
- **Configurable Tolerance**: 2% tolerance by default to account for minor variations
- **Batch-Ready Output**: Generates flat file lists compatible with popular tools

## How It Works

The script analyzes each JPG file's dimensions and calculates its aspect ratio. Images that fall outside the acceptable range (16:9 ± 2% tolerance) are flagged as non-conforming. The tolerance accounts for:

- Slight cropping variations
- Minor compression artifacts
- Rounding differences in image editing software

**Target Ratio**: 1.7777:1 (16:9)  
**Acceptable Range**: 1.7422:1 to 1.8133:1 (±2%)

## Usage

Simply run the script and follow the interactive prompts:

```powershell
.\jpgaspect.ps1
```

### Interactive Steps

1. **Directory Selection**: Choose the root folder to scan (all subfolders included)
2. **Filename Filter**: Enter a search string to target specific files (default: "fanart")
3. **Output File**: Specify the results filename (default: "16x9results.txt")
4. **Confirmation**: Review settings before starting the scan

### Example Workflow

```
Root directory: C:\Media\Movies
Search filter: *fanart*
Output file: fanart_issues.txt
Tolerance: ±2%

Found 1,247 JPG files to analyze...
Found 23 files that don't conform to 16:9 aspect ratio
File paths exported to fanart_issues.txt
```

## Output Format

The script generates a **flat text file** with one file path per line:

```
C:\Media\Movies\Action Movie (2023)\fanart.jpg
C:\Media\Movies\Comedy Film (2022)\fanart.jpg
C:\Media\Movies\Drama Series\Season 01\fanart.jpg
```

This simple format is **optimized for batch processing** and can be directly imported into various tools.

## Batch Processing Integration

### Everything Search Tool
1. Load the results file: **File > Import File List**
2. Select all non-conforming images for review
3. Use Everything's built-in tools for file operations

### IrfanView Batch Processing
1. Open IrfanView and start **Batch Conversion/Rename**
2. Click **Add files from TXT** and select your results file
3. Configure batch operations (resize, crop, convert, etc.)
4. Process all flagged images automatically

### Other Compatible Tools
- **XnView MP**: File list import for batch operations
- **FastStone Image Viewer**: Batch processing from file lists  
- **GIMP**: Script-Fu batch processing with file paths
- **ImageMagick**: Command-line batch operations using file list
- **PowerShell**: Further scripting with the generated file paths

## Common Use Cases

### Media Center Maintenance
```
Search string: fanart
Purpose: Find fanart images that don't fit 16:9 displays properly
Action: Batch resize or replace with correctly sized versions
```

### Poster Collection Cleanup
```
Search string: poster  
Purpose: Identify movie posters with incorrect aspect ratios
Action: Source replacement images or crop to standard size
```

### Thumbnail Generation
```
Search string: thumb
Purpose: Find thumbnails that won't display consistently
Action: Regenerate thumbnails with correct 16:9 ratio
```

## Requirements

- **PowerShell 5.1** or later
- **.NET Framework** (for System.Drawing assembly)
- **Windows OS** (due to System.Drawing dependency)

## Technical Details

### Tolerance Calculation
```
Target Ratio = 16/9 = 1.7777...
Actual Ratio = Image Width / Image Height
Tolerance Range = Target ± (Target × 0.02)
Min Acceptable = 1.7422
Max Acceptable = 1.8133
```

### Performance
- Processes approximately **100-200 images per second** (varies by image size)
- Memory efficient: loads one image at a time
- Progress indicator shows completion percentage

### Error Handling
- Gracefully handles corrupted or unreadable images
- Continues processing if individual files fail
- Reports warnings for problematic files without stopping

## Troubleshooting

**"Assembly not found" error**: Ensure .NET Framework is installed  
**"Path not found" error**: Check directory permissions and path accuracy  
**Slow performance**: Consider filtering by filename to reduce file count  
**Memory issues**: Process smaller directory trees or restart PowerShell

## File Naming Conventions

The script works best with organized file naming:
- `movie-fanart.jpg` ✓
- `series-S01-fanart.jpg` ✓  
- `poster-main.jpg` ✓
- `thumbnail-episode.jpg` ✓

## Contributing

This script can be enhanced with additional features:
- Support for other image formats (PNG, BMP, etc.)
- Custom aspect ratio targets (4:3, 21:9, etc.)
- CSV output with dimensions and ratios
- GUI interface for non-PowerShell users

## License

This script is provided as-is for personal and educational use. Feel free to modify and distribute according to your needs.
