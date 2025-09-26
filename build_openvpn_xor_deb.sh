#!/bin/bash

# OpenVPN XOR Deb Package Builder
# This script builds a deb package from OpenVPN source with XOR patches
# Author: Automated Build Script
# Version: 1.0

set -e  # Exit on any error

# Configuration
OPENVPN_VERSION="2.5.9"
OPENVPN_URL="https://raw.githubusercontent.com/Tunnelblick/Tunnelblick/master/third_party/sources/openvpn/openvpn-${OPENVPN_VERSION}/openvpn-${OPENVPN_VERSION}.tar.gz"
BUILD_DIR="/tmp/openvpn_xor_build"
LOGFILE="/tmp/openvpn_xor_build.log"

# XOR patches
PATCHES=(
    "02-tunnelblick-openvpn_xorpatch-a.diff"
    "03-tunnelblick-openvpn_xorpatch-b.diff"
    "04-tunnelblick-openvpn_xorpatch-c.diff"
    "05-tunnelblick-openvpn_xorpatch-d.diff"
    "06-tunnelblick-openvpn_xorpatch-e.diff"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOGFILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGFILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOGFILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOGFILE"
}

# Function to install build dependencies
install_build_dependencies() {
    log "Installing build dependencies..."
    
    local dependencies=(
        "build-essential"
        "devscripts"
        "debhelper"
        "dh-make"
        "libssl-dev"
        "liblzo2-dev"
        "liblz4-dev"
        "libpam0g-dev"
        "libsystemd-dev"
        "pkg-config"
        "git"
        "wget"
        "tar"
        "autoconf"
        "automake"
        "libtool"
    )
    
    if [[ $EUID -eq 0 ]]; then
        apt update
        apt install -y "${dependencies[@]}"
    else
        sudo apt update
        sudo apt install -y "${dependencies[@]}"
    fi
    
    log_success "Build dependencies installed."
}

# Function to prepare build directory
prepare_build_directory() {
    log "Preparing build directory..."
    
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
    fi
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    log_success "Build directory prepared: $BUILD_DIR"
}

# Function to download and extract OpenVPN source
download_openvpn_source() {
    log "Downloading OpenVPN source..."
    
    wget "$OPENVPN_URL" -O "openvpn-${OPENVPN_VERSION}.tar.gz" || {
        log_error "Failed to download OpenVPN source"
        exit 1
    }
    
    tar xzf "openvpn-${OPENVPN_VERSION}.tar.gz" || {
        log_error "Failed to extract OpenVPN source"
        exit 1
    }
    
    cd "openvpn-${OPENVPN_VERSION}"
    
    log_success "OpenVPN source downloaded and extracted."
}

# Function to download and apply XOR patches
apply_xor_patches() {
    log "Downloading and applying XOR patches..."
    
    # Initialize git repository for patch application
    git init
    git add .
    git commit -m "Initial OpenVPN source"
    
    for patch in "${PATCHES[@]}"; do
        log "Downloading patch: $patch"
        wget "https://raw.githubusercontent.com/Tunnelblick/Tunnelblick/master/third_party/sources/openvpn/openvpn-${OPENVPN_VERSION}/patches/$patch" || {
            log_error "Failed to download patch: $patch"
            exit 1
        }
        
        log "Applying patch: $patch"
        git apply "$patch" || {
            log_error "Failed to apply patch: $patch"
            exit 1
        }
    done
    
    # Commit patches
    git add .
    git commit -m "Applied XOR patches"
    
    log_success "XOR patches applied successfully."
}

# Function to create debian packaging structure
create_debian_packaging() {
    log "Creating debian packaging structure..."
    
    # Create debian directory
    mkdir -p debian
    
    # Create control file
    cat > debian/control << 'EOF'
Source: openvpn-xor
Section: net
Priority: optional
Maintainer: OpenVPN XOR Builder <builder@local>
Build-Depends: debhelper (>= 10), libssl-dev, liblzo2-dev, liblz4-dev, libpam0g-dev, libsystemd-dev, pkg-config, autoconf, automake, libtool
Standards-Version: 4.1.2
Homepage: https://openvpn.net/

Package: openvpn-xor
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: OpenVPN with XOR obfuscation support
 OpenVPN is a robust and highly flexible VPN daemon that supports many
 different VPN scenarios. This version includes XOR obfuscation patches
 for additional traffic obfuscation capabilities.
EOF

    # Create changelog
    cat > debian/changelog << EOF
openvpn-xor (${OPENVPN_VERSION}-1) unstable; urgency=medium

  * OpenVPN ${OPENVPN_VERSION} with XOR obfuscation patches
  * Built automatically with XOR support

 -- OpenVPN XOR Builder <builder@local>  $(date -R)
EOF

    # Create copyright file
    cat > debian/copyright << 'EOF'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: openvpn-xor
Source: https://openvpn.net/

Files: *
Copyright: OpenVPN Inc. and contributors
License: GPL-2
 This package is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
EOF

    # Create rules file
    cat > debian/rules << 'EOF'
#!/usr/bin/make -f

%:
	dh $@ --with autotools_dev

override_dh_auto_configure:
	./configure --prefix=/usr \
		--enable-static=no \
		--enable-shared \
		--disable-debug \
		--disable-dependency-tracking \
		--enable-systemd \
		--with-crypto-library=openssl

override_dh_auto_install:
	dh_auto_install
	# Remove unwanted files
	rm -f debian/openvpn-xor/usr/share/doc/openvpn-xor/README.systemd
EOF

    chmod +x debian/rules

    # Create compat file
    echo "10" > debian/compat

    # Create source format
    mkdir -p debian/source
    echo "3.0 (quilt)" > debian/source/format

    log_success "Debian packaging structure created."
}

# Function to build deb package
build_deb_package() {
    log "Building deb package..."
    
    # Build the package
    dpkg-buildpackage -us -uc -b || {
        log_error "Failed to build deb package"
        exit 1
    }
    
    # Move built packages to a results directory
    cd "$BUILD_DIR"
    mkdir -p results
    mv *.deb results/ 2>/dev/null || true
    mv *.changes results/ 2>/dev/null || true
    
    log_success "Deb package built successfully!"
    log "Built packages are available in: $BUILD_DIR/results/"
    
    # List built packages
    if [[ -d "results" ]]; then
        log "Built packages:"
        ls -la results/*.deb 2>/dev/null || log_warning "No deb packages found in results directory"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -k, --keep-build    Keep build directory after completion"
    echo "  -v, --verbose       Enable verbose output"
    echo ""
    echo "This script builds OpenVPN XOR deb package from source with XOR patches."
}

# Function to cleanup
cleanup() {
    if [[ -d "$BUILD_DIR" ]]; then
        log "Cleaning up build directory..."
        rm -rf "$BUILD_DIR"
    fi
}

# Main function
main() {
    local keep_build=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -k|--keep-build)
                keep_build=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                set -x
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log "Starting OpenVPN XOR deb package build..."
    log "Log file: $LOGFILE"
    
    # Execute build steps
    install_build_dependencies
    prepare_build_directory
    download_openvpn_source
    apply_xor_patches
    create_debian_packaging
    build_deb_package
    
    if [[ "$keep_build" == "false" ]]; then
        cleanup
    else
        log "Keeping build directory: $BUILD_DIR"
    fi
    
    log_success "OpenVPN XOR deb package build completed successfully!"
}

# Set up signal handlers
trap 'log_error "Build interrupted by user"; cleanup; exit 1' INT TERM

# Run main function
main "$@"