@echo off
echo Creating Laravel directory structure...

if not exist "bootstrap\cache" mkdir "bootstrap\cache"
if not exist "storage\app" mkdir "storage\app"
if not exist "storage\app\public" mkdir "storage\app\public"
if not exist "storage\framework" mkdir "storage\framework"
if not exist "storage\framework\cache" mkdir "storage\framework\cache"
if not exist "storage\framework\cache\data" mkdir "storage\framework\cache\data"
if not exist "storage\framework\sessions" mkdir "storage\framework\sessions"
if not exist "storage\framework\views" mkdir "storage\framework\views"
if not exist "storage\logs" mkdir "storage\logs"

echo Creating .gitkeep files...
echo. > "bootstrap\cache\.gitkeep"
echo. > "storage\app\.gitkeep"
echo. > "storage\app\public\.gitkeep"
echo. > "storage\framework\.gitkeep"
echo. > "storage\framework\cache\.gitkeep"
echo. > "storage\framework\cache\data\.gitkeep"
echo. > "storage\framework\sessions\.gitkeep"
echo. > "storage\framework\views\.gitkeep"
echo. > "storage\logs\.gitkeep"

echo Directory structure created successfully!
pause