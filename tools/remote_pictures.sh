#!/data/data/com.termux/files/usr/bin/bash

# Function to display a colored banner
display_banner() {
    clear
    echo -e ${CYAN}  # Bright cyan color
    cat << 'EOF'
██████╗     ███████╗    ███╗   ███╗     ██████╗     ████████╗    ███████╗       ██████╗     ██╗     ██████╗    ███████╗
██╔══██╗    ██╔════╝    ████╗ ████║    ██╔═══██╗    ╚══██╔══╝    ██╔════╝       ██╔══██╗    ██║    ██╔════╝    ██╔════╝
██████╔╝    █████╗      ██╔████╔██║    ██║   ██║       ██║       █████╗         ██████╔╝    ██║    ██║         ███████╗
██╔══██╗    ██╔══╝      ██║╚██╔╝██║    ██║   ██║       ██║       ██╔══╝         ██╔═══╝     ██║    ██║         ╚════██║
██║  ██║    ███████╗    ██║ ╚═╝ ██║    ╚██████╔╝       ██║       ███████╗       ██║         ██║    ╚██████╗    ███████║
╚═╝  ╚═╝    ╚══════╝    ╚═╝     ╚═╝     ╚═════╝        ╚═╝       ╚══════╝       ╚═╝         ╚═╝     ╚═════╝    ╚══════╝
                                                                                                                       
EOF
    echo -e ${RESET}  # Reset color
}

# Function to display usage/help
usage() {
    echo "Usage: $0 [-d LOCAL_DIR] [-m MEGA_DIR] [-i INTERVAL] [-c] [-k] [-s TIME] [-e] [-p PASSWORD] [-D] [-C CAMERA] [-I] [-h]"
    echo "  -d LOCAL_DIR  Local directory to save photos (default: ~/storage/pictures/FotosMega)"
    echo "  -m MEGA_DIR   MEGA directory to upload photos (default: FotosMega)"
    echo "  -i INTERVAL   Interval between photos in seconds (default: 5)"
    echo "  -c            Clean local files after upload (default: false)"
    echo "  -k            Enable colored interface (default: true)"
    echo "  -s TIME       Schedule execution at a specific time (format: HH:MM, default: none)"
    echo "  -e            Encrypt files before uploading (default: false)"
    echo "  -p PASSWORD   Password for encryption (required if -e is used)"
    echo "  -D            Enable dependency checking (default: false)"
    echo "  -C CAMERA     Select camera (0 for back, 1 for front, default: 0)"
    echo "  -I            Collect and upload device info (default: false)"
    echo "  -h            Display this help"
    exit 1
}

# Default values
LOCAL_DIR="~/storage/pictures/FotosMega"  # Default local directory to save photos
MEGA_DIR="FotosMega"  # Default MEGA directory to upload photos
INTERVAL=0  # Default interval between photos (in seconds)
CLEAN_FILES=false  # Clean local files after upload (default: false)
COLORED_OUTPUT=true  # Enable colored interface (default: true)
SCHEDULE_TIME=""  # Schedule execution at a specific time (default: none)
ENCRYPT_FILES=false  # Encrypt files before uploading (default: false)
CRYPT_PASSWORD=""  # Password for encryption (required if -e is used)
CHECK_DEPENDENCIES=false  # Enable dependency checking (default: false)
CAMERA=0  # Select camera (0 for back, 1 for front, default: 0)
COLLECT_INFO=false  # Collect and upload device info (default: false)

# Colors for colored interface (if enabled)
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[1;36m"
RESET="\033[0m"

# Argument parser
while getopts "d:m:i:cks:e:p:D:C:Ih" opt; do
    case $opt in
        d) LOCAL_DIR="$OPTARG" ;;  # Set local directory
        m) MEGA_DIR="$OPTARG" ;;  # Set MEGA directory
        i) INTERVAL="$OPTARG" ;;  # Set interval between photos
        c) CLEAN_FILES=true ;;  # Enable cleaning local files after upload
        k) COLORED_OUTPUT=true ;;  # Enable colored interface
        s) SCHEDULE_TIME="$OPTARG" ;;  # Set schedule time
        e) ENCRYPT_FILES=true ;;  # Enable file encryption
        p) CRYPT_PASSWORD="$OPTARG" ;;  # Set encryption password
        D) CHECK_DEPENDENCIES=true ;;  # Enable dependency checking
        C) CAMERA="$OPTARG" ;;  # Set camera (0 for back, 1 for front)
        I) COLLECT_INFO=true ;;  # Enable device info collection
        h) usage ;;  # Display help
        *) echo "Invalid option: -$OPTARG" >&2; usage ;;  # Invalid option
    esac
