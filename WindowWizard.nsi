; Installs Chocolatey, Make, and MSYS2
; Modern UI and Logic
!include "MUI2.nsh"
!include "LogicLib.nsh"
; Installer Details
Name "Dev Environment Installer"
OutFile "DevEnvironmentSetup.exe"
RequestExecutionLevel admin
InstallDir "C:\DevTools"
; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"
; Sections
Section "Chocolatey" SEC_CHOCOLATEY
    DetailPrint "Checking and Installing Chocolatey..."
    
    ; Use PowerShell to download and install Chocolatey
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1''))"'
    Pop $0
    ${If} $0 == "0"
        DetailPrint "Chocolatey installed successfully."
        MessageBox MB_OK "Chocolatey installed successfully."
    ${Else}
        DetailPrint "Failed to install Chocolatey."
        MessageBox MB_OK "Failed to install Chocolatey."
        Abort
    ${EndIf}
SectionEnd

Section "Make" SEC_MAKE
    DetailPrint "Installing Make via Chocolatey..."
    
    ; Install Make using Chocolatey
    nsExec::ExecToLog 'choco install make -y'
    Pop $0
    ${If} $0 == "0"
        DetailPrint "Make installed successfully."
        MessageBox MB_OK "Make installed successfully."
    ${Else}
        DetailPrint "Failed to install Make."
        MessageBox MB_OK "Failed to install Make."
        Abort
    ${EndIf}
SectionEnd

Section "MSYS2" SEC_MSYS2
    DetailPrint "Downloading MSYS2 Installer..."
    
    ; Download MSYS2 Installer using PowerShell
    nsExec::ExecToLog 'powershell -Command "(New-Object System.Net.WebClient).DownloadFile(''https://github.com/msys2/msys2-installer/releases/download/2024-01-13/msys2-x86_64-20240113.exe'', ''$TEMP\msys2-installer.exe'')"'
    Pop $0
    ${If} $0 == "0"
        DetailPrint "MSYS2 installer downloaded successfully."
        
        ; Silent installation of MSYS2
        ExecWait '"$TEMP\msys2-installer.exe" /SILENT' $0
        ${If} $0 == "0"
            DetailPrint "MSYS2 installed successfully."
            
            ; Update MSYS2 and install development tools
            nsExec::ExecToLog 'C:\msys64\usr\bin\bash.exe -c "pacman -Syu --noconfirm"'
            nsExec::ExecToLog 'C:\msys64\usr\bin\bash.exe -c "pacman -S --noconfirm mingw-w64-x86_64-toolchain base-devel"'
            
            MessageBox MB_OK "MSYS2 installed successfully."
        ${Else}
            DetailPrint "Failed to install MSYS2."
            MessageBox MB_OK "Failed to install MSYS2."
            Abort
        ${EndIf}
    ${Else}
        DetailPrint "Failed to download MSYS2 installer."
        MessageBox MB_OK "Failed to download MSYS2 installer."
        Abort
    ${EndIf}
SectionEnd

; Section Initialization
Function .onInit
    ; Set default section selections
    IntOp $0 ${SF_SELECTED} | ${SF_BOLD}
    SectionSetFlags ${SEC_CHOCOLATEY} $0
    SectionSetFlags ${SEC_MAKE} $0
    SectionSetFlags ${SEC_MSYS2} $0
FunctionEnd

Function .onInstSuccess
    MessageBox MB_OK "Development environment setup is complete!"
FunctionEnd
