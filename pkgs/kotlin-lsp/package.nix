{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  system = stdenv.hostPlatform.system;

  archiveFile =
    version:
    {
      "x86_64-linux" = "kotlin-server-${version}.tar.gz";
      "aarch64-linux" = "kotlin-server-${version}-aarch64.tar.gz";
    }
    .${system} or (throw "kotlin-lsp does not support ${system}");

  archiveHash =
    {
      "x86_64-linux" = "sha256-RpcREMm4ozYM4/31Q3Rn9MRH2tN61z2/gdZK9neeQQU=";
      "aarch64-linux" = "sha256-YlhwrgkcbQ3uJVFNVFxwim6lDXy7UVSq8aqRI8z/M4s=";
    }
    .${system} or (throw "kotlin-lsp does not support ${system}");
in

stdenv.mkDerivation (finalAttrs: {
  pname = "kotlin-lsp";
  version = "262.4739.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/kotlin-lsp/${finalAttrs.version}/${archiveFile finalAttrs.version}";
    hash = archiveHash;
  };

  dontConfigure = true;
  dontBuild = true;

  autoPatchelfIgnoreMissingDeps = [
    "libasound.so.2"
    "libc.musl-x86_64.so.1"
    "libfreetype.so.6"
    "libwayland-client.so.0"
    "libwayland-cursor.so.0"
    "libX11.so.6"
    "libXext.so.6"
    "libXi.so.6"
    "libXrender.so.1"
    "libXtst.so.6"
    "libxkbcommon.so.0"
  ];

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/kotlin-lsp
    cp -r bin jbr lib modules plugins product-info.json build.txt $out/share/kotlin-lsp/

    mkdir -p $out/bin
    ln -s ../share/kotlin-lsp/bin/intellij-server $out/bin/kotlin-lsp

    runHook postInstall
  '';

  meta = {
    description = "Official Kotlin LSP, by JetBrains";
    homepage = "https://github.com/Kotlin/kotlin-lsp";
    license = with lib.licenses; [ asl20 unfreeRedistributable ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "kotlin-lsp";
  };
})
