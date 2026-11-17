@echo off
REM Godot CLI Export Script for "Distruggi la Stanza"

echo ========================================
echo Godot Export - Destroy The Room
echo ========================================

REM Check if Godot is in PATH
where godot >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Godot CLI not found in PATH.
    echo Please install Godot 4.7.2 and add to PATH, or update this script with Godot install path.
    pause
    exit /b 1
)

REM Navigate to export directory
cd /d "%~dp0"

REM Run Godot export for Windows Desktop
echo Exporting to Windows Desktop...
godot --export "Windows Desktop" bin/

if %ERRORLEVEL% EQU 0 (
    echo ========================================
    echo Export successful! Executable at: bin\DestroyTheRoom.exe
    echo ========================================
) else (
    echo ========================================
    echo ERROR: Export failed with code %ERRORLEVEL%
    echo ========================================
)

pause