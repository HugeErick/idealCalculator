# Make Installation Wizard for Windows
# This script checks and installs Chocolatey, then installs Make

# Function to check if running as administrator
function Test-Adminrights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to install Chocolatey if not already installed
function Install-Chocolatey {
    if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Installing Chocolatey..." -ForegroundColor Yellow
        
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            
            Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to install Chocolatey. Error: $_" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "Chocolatey is already installed." -ForegroundColor Green
    }
}

# Function to install Make
function Install-Make {
    try {
        Write-Host "Installing Make via Chocolatey..." -ForegroundColor Yellow
        choco install make -y
        
        Write-Host "Make installation completed successfully!" -ForegroundColor Green
        
        # Verify installation
        $makeVersion = (& make --version) -join "`n"
        Write-Host "Installed Make Version:`n$makeVersion" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Failed to install Make. Error: $_" -ForegroundColor Red
        exit 1
    }
}

# Main script execution
function Main {
    # Check for admin rights
    if (!(Test-AdminRights)) {
        Write-Host "This script requires administrator rights. Please run PowerShell as an administrator." -ForegroundColor Red
        pause
        exit 1
    }

    # Welcome message
    Write-Host "Make Installation Wizard for Windows" -ForegroundColor Magenta
    Write-Host "This wizard will install Chocolatey (if not already installed) and then install Make." -ForegroundColor Cyan

    # Confirm with user
    $confirmation = Read-Host "Do you want to proceed? (Y/N)"
    if ($confirmation -ne 'Y') {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        exit 0
    }

    # Install Chocolatey and Make
    Install-Chocolatey
    Install-Make

    # Post-installation message
    Write-Host "`nMake is now installed and ready to use in PowerShell or CMD." -ForegroundColor Green
    Write-Host "You can verify the installation by running 'make --version' in your terminal." -ForegroundColor Cyan

    pause
}

# Run the main script
Main
