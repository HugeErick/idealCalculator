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

# GUI Installation Function
function Invoke-GUIInstallation {
    # Create WPF Window
    [xml]$xaml = @"
    <Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Development Tools Installation Wizard" Height="450" Width="600"
        WindowStartupLocation="CenterScreen">
        <Grid>
            <StackPanel Margin="20">
                <TextBlock Text="Development Tools Installation Wizard" FontSize="24" FontWeight="Bold" Margin="0,0,0,20" HorizontalAlignment="Center"/>
                
                <TextBlock Text="This wizard will install Chocolatey, Make, and MSYS2 for development tools." 
                           TextWrapping="Wrap" Margin="0,0,0,20" HorizontalAlignment="Center"/>
                
                <ProgressBar Name="progressBar" Height="20" Margin="0,0,0,20" Minimum="0" Maximum="100"/>
                
                <TextBlock Name="statusText" Text="" TextWrapping="Wrap" Margin="0,0,0,20" HorizontalAlignment="Center"/>
                
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                    <Button Name="installButton" Content="Install" Width="100" Margin="0,0,10,0"/>
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
    $installButton = $window.FindName("installButton")
    $finishButton = $window.FindName("finishButton")
    $cancelButton = $window.FindName("cancelButton")

    # Event Handlers
    $cancelButton.Add_Click({
        $window.Close()
    })

    $finishButton.Add_Click({
        $window.Close()
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
                    $statusText.Text = "Installation Complete!"
                    $progressBar.Value = 100
                    $finishButton.IsEnabled = $true
                    $installButton.Visibility = 'Collapsed'
                    [System.Windows.MessageBox]::Show("Chocolatey, Make, and MSYS2 have been successfully installed.", "Success", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
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

    # Determine installation mode based on arguments
    if ($args.Count -gt 0) {
        switch ($args[0]) {
            "gui" { Invoke-GUIInstallation }
            "cli" { Invoke-CLIInstallation }
            default { 
                Write-Host "Invalid argument. Use 'gui' or 'cli'." -ForegroundColor Red
                exit 1
            }
        }
    }
    else {
        # Default to CLI if no argument provided
        Invoke-CLIInstallation
    }
}

# Run the main script
Main @args
