{ stdenv, pkgs, fetchgit }:

with pkgs;

let
  nccl = callPackage ../nccl {};
in

stdenv.mkDerivation rec {
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
    cudatoolkit8
    cudnn60_cudatoolkit80
    nccl
    linuxPackages.nvidia_x11
    openblas
    (pkgs.opencv3.override {
      enableGtk2 = true;
      enableCuda = true;
    })
  ];

  buildPhase = ''
    make -j $(nproc) USE_OPENCV=1 USE_BLAS=openblas USE_CUDA=1 USE_CUDA_PATH=${cudatoolkit8} USE_CUDNN=1 USE_NCCL=1
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp -r ./lib/* $out/lib
  '';
}
