Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

# Load the existing winScript.ps1 functions
function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Chocolatey {
    if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            return $true
        }
        catch {
            return $false
        }
    }
    return $true
}

function Install-Make {
    try {
        choco install make -y
        return $true
    }
    catch {
        return $false
    }
}

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
                <Button Name="cancelButton" Content="Cancel" Width="100"/>
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
$cancelButton = $window.FindName("cancelButton")

# Event Handlers
$cancelButton.Add_Click({
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
            [System.Windows.MessageBox]::Show("Make has been successfully installed.", "Success", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        }
        else {
            $statusText.Text = "Make Installation Failed"
            [System.Windows.MessageBox]::Show("Failed to install Make.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    }
    else {
        $statusText.Text = "Chocolatey Installation Failed"
        [System.Windows.MessageBox]::Show("Failed to install Chocolatey.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }

    $installButton.IsEnabled = $true
})

# Show Window
$window.ShowDialog() | Out-Null
