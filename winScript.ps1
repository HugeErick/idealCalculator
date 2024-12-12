Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

# Function to check if running as administrator
function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to install Chocolatey if not already installed
function Install-Chocolatey {
    if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        try {
            Write-Host "Chocolatey not found. Installing Chocolatey..." -ForegroundColor Yellow
            
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            
            Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "Failed to install Chocolatey. Error: $_" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "Chocolatey is already installed." -ForegroundColor Green
        return $true
    }
}

# Function to check if MSYS2 is already installed
function Test-MSYS2Installed {
    return (Get-Command msys2 -ErrorAction SilentlyContinue) -or 
           (Test-Path "C:\msys64\usr\bin\msys-2.0.dll") -or 
           (Test-Path "C:\Program Files\MSYS2\msys2.exe")
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
        return $true
    }
    catch {
        Write-Host "Failed to install Make. Error: $_" -ForegroundColor Red
        return $false
    }
}

# Function to install MSYS2
function Install-MSYS2 {
    try {
        # Check if already installed
        if (Test-MSYS2Installed) {
            Write-Host "MSYS2 is already installed." -ForegroundColor Green
            return $true
        }

        Write-Host "Installing MSYS2 via Chocolatey..." -ForegroundColor Yellow
        choco install msys2 -y
        
        Write-Host "MSYS2 installation completed successfully!" -ForegroundColor Green
        
        # Verify installation
        $msys2Version = & msys2 --version 2>&1
        Write-Host "Installed MSYS2 Version:`n$msys2Version" -ForegroundColor Cyan
        
        # Perform initial update and install base development tools
        Write-Host "Updating MSYS2 and installing base development tools..." -ForegroundColor Yellow
        Start-Process "C:\msys64\msys2.exe" -ArgumentList "-c 'pacman -Syu --noconfirm'" -Wait
        Start-Process "C:\msys64\msys2.exe" -ArgumentList "-c 'pacman -S --noconfirm base-devel mingw-w64-x86_64-toolchain git'" -Wait
        
        return $true
    }
    catch {
        Write-Host "Failed to install MSYS2. Error: $_" -ForegroundColor Red
        return $false
    }
}

# Function to install Raylib
function Install-Raylib {
    try {
        Write-Host "Installing Raylib via Chocolatey..." -ForegroundColor Yellow
        choco install raylib -y
        
        Write-Host "Raylib installation completed successfully!" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Host "Failed to install Raylib. Error: $_" -ForegroundColor Red
        return $false
    }
}

function Create-Shortcut {
    param (
        [string]$TargetPath,
        [string]$ShortcutPath
    )
    try {
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.Save()
        Write-Host "Shortcut created successfully: $ShortcutPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create shortcut. Error: $_" -ForegroundColor Red
    }
}

