prepare_openvpn_source() {
    echo "Preparing OpenVPN source..."
    mkdir -p /opt/openvpn_install && cd /opt/openvpn_install
    wget https://raw.githubusercontent.com/Tunnelblick/Tunnelblick/master/third_party/sources/openvpn/openvpn-2.6.14/openvpn-2.6.14.tar.gz
    tar xvf openvpn-2.6.14.tar.gz
    cd openvpn-2.6.14
}

# == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
download_and_apply_patches() {
    echo "Downloading and applying patches..."
    local patches=(
        "02-tunnelblick-openvpn_xorpatch-a.diff"
        "03-tunnelblick-openvpn_xorpatch-b.diff"
        "04-tunnelblick-openvpn_xorpatch-c.diff"
        "05-tunnelblick-openvpn_xorpatch-d.diff"
        "06-tunnelblick-openvpn_xorpatch-e.diff"
    )

    for patch in "${patches[@]}"; do
        wget "https://raw.githubusercontent.com/Tunnelblick/Tunnelblick/master/third_party/sources/openvpn/openvpn-2.6.14/patches/$patch"
        git apply "$patch"
    done
}

# == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
compile_and_install_openvpn() {
    echo "Compiling and installing OpenVPN..."
    ./configure --enable-static=yes --enable-shared --disable-debug --disable-plugin-auth-pam --disable-dependency-tracking
    make
    make install
}