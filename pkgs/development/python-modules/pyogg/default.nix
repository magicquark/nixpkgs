{
  stdenv,
  lib,
  fetchPypi,
  buildPythonPackage,
  libvorbis,
  flac,
  libogg,
  libopus,
  opusfile,
  replaceVars,
}:

buildPythonPackage rec {
  pname = "pyogg";
  version = "0.6.14a1";
  format = "setuptools";

  src = fetchPypi {
    pname = "PyOgg";
    inherit version;
    hash = "sha256-gpSzSqWckCAMRjDCzEpbhEByCRQejl0GnXpb41jpQmI=";
  };

  buildInputs = [
    libvorbis
    flac
    libogg
    libopus
  ];

  propagatedBuildInputs = [
    libvorbis
    flac
    libogg
    libopus
    opusfile
  ];

  # There are no tests in this package.
  doCheck = false;

  # patch has dos style eol
  patchFlags = [
    "-p1"
    "--binary"
  ];
  patches = [
    (replaceVars ./pyogg-paths.patch {
      flacLibPath = "${flac.out}/lib/libFLAC${stdenv.hostPlatform.extensions.sharedLibrary}";
      oggLibPath = "${libogg}/lib/libogg${stdenv.hostPlatform.extensions.sharedLibrary}";
      vorbisLibPath = "${libvorbis}/lib/libvorbis${stdenv.hostPlatform.extensions.sharedLibrary}";
      vorbisFileLibPath = "${libvorbis}/lib/libvorbisfile${stdenv.hostPlatform.extensions.sharedLibrary}";
      vorbisEncLibPath = "${libvorbis}/lib/libvorbisenc${stdenv.hostPlatform.extensions.sharedLibrary}";
      opusLibPath = "${libopus}/lib/libopus${stdenv.hostPlatform.extensions.sharedLibrary}";
      opusFileLibPath = "${opusfile}/lib/libopusfile${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  meta = with lib; {
    description = "Xiph.org's Ogg Vorbis, Opus and FLAC for Python";
    homepage = "https://github.com/Zuzu-Typ/PyOgg";
    license = licenses.publicDomain;
    maintainers = with maintainers; [ pmiddend ];
  };
}
