# Photo Capture and Upload Script to MEGA

This script is designed to capture photos using the Termux camera and automatically upload them to a MEGA account. It includes features such as file encryption, local file cleanup, execution scheduling, and a colored interface.

---

## Features

1. **Photo Capture**:
   - Uses the Termux camera to capture photos.
   - Saves photos locally with a timestamp-based name (`YYYYMMDD_HHMMSS`).

2. **Upload to MEGA**:
   - Uploads photos to a specific directory on MEGA.
   - Captures error exceptions if the upload fails.

3. **Encryption**:
   - Encrypts files before uploading them to MEGA.
   - The encryption password can be provided via an argument (`-p`).

4. **Local File Cleanup**:
   - Removes local files after successful upload (optional).

5. **Scheduling**:
   - Allows scheduling the script's execution using `cron`.
   - Supported frequencies: `1h` (1 hour), `30m` (30 minutes), `15m` (15 minutes).

6. **Colored Interface**:
   - Displays colored messages in the terminal for better readability (optional).

---

## How to Use

### Script Arguments
 -------------------|---------------------------------------------------------------------------------------
| Argument          | Description                                                                           |
|-------------------|---------------------------------------------------------------------------------------|
| `-d DIR_LOCAL`    | Defines the local directory to save photos (default: `~/storage/pictures/FotosMega`). |
| `-m DIR_MEGA`     | Defines the MEGA directory to upload photos (default: `FotosMega`).                   |
| `-i INTERVAL`     | Defines the interval between photos in seconds (default: 5).                          |
| `-c`              | Cleans up local files after upload.                                                   |
| `-k`              | Enables the colored interface.                                                        |
| `-s TIME`    |    | Schedules execution with `cron` (e.g., `1h`, `30m`, `15m`).                           |
| `-e`              | Encrypts files before uploading.                                                      |
| `-p PASSWORD`     | Password for encryption (required if `-e` is used).                                   |
| `-h`              | Displays help.                                                                        |
 -------------------|---------------------------------------------------------------------------------------

### Usage Examples

1. **Default execution**:
   ```bash
   ./script.sh