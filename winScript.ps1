Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

# Function to check if running as administrator
function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to create a shortcut to the executable
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
        $exePath = Join-Path -Path (Get-Location) -ChildPath "bin\idealCalcu.exe"
        if (Test-Path $exePath) {
            Start-Process $exePath
        }
        else {
            [System.Windows.MessageBox]::Show("Executable not found. Please build the application first.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
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

    # Default to GUI mode
    Invoke-GUIInstallation
}

# Run the main script
Main

