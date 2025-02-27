Photo Capture and Upload Script to MEGA

This script is designed to capture photos using the Termux camera and
automatically upload them to a MEGA account. It includes features such
as file encryption, local file cleanup, execution scheduling, a colored
interface, and camera selection. Features

    Photo Capture:

        Uses the Termux camera to capture photos.

        Saves photos locally with a timestamp-based name (YYYYMMDD_HHMMSS).

        Allows selection of the camera (front or back).

    Upload to MEGA:

        Uploads photos to a specific directory on MEGA.

        Captures error exceptions if the upload fails.

    Encryption:

        Encrypts files before uploading them to MEGA.

        The encryption password can be provided via an argument (-p).

    Local File Cleanup:

        Removes local files after successful upload (optional).

    Scheduling:

        Allows scheduling the script's execution using cron.

        Supports specific times (format: HH:MM).

    Colored Interface:

        Displays colored messages in the terminal for better readability (optional).

    Camera Selection:

        Choose between the front (1) or back (0) camera.

How to Use Script Arguments 
    Argument            Description 
    -d DIR_LOCAL        Defines the local directory to save photos (default: \~/storage/pictures/FotosMega). 
    -m DIR_MEGA         Defines the MEGA directory to upload photos (default: FotosMega). 
    -i INTERVAL         Defines the interval between photos in seconds (default: 5). 
    -c                  Cleans up local files after upload (default: false). 
    -k                  Enables the colored interface (default:true). 
    -s TIME             Schedules execution at a specific time (format: HH:MM, default: none). 
    -e                  Encrypts files before uploading (default: false). 
    -p PASSWORD         Password for encryption (required if -e is used). 
    -C CAMERA           Selects the camera (0 for back, 1 for front, default: 0). 
    -D                  Enables dependency checking (default: false). 
    -h                  Displays help; 

Usage Examples

    Default execution (back camera):
    bash

    ./script.sh

    Use front camera:
    bash

    ./script.sh -C 1

    Schedule execution at 14:30 (2:30 PM) with front camera:
    bash

    ./script.sh -s 14:30 -C 1

    Encrypt files with password and use front camera:
    bash

    ./script.sh -e -p "your_password" -C 1

    Clean local files and use colored interface:
    bash

    ./script.sh -c -k

    Enable dependency checking:
    bash

    ./script.sh -D

Dependencies

The script depends on the following packages:

    mega-cmd: To interact with MEGA.

        Installation:
        bash        

        pkg install megacmd

    termux-api: To access the Termux camera.

        Installation:
        bash
        
        pkg install termux-api

    gpg: To encrypt files (optional).

        Installation:
        bash
    
        pkg install gnupg

Notes

    Encryption:

        The encryption password must be provided via the -p argument.

        If encryption is enabled and no password is provided, the script will display an error and exit.

    Scheduling:

        Scheduling with cron creates a task to run the script at the specified time.

        To remove the schedule, use:
        bash

        crontab -r

    Local File Cleanup:

        Enable cleanup with the -c flag to avoid file accumulation on the device.

    Colored Interface:

        Enable the colored interface with the -k flag for better message readability.

    Camera Selection:

        Use -C 0 for the back camera (default) or -C 1 for the front camera.

    Dependency Checking:

        Enable dependency checking with the -D flag to ensure all required tools are installed.

    Continuous Execution:

        The script will continue running until memory is full or manually interrupted (Ctrl+C).

Project Structure

    script.sh: The main script.

    README.md: This documentation file.

License

This project is licensed under the MIT License. Feel free to use,
modify, and distribute. Contributions

Contributions are welcome! Follow these steps:

    Fork the project.

    Create a branch for your feature (git checkout -b feature/new-feature).

    Commit your changes (git commit -m 'Adding new feature').

    Push to the branch (git push origin feature/new-feature).

    Open a Pull Request.

Author
    @museu_do_novo