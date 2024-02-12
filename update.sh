#!/bin/bash

# Current date and time
date_time=$(date +"%Y-%m-%d_%H-%M-%S")
current_dir=$pwd

echo "Enter commit message: "
read message
commit_message="$date_time-$message" 

# 1. Build Hugo site
hugo > /dev/null 2>&1

# 2. Move to 'public' folder
cd public

# 4. Add changes and commit
git add . > /dev/null 2>&1
git commit -m "$commit_message"  > /dev/null 2>&1
echo "git push from submodules"
git push origin master > /dev/null 2>&1

# 5. Move back to project root
cd ../

# 7. Add changes and commit
git add . > /dev/null 2>&1
git commit -m "$commit_message" > /dev/null 2>&1
echo "git push from parent repo"
git push origin master > /dev/null 2>&1
