{
  lib,
  stdenv,
  fetchFromGitHub,
  llvmPackages,
  elfutils,
  bcc,
  libbpf,
  libbfd,
  libopcodes,
  glibc,
  cereal,
  asciidoctor,
  cmake,
  pkg-config,
  flex,
  bison,
  util-linux,
  nixosTests,
}:

stdenv.mkDerivation rec {
  pname = "bpftrace";
  version = "0.23.5";

  src = fetchFromGitHub {
    owner = "bpftrace";
    repo = "bpftrace";
    rev = "v${version}";
    hash = "sha256-Shtf4PSXxUV0Bd7ORYyP06lbWf3LE6BQi7WfTIGDOfk=";
  };

  buildInputs = with llvmPackages; [
    llvm
    libclang
    elfutils
    bcc
    libbpf
    libbfd
    libopcodes
    cereal
    asciidoctor
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    flex
    bison
    llvmPackages.llvm.dev
    util-linux
  ];

  cmakeFlags = [
    "-DLIBBCC_INCLUDE_DIRS=${bcc}/include"
    "-DINSTALL_TOOL_DOCS=OFF"
    "-DSYSTEM_INCLUDE_PATHS=${glibc.dev}/include"
  ];

  # Pull BPF scripts into $PATH (next to their bcc program equivalents), but do
  # not move them to keep `${pkgs.bpftrace}/share/bpftrace/tools/...` working.
  postInstall = ''
    ln -sr $out/share/bpftrace/tools/*.bt $out/bin/
    # do not use /usr/bin/env for shipped tools
    # If someone can get patchShebangs to work here please fix.
    sed -i -e "1s:#!/usr/bin/env bpftrace:#!$out/bin/bpftrace:" $out/share/bpftrace/tools/*.bt
  '';

  outputs = [
    "out"
    "man"
  ];

  passthru.tests = {
    bpf = nixosTests.bpf;
  };

  meta = {
    description = "High-level tracing language for Linux eBPF";
    homepage = "https://github.com/bpftrace/bpftrace";
    changelog = "https://github.com/bpftrace/bpftrace/releases/tag/v${version}";
    mainProgram = "bpftrace";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      rvl
      thoughtpolice
      martinetd
      mfrw
      illustris
    ];
    platforms = lib.platforms.linux;
  };
}
