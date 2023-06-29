with import (builtins.fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/60a783e00517fce85c42c8c53fe0ed05ded5b2a4.tar.gz"; }) { };
stdenv.mkDerivation rec {
  name = "angr-env";

  nativeBuildInputs = [
    cmake
    pkgconfig
    git
    pkgs.pkgsCross.aarch64-multiplatform.buildPackages.gdb
  ];

  buildInputs = [
    bashInteractive
    pypy3 # for PyPy install
    nasm
    libxml2
    libxslt
    libffi
    readline
    libtool
    glib
    debootstrap
    pixman
    qt5.qtdeclarative
    openssl
    # jdk8
    ((z3.override { python = pypy3; }).overrideAttrs
      (finalAttrs: previousAttrs: {
        postInstall = " 
                              mkdir -p $dev $lib
                              mv $out/lib $lib/lib
                              mv $out/include $dev/include
                              mkdir -p $python/lib
                              mv $lib/lib/pypy* $python/lib/
                              ln -sf $lib/lib/libz3${stdenv.hostPlatform.extensions.sharedLibrary} $python/${pypy3.sitePackages}/z3/lib/libz3${stdenv.hostPlatform.extensions.sharedLibrary}
          		    ";
      }))
    # (z3.override { python = pypy3; })
    pypy3Packages.setuptools
    gdb

    # needed for pure environments
    which
  ];

  shellHook = ''
    alias gdb-multiarch="aarch64-linux-unknown-gnu-gdb"
    export LD_LIBRARY_PATH="${gcc-unwrapped.lib}/lib:${pkgs.z3.lib}/lib:$LD_LIBRARY_PATH"
  '';
}
