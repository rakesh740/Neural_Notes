# Transcribe Meetings

## Overview

This project provides a shell script (`transcribe_meetings.sh`) designed to automate the process of transcribing meetings. The script is intended to streamline the workflow of converting recorded meeting audio into text, making it easier to document, search, and share meeting content.

## What It Does

- Takes an audio recording of a meeting as input.
- Processes the audio file using a transcription service or tool (details depend on the script's implementation).
- Outputs a text file containing the transcribed content of the meeting.

## Why Use This?

- **Efficiency:** Automates the manual process of transcribing meetings, saving time and effort.
- **Documentation:** Provides accurate records of meetings for future reference, compliance, or sharing with absent participants.
- **Searchability:** Makes meeting content searchable and accessible.

## How to Run the System

1. **Prerequisites:**
   - Ensure you have the necessary dependencies installed (e.g., transcription tools, audio processing utilities). Check the script for specific requirements.
   - Place your meeting audio file (e.g., `.wav`, `.mp3`) in an accessible directory.

2. **Usage:**

   - Open a terminal and navigate to the project directory:

     ```sh
     cd /Users/rakeshrakshit/Projects/transcribe_meetings
     ```

   - Make the script executable (if not already):

     ```sh
     chmod +x transcribe_meetings.sh
     ```

   - Run the script with your audio file as an argument:

     ```sh
     ./transcribe_meetings.sh path/to/your/meeting_audio.wav
     ```

   - The script will process the audio and output a transcript file (check the script for output location and format).

3. **Customization:**
   - You can modify the script to use different transcription services or adjust output formatting as needed.



## Potential Security Issues

While the script is generally safe for its intended use, consider the following potential security issues:

- **Hardcoded Paths:** The script uses hardcoded absolute paths for `SOURCE_DIR` and `DEST_DIR`. If these directories are user-writable, there is a risk of malicious files being placed there. Restrict permissions or validate file origins if possible.
- **No Input Sanitization:** If the script is modified to accept user input (e.g., file paths or model names as arguments), ensure all inputs are sanitized to prevent command injection.
- **File Overwrite Risk:** The script overwrites output files in `DEST_DIR` without prompting. If a file with the same name exists, it will be replaced. Consider adding checks or backups if this is a concern.
- **Moving Files to Trash:** The script moves all `.m4a` files from `SOURCE_DIR` to `~/.Trash/` after processing. If run with elevated privileges, this could move unintended files. Ensure the script is run with the correct user permissions.
- **No Quoting in mv Command:** The `mv` command uses a glob without quotes. While `nullglob` is set, always ensure quoting is used to prevent word splitting or globbing issues.

**Recommendations:**
- Avoid running the script as root.
- Ensure only trusted files are present in `SOURCE_DIR`.
- Consider parameterizing paths and adding input validation if you expand its functionality.


- For more details on configuration or troubleshooting, review the comments within `transcribe_meetings.sh`.
- If you encounter issues, ensure all dependencies are installed and accessible in your environment.