# GUI Installation Function
function Invoke-GUIInstallation {
    # Create WPF Window
    [xml]$xaml = @"
    <Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Development Tools Installation Wizard" Height="500" Width="600"
        WindowStartupLocation="CenterScreen">
        <Grid>
            <StackPanel Margin="20">
                <TextBlock Text="Development Tools Installation Wizard" FontSize="24" FontWeight="Bold" Margin="0,0,0,20" HorizontalAlignment="Center"/>
                
                <TextBlock Text="This wizard will install Chocolatey, Make, and MSYS2 for development tools." 
                           TextWrapping="Wrap" Margin="0,0,0,20" HorizontalAlignment="Center"/>
                
                <ProgressBar Name="progressBar" Height="20" Margin="0,0,0,20" Minimum="0" Maximum="100"/>
                
                <TextBlock Name="statusText" Text="" TextWrapping="Wrap" Margin="0,0,0,20" HorizontalAlignment="Center"/>
                
                <CheckBox Name="shortcutCheckbox" Content="Create Shortcut for idealCalculator" Margin="0,0,0,20" HorizontalAlignment="Center"/>

                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                    <Button Name="installButton" Content="Install" Width="100" Margin="0,0,10,0"/>
                    <Button Name="runButton" Content="Run" Width="100" Margin="0,0,10,0" IsEnabled="False"/>
                    <Button Name="finishButton" Content="Finish" Width="100" IsEnabled="False"/>
                    <Button Name="cancelButton" Content="Cancel" Width="100" Margin="10,0,0,0"/>
                </StackPanel>
            </StackPanel>
        </Grid>
    </Window>
"@

    # Create Window
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)

    # Get Controls
    $progressBar = $window.FindName("progressBar")
    $statusText = $window.FindName("statusText")
    $shortcutCheckbox = $window.FindName("shortcutCheckbox")
    $installButton = $window.FindName("installButton")
    $runButton = $window.FindName("runButton")
    $finishButton = $window.FindName("finishButton")
    $cancelButton = $window.FindName("cancelButton")

    # Event Handlers
    $cancelButton.Add_Click({
        $window.Close()
    })

    $finishButton.Add_Click({
        $window.Close()
    })

    $runButton.Add_Click({
        # Run make clean and make run first
        try {
            Write-Host "Running make clean..." -ForegroundColor Yellow
            & make clean

            Write-Host "Running make run to build Windows binaries..." -ForegroundColor Yellow
            & make run
        }
        catch {
            [System.Windows.MessageBox]::Show("Error running make commands: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
            return
        }

        # After make commands, check for executable
        $exePath = Join-Path -Path (Get-Location) -ChildPath "bin\idealCalcu.exe"
        if (Test-Path $exePath) {
            Start-Process $exePath
        }
        else {
            [System.Windows.MessageBox]::Show("Executable not found after make commands. Please check your build process.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    })

    $installButton.Add_Click({
        # Disable install button during process
        $installButton.IsEnabled = $false
        $statusText.Text = ""
        $progressBar.Value = 0

        # Check Admin Rights
        if (!(Test-AdminRights)) {
            [System.Windows.MessageBox]::Show("This installer requires administrator rights.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
            $installButton.IsEnabled = $true
            return
        }

        # Update Status for Chocolatey
        $statusText.Text = "Installing Chocolatey..."
        $progressBar.Value = 25
        $chocoResult = Install-Chocolatey

        if ($chocoResult) {
            # Update Status for Make
            $statusText.Text = "Installing Make..."
            $progressBar.Value = 50
            $makeResult = Install-Make

            if ($makeResult) {
                # Update Status for MSYS2
                $statusText.Text = "Installing MSYS2..."
                $progressBar.Value = 75
                $msys2Result = Install-MSYS2

                if ($msys2Result) {
                    # Add Raylib installation
                    $statusText.Text = "Installing Raylib..."
                    $progressBar.Value = 90
                    $raylibResult = Install-Raylib

                    if ($raylibResult) {
                        $statusText.Text = "Installation Complete!"
                        $progressBar.Value = 100

                        # Check if shortcut creation is selected
                        if ($shortcutCheckbox.IsChecked -eq $true) {
                            $exePath = Join-Path -Path (Get-Location) -ChildPath "bin\idealCalcu.exe"
                            $shortcutPath = [Environment]::GetFolderPath("Desktop") + "\idealCalculator.lnk"
                            Create-Shortcut -TargetPath $exePath -ShortcutPath $shortcutPath
                        }

                        $finishButton.IsEnabled = $true
                        $runButton.IsEnabled = $true
                        $installButton.Visibility = 'Collapsed'
                        [System.Windows.MessageBox]::Show("Chocolatey, Make, MSYS2, and Raylib have been successfully installed.", "Success", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
                    }
                    else {
                        $statusText.Text = "Raylib Installation Failed"
                        [System.Windows.MessageBox]::Show("Failed to install Raylib.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
                        $installButton.IsEnabled = $true
                    }
                }
                else {
                    $statusText.Text = "MSYS2 Installation Failed"
                    [System.Windows.MessageBox]::Show("Failed to install MSYS2.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
                    $installButton.IsEnabled = $true
                }
            }
            else {
                $statusText.Text = "Make Installation Failed"
                [System.Windows.MessageBox]::Show("Failed to install Make.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
                $installButton.IsEnabled = $true
            }
        }
        else {
            $statusText.Text = "Chocolatey Installation Failed"
            [System.Windows.MessageBox]::Show("Failed to install Chocolatey.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
            $installButton.IsEnabled = $true
        }
    })

    # Show Window
    $window.ShowDialog() | Out-Null
}



# Main script execution
function Main {
    # Check for admin rights
    if (!(Test-AdminRights)) {
        Write-Host "This script requires administrator rights. Please run PowerShell as an administrator." -ForegroundColor Red
        pause
        exit 1
    }

    # Default to GUI mode
    Invoke-GUIInstallation
}

# Run the main script
Main