done

# Function to display colored messages
message() {
    local color="$1"
    local msg="$2"
    if $COLORED_OUTPUT; then
        echo -e "${color}${msg}${RESET}"  # Print colored message
    else
        echo "$msg"  # Print plain message
    fi
}

# Function to install dependencies
install_dependencies() {
    message "$GREEN" "Installing dependencies..."
    pkg update -y
    pkg install -y megatools termux-api gnupg
    if [ $? -eq 0 ]; then
        message "$GREEN" "Dependencies installed successfully!"
    else
        message "$RED" "Failed to install dependencies. Please check your internet connection and try again."
        exit 1
    fi
}

# Function to check if logged into MEGA
check_mega_login() {
    if mega-whoami >/dev/null 2>&1; then
        message "$GREEN" "Logged into MEGA as: $(mega-whoami)"
    else
        message "$YELLOW" "You are not logged into MEGA."
        message "$BLUE" "Please log in to your MEGA account."
        read -p "Enter your MEGA email: " MEGA_EMAIL
        read -s -p "Enter your MEGA password: " MEGA_PASSWORD
        echo
        mega-login "$MEGA_EMAIL" "$MEGA_PASSWORD" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            message "$GREEN" "Successfully logged into MEGA as: $(mega-whoami)"
        else
            message "$RED" "Failed to log in. Please check your credentials and try again."
            exit 1
        fi
    fi
}

# Function to check dependencies
check_dependencies() {
    if $CHECK_DEPENDENCIES; then
        commands=("megacmd" "termux-api" "gpg")
        for cmd in "${commands[@]}"; do
            if ! command -v $cmd &> /dev/null; then
                message "$RED" "Error: $cmd is not installed. Installing now..."
                install_dependencies
                break
            fi
        done
    else
        message "$YELLOW" "Dependency checking is disabled."
    fi
}

# Function to collect and upload device info
collect_and_upload_info() {
    # Name of the info file
    INFO_FILE="$TMPDIR/device_info_$(date +"%Y%m%d_%H%M%S").txt"

    # Collect device info
    echo "=== Device Information ===" > "$INFO_FILE"
    echo "Date and Time: $(date)" >> "$INFO_FILE"

    # Collect location (using termux-location)
    if command -v termux-location &> /dev/null; then
        LOCATION=$(termux-location)
        if [ -n "$LOCATION" ]; then
            echo "Location: $LOCATION" >> "$INFO_FILE"
        else
            echo "Location: Not available" >> "$INFO_FILE"
        fi
    else
        echo "Location: termux-location not installed" >> "$INFO_FILE"
    fi

    # Collect battery status (using termux-battery-status)
    if command -v termux-battery-status &> /dev/null; then
        BATTERY=$(termux-battery-status)
        if [ -n "$BATTERY" ]; then
            echo "Battery: $BATTERY" >> "$INFO_FILE"
        else
            echo "Battery: Not available" >> "$INFO_FILE"
        fi
    else
        echo "Battery: termux-battery-status not installed" >> "$INFO_FILE"
    fi

    # Collect Wi-Fi info (using termux-wifi-connectioninfo)
    if command -v termux-wifi-connectioninfo &> /dev/null; then
        WIFI_INFO=$(termux-wifi-connectioninfo)
        if [ -n "$WIFI_INFO" ]; then
            echo "Wi-Fi: $WIFI_INFO" >> "$INFO_FILE"
        else
            echo "Wi-Fi: Not available" >> "$INFO_FILE"
        fi
    else
        echo "Wi-Fi: termux-wifi-connectioninfo not installed" >> "$INFO_FILE"
    fi

    # Upload the info file to MEGA
    if command -v mega-put &> /dev/null; then
        message "$BLUE" "Uploading info file to MEGA..."
        mega-put "$INFO_FILE" "$MEGA_DIR" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            message "$GREEN" "Info file uploaded to MEGA successfully!"
            rm "$INFO_FILE"  # Remove the local file after upload
        else
            message "$RED" "Error uploading info file to MEGA!"
        fi
    else
        message "$RED" "Error: mega-put is not installed."
    fi
}

