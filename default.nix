{ mkDerivation, aeson, base, stdenv, wreq }:
mkDerivation {
  pname = "k6tracker";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ aeson base wreq ];
  license = stdenv.lib.licenses.bsd3;
}
