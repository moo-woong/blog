#!/bin/bash

# Current date and time
date_time=$(date +"%Y-%m-%d_%H-%M-%S")

# 1. Build Hugo site
hugo

# 2. Move to 'public' folder
cd public

# 3. User input commit message
echo "Enter commit message: "
read commit_message

# 4. Add changes and commit
git add .
git commit -m "$commit_message"

# 5. Move back to project root
cd ../

# 6. Update submodule
git submodule update --init --recursive

# 7. Add changes and commit
git add .
git commit -m "Submodule update - $date_time"

# 8. Deploy to Github Pages
git push -u origin master --recurse-submodules=on-demand

# 9. Restore working directory
cd $current_dir

echo "Deployment complete!"
