Multi Search

Multi Search is a command-line tool written in Bash that simplifies web searches directly from the terminal, especially on Android devices using Termux. With support for multiple search engines, customizable configurations, and advanced features, it is ideal for developers, researchers, and tech enthusiasts.
📦 Features

    Search Across Multiple Engines:

        Support for over 50 search engines, including Google, DuckDuckGo, GitHub, YouTube, arXiv, and many more.

        Organized into categories such as general search, technology, academic, media, shopping, etc.

    Configuration File:

        Customize the default search engine.

        Add new search engines or modify existing ones.

    Batch Searches:

        Execute multiple searches from a text file.

    Android Integration:

        Opens URLs directly in the default Android browser using the am start command.

    Ease of Use:

        Detailed help interface (--help).

        Lists all available search engines (--list).

🚀 How to Use
Installation

    Ensure you have Termux installed on your Android device.

    Copy the searchhelper.sh script to your device.

    Make the script executable:
    bash

    chmod +x searchhelper.sh

Basic Usage
bash

./searchhelper.sh [OPTIONS] "SEARCH TERMS"

Examples

    Simple Search:
    bash

    ./searchhelper.sh -e google "search terms"

    Search Across Multiple Engines:
    bash

    ./searchhelper.sh -m google,ddg,github "search terms"

    Batch Search:
    bash

    ./searchhelper.sh -f queries.txt

    List Available Search Engines:
    bash
    
    ./searchhelper.sh --list

    Help:
    bash
    
    ./searchhelper.sh --help

⚙️ Configuration

The script loads settings from a configuration file located at ~/.config/searchhelper.conf. You can customize the script's behavior by editing this file.
Example Configuration File
bash


# Set default search engine
DEFAULT_ENGINE="startpage"

# Add a custom search engine
SEARCH_ENGINES["myrepo"]="https://repo.example.com/search?q={query}"

# Modify an existing search engine
SEARCH_ENGINES["github"]="https://github.com/search?q={query}&type=code"

📂 Project Structure

    searchhelper.sh: Main script.

    searchhelper.conf: Configuration file (optional).

    README.md: This file.

📌 Tips

    Use the --list command to explore all available search engines.

    Customize the configuration file to adapt the script to your needs.

    For frequent searches, create an alias in your terminal:
    bash
    
    alias search="./searchhelper.sh"

Now you're ready to use Multi Search! 🎉