# Function to encrypt files
encrypt_file() {
    local file="$1"
    if $ENCRYPT_FILES; then
        if [ -z "$CRYPT_PASSWORD" ]; then
            message "$RED" "Error: Encryption password not provided. Use the -p flag."
            exit 1
        fi
        message "$BLUE" "Encrypting $file..."
        echo "$CRYPT_PASSWORD" | gpg --batch --passphrase-fd 0 -c "$file" && rm "$file"
        echo "$file.gpg"
    else
        echo "$file"
    fi
}

# Function to set up the environment
setup() {
    message "$GREEN" "Setting up environment..."
    mkdir -p "$LOCAL_DIR"
    mega-rm -rf "$MEGA_DIR"
    mega-mkdir "$MEGA_DIR"
}

# Function to capture and upload photos
capture_and_upload() {
    while true; do
        # Generate a timestamp in the format YYYYMMDD_HHMMSS
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

        # Name of the photo with the timestamp
        PHOTO="$LOCAL_DIR/$TIMESTAMP.jpg"

        # Capture photo using the selected camera
        message "$GREEN" "Capturing photo: $PHOTO..."
        termux-camera-photo -c "$CAMERA" "$PHOTO"

        # Check if the photo was captured successfully
        if [ -f "$PHOTO" ]; then
            message "$GREEN" "Photo captured and saved to $PHOTO"

            # Encrypt the file if necessary
            FILE_TO_UPLOAD=$(encrypt_file "$PHOTO")

            # Upload the photo to MEGA
            message "$BLUE" "Uploading photo to MEGA..."
            if mega-put "$FILE_TO_UPLOAD" "$MEGA_DIR" >/dev/null 2>&1; then
                message "$GREEN" "Photo uploaded to MEGA successfully!"
                # Clean local files if necessary
                if $CLEAN_FILES; then
                    message "$YELLOW" "Removing local file: $FILE_TO_UPLOAD..."
                    rm "$FILE_TO_UPLOAD"
                fi
            else
                message "$RED" "Error uploading photo to MEGA!"
            fi

            # Collect and upload device info if the -I flag is active
            if $COLLECT_INFO; then
                collect_and_upload_info
            fi

            # Wait for the specified interval before capturing the next photo
            message "$BLUE" "Waiting $INTERVAL seconds for the next capture..."
            sleep "$INTERVAL"
        else
            message "$RED" "Error capturing photo!"
        fi
    done
}

# Function to schedule execution using cron
schedule_cron() {
    if [ -n "$SCHEDULE_TIME" ]; then
        # Validate time format (HH:MM)
        if ! [[ "$SCHEDULE_TIME" =~ ^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
            message "$RED" "Invalid time format. Use HH:MM."
            exit 1
        fi

        # Split time into hours and minutes
        IFS=":" read -r HOUR MINUTE <<< "$SCHEDULE_TIME"

        # Create cron expression
        CRON_EXPR="$MINUTE $HOUR * * *"

        message "$GREEN" "Scheduling execution at $SCHEDULE_TIME daily..."
        (crontab -l 2>/dev/null; echo "$CRON_EXPR $0 -d '$LOCAL_DIR' -m '$MEGA_DIR' -i $INTERVAL -c -k -e -p '$CRYPT_PASSWORD' -C $CAMERA -I") | crontab -
        message "$GREEN" "Scheduling completed!"
        exit 0
    fi
}

# Main execution function
main() {
    display_banner
    check_dependencies
    check_mega_login
    setup
    schedule_cron
    capture_and_upload
}

# Start the script
main