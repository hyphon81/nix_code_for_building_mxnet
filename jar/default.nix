{ stdenv, pkgs, fetchgit }:

with pkgs;

let
  nccl = callPackage ../nccl {};
in

stdenv.mkDerivation rec {
  name = "mxnet-jar-${version}";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/apache/incubator-mxnet";
    rev = "2a4505a33586cd272d650d7df4e8b338c948e0c9";
    sha256 = "18d5jxqz2n2sdg2dscdjbw0i5la09a2zlmqykpdq9y2y0m4iqbli";
  };

  nativeBuildInputs = [
    pkgconfig
    gcc5
    maven
  ];

  propagatedBuildInputs = [
    jdk9
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

  configurePhase = ''
    mkdir -p $out/var

    cat <<SETTING > $out/var/settings.xml
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
     https://maven.apache.org/xsd/settings-1.0.0.xsd">
      <localRepository>./var/m2</localRepository>
    </settings>
    SETTING

    substituteInPlace Makefile \
      --replace "mvn package -P\$(SCALA_PKG_PROFILE) -Dcxx=\"\$(CXX)\" \\" "mvn package -gs $out/var/settings.xml -P\$(SCALA_PKG_PROFILE) -Dcxx=\"\$(CXX)\" \\"
  '';

  buildPhase = ''
    make -j $(nproc) USE_OPENCV=1 USE_BLAS=openblas USE_CUDA=1 USE_CUDA_PATH=${cudatoolkit8} USE_CUDNN=1 USE_NCCL=1
    make scalapkg USE_OPENCV=1 USE_BLAS=openblas USE_CUDA=1 USE_CUDA_PATH=${cudatoolkit8} USE_CUDNN=1 USE_NCCL=1
  '';

  installPhase = ''
    mkdir -p $out/jar
    cp -r ./scala-package/assembly/linux-x86_64-gpu/target/*.jar $out/jar

    rm -rf $out/var
  '';
}
