#!/bin/bash

# Set the path to the file
file_path="/tmp/workspace/env.txt"

# Check if the file exists
if [ -f "$file_path" ]; then
    # Do something with the file
    echo "File exists!"
else
    echo "File does not exist!"
    touch /tmp/workspace/env.txt
    echo "created the File：/tmp/workspace/env.txt"
fi
