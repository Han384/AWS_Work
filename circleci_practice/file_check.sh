#!/bin/bash

# Set the path to the file
file_path="/tmp/workspace/env_set_serverspec.sh"

# Check if the file exists
if [ -f "$file_path" ]; then
    # Do something with the file
    echo "File exists!"
else
    echo "File does not exist!"
    touch /tmp/workspace/env_set_serverspec.sh
    echo "created the File：/tmp/workspace/env_set_serverspec.sh"
fi
