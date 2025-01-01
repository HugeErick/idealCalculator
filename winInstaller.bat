@echo off
setlocal EnableDelayedExpansion

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator rights.
    echo Please run as administrator.
    pause
    exit /b 1
)

echo Checking and installing dependencies...
echo.

:: Check if Chocolatey is installed
where choco >nul 2>&1
if %errorLevel% neq 0 (
    echo Installing Chocolatey...
    @powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if %errorLevel% neq 0 (
        echo Failed to install Chocolatey
        pause
        exit /b 1
    )
    echo Chocolatey installed successfully!
    :: Refresh environment variables
    call refreshenv
) else (
    echo Chocolatey is already installed
)

echo.
echo Installing Make...
choco install make -y
if %errorLevel% neq 0 (
    echo Failed to install Make
    pause
    exit /b 1
)
echo Make installed successfully!

echo.
echo Installing MSYS2...
:: Check if MSYS2 is already installed
if exist "C:\msys64\usr\bin\msys-2.0.dll" (
    echo MSYS2 is already installed
) else (
    choco install msys2 -y
    if %errorLevel% neq 0 (
        echo Failed to install MSYS2
        pause
        exit /b 1
    )
    echo MSYS2 installed successfully!
    
    echo Updating MSYS2 and installing development tools...
    C:\msys64\usr\bin\bash -lc "pacman -Syu --noconfirm"
    C:\msys64\usr\bin\bash -lc "pacman -S --noconfirm base-devel mingw-w64-x86_64-toolchain git"
)

echo.
echo Installing Raylib using MSYS2...
:: Install Raylib using MSYS2's package manager
C:\msys64\usr\bin\bash -lc "pacman -S --noconfirm mingw-w64-x86_64-raylib"
if %errorLevel% neq 0 (
    echo Failed to install Raylib
    pause
    exit /b 1
)

:: Add MinGW binaries to PATH if not already present
set "MINGW_PATH=C:\msys64\mingw64\bin"
echo %PATH% | find /i "%MINGW_PATH%" >nul || (
    setx PATH "%PATH%;%MINGW_PATH%" /M
    if %errorLevel% neq 0 (
        echo Failed to add MinGW path to PATH
        pause
        exit /b 1
    )
)

echo.
echo All dependencies installed successfully!
echo You may need to restart your command prompt for PATH changes to take effect.
pause
