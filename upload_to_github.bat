@echo off
echo Adding changes to git...
git add .

echo Committing changes...
git commit -m "Auto-upload: Added daily notes and updates"

echo Pushing to GitHub...
git push

echo.
echo Upload complete! Press any key to close this window.
pause
