# OpenVPN XOR Package - Automatic Installation

This repository contains pre-built OpenVPN packages with XOR obfuscation support and automated installation scripts for Debian-based systems.

## Features

- **Pre-built Packages**: Ready-to-install deb packages with XOR obfuscation support
- **Automatic Installation**: Bash script that handles the complete installation process
- **Source Building**: Optional script to build packages from OpenVPN source with XOR patches
- **Dependency Management**: Automatic detection and installation of required dependencies
- **Universal Compatibility**: Works on any Debian-based system with apt/dpkg support

## Quick Installation

### Method 1: Direct Installation Script

Run this one-liner to automatically install OpenVPN XOR:

```bash
curl -fsSL https://raw.githubusercontent.com/Lunatik-cyber/OpenVPN_XOR_package/main/auto_install_openvpn_xor.sh | sudo bash
```

### Method 2: Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/Lunatik-cyber/OpenVPN_XOR_package.git
cd OpenVPN_XOR_package
```

2. Run the installation script:
```bash
sudo ./auto_install_openvpn_xor.sh
```

## Installation Scripts

### auto_install_openvpn_xor.sh

Main installation script that:
1. Clones the OpenVPN_XOR_package repository
2. Checks system compatibility
3. Installs necessary dependencies
4. Installs pre-built deb packages or builds from source if needed
5. Verifies the installation

**Usage:**
```bash
./auto_install_openvpn_xor.sh [options]

Options:
  -h, --help          Show help message
  -k, --keep-files    Keep temporary files after installation
  -v, --verbose       Enable verbose output
```

### build_openvpn_xor_deb.sh

Source building script that:
1. Downloads OpenVPN source code
2. Applies XOR obfuscation patches
3. Creates debian packaging structure
4. Builds deb packages from source

**Usage:**
```bash
./build_openvpn_xor_deb.sh [options]

Options:
  -h, --help          Show help message
  -k, --keep-build    Keep build directory after completion
  -v, --verbose       Enable verbose output
```

## Pre-built Packages

The repository includes the following pre-built packages:

- `openvpn_2.5.9-1_amd64.deb` - Main OpenVPN package with XOR support
- `libssl1.0.0_*_amd64.deb` - SSL library dependencies (multiple versions)
- `libssl1.1_*_amd64.deb` - SSL library dependencies
- `openssl_*_amd64.deb` - OpenSSL packages
- `multiarch-support_*_amd64.deb` - Multi-architecture support

## System Requirements

### Supported Systems
- Ubuntu 16.04 LTS and newer
- Debian 9 (Stretch) and newer
- Other Debian-based distributions with apt/dpkg support

### Dependencies
The installation script automatically installs these dependencies:
- `git` - For repository cloning
- `wget`, `curl` - For downloading resources
- `build-essential` - Compilation tools (if building from source)
- `devscripts`, `debhelper`, `dh-make` - Debian packaging tools
- SSL/TLS libraries as needed

## XOR Obfuscation

The OpenVPN packages in this repository include XOR obfuscation patches that allow traffic obfuscation to bypass deep packet inspection (DPI) systems.

### XOR Configuration Example

Add these options to your OpenVPN configuration file:

```
# Enable XOR obfuscation
scramble obfuscate your_password_here

# Or use reverse XOR
scramble reverse

# XOR with specific key
scramble xor your_xor_key
```

**Note**: Both client and server must use the same XOR configuration.

## Security Considerations

- Always verify package integrity before installation
- Use strong, unique XOR keys for obfuscation
- Keep OpenVPN and system packages updated
- Use proper firewall and network security measures

## Troubleshooting

### Common Issues

1. **Permission Denied**: Run the script with sudo privileges
   ```bash
   sudo ./auto_install_openvpn_xor.sh
   ```

2. **Package Conflicts**: Remove existing OpenVPN installations
   ```bash
   sudo apt remove openvpn
   sudo apt autoremove
   ```

3. **Dependency Issues**: Force dependency resolution
   ```bash
   sudo apt install -f
   ```

4. **Build Failures**: Install additional build dependencies
   ```bash
   sudo apt install autoconf automake libtool
   ```

### Log Files

Installation logs are saved to:
- `/tmp/openvpn_xor_install.log` - Installation log
- `/tmp/openvpn_xor_build.log` - Build log (if building from source)

### Verification

After installation, verify OpenVPN is working:

```bash
# Check version
openvpn --version

# Check for XOR support (if available in help)
openvpn --help | grep -i xor

# Test configuration
sudo openvpn --config your_config.ovpn --verb 4
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project contains scripts and packages related to OpenVPN, which is licensed under the GPL v2. Please refer to the original OpenVPN license for more information.

## Disclaimer

This software is provided "as is" without warranty of any kind. Use at your own risk. The XOR obfuscation patches are third-party modifications and may not be suitable for all use cases.

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the log files for error details
3. Create an issue in the GitHub repository
4. Refer to the official OpenVPN documentation

---

**Note**: XOR obfuscation may not be legal in all jurisdictions. Please ensure compliance with local laws and regulations before use.