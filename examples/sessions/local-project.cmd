@echo off
tasklist /fi "WINDOWTITLE eq my-project [Local] - Claude Code" 2>nul | find "cmd.exe" >nul 2>&1
if not errorlevel 1 (
    echo [!] my-project session already open.
    pause
    exit /b 1
)
if exist "%USERPROFILE%\.claude\projects\C--Projects-my-project\*.jsonl" (
    wt new-tab --title "my-project [Local]" cmd /k "cd /d C:\Projects\my-project && claude -c"
) else (
    wt new-tab --title "my-project [Local]" cmd /k "cd /d C:\Projects\my-project && claude"
)
exit /b 0
