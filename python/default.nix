{ stdenv,
  pkgs,
  python,
  fetchgit
}:

with pkgs;
with python.pkgs;

let
  libmxnet = callPackage ../libmxnet {};
in

buildPythonPackage rec {
  name = "mxnet-${version}";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/apache/incubator-mxnet";
    rev = "2a4505a33586cd272d650d7df4e8b338c948e0c9";
    sha256 = "18d5jxqz2n2sdg2dscdjbw0i5la09a2zlmqykpdq9y2y0m4iqbli";
  };

  nativeBuildInputs = [
    gcc5
    pkgconfig
  ];

  propagatedBuildInputs = [
    libmxnet
    numpy
    requests
    graphviz
  ];

  preBuild = ''
    mkdir ./lib
    cp -r ${libmxnet}/lib/* ./lib
    cd python
  '';

  # In python3, test was failed...
  doCheck = isPy27;

  postInstall = ''
    cp -r ${libmxnet}/lib/* $out/lib/${python.libPrefix}/site-packages/mxnet/
  '';
}
