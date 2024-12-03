# idealCalculator

## Description

idealCalculator is a C-based numerical integration tool that implements the Composite Trapezoidal Rule and the Composite Midpoint Rule. This project provides efficient and accurate methods for approximating definite integrals, making it useful for various scientific and engineering applications.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Installation

### Prerequisites

- C compiler
- Make build system

### Steps

1. Install Make:
   - **Linux (Ubuntu/Debian)**:  
     ```bash
     sudo apt-get install make
     ```
   - **macOS**:  
     Install Xcode Command Line Tools:  
     ```bash
     xcode-select --install
     ```
   - **Windows**:  
     Run wizard: 
     ```
     DevEnvironmentSetup.exe
     ```
     Alternative Manual Installation Method:
     1. Open PowerShell as Administrator
     2. Install Chocolatey:
        ```powershell
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        ```
     3. Install Make:
        ```powershell
        choco install make
        ```
     4. Restart PowerShell or your system to ensure Make is accessible from the command line.

2. Clone the repository:
   ```bash
   git clone https://github.com/HugeErick/idealCalculator.git
   cd idealCalculator
   ```

3. Build the project:
   ```bash
   make
   ```

## Usage

Run the application and follow the prompts to perform numerical integration calculations.

## Features

- Implements the Composite Trapezoidal Rule
- Implements the Composite Midpoint Rule
- Lightweight and efficient
- Cross-platform compatibility (Linux, macOS, Windows)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Erick Gonzalez Parada - erick.parada101@gmail.com

Project Link: [https://github.com/HugeErick/idealCalculator](https://github.com/HugeErick/idealCalculator)

