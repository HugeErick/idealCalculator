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

# CLI Installation Function
function Invoke-CLIInstallation {
    # (Kept the same as in the original script)
    # ... (previous CLI installation code)
}

# GUI Installation Function
function Invoke-GUIInstallation {
    # Create WPF Window
    [xml]$xaml = @"
    <Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Make Installation Wizard" Height="450" Width="600"
        WindowStartupLocation="CenterScreen">
        <Grid>
            <StackPanel Margin="20">
                <TextBlock Text="Make Installation Wizard" FontSize="24" FontWeight="Bold" Margin="0,0,0,20" HorizontalAlignment="Center"/>
                
                <TextBlock Text="This wizard will install Chocolatey (if not already installed) and Make." 
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
            $progressBar.Value = 75
            $makeResult = Install-Make

            if ($makeResult) {
                $statusText.Text = "Installation Complete!"
                $progressBar.Value = 100
                $finishButton.IsEnabled = $true
                $installButton.Visibility = 'Collapsed'
                [System.Windows.MessageBox]::Show("Make has been successfully installed.", "Success", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
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
