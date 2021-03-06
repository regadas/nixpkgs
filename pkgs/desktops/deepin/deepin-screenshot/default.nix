{ stdenv, mkDerivation, fetchFromGitHub, fetchpatch, cmake, pkgconfig, xdg_utils, qttools, qtx11extras,
  dtkcore, dtkwidget, dtkwm, deepin-turbo, deepin-shortcut-viewer,
  deepin }:

mkDerivation rec {
  pname = "deepin-screenshot";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "16wy1ywp4lm7fg488laqxgxpir745rbpj9z410r6x7krpgjds189";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    deepin.setupHook
  ];

  buildInputs = [
    deepin-shortcut-viewer
    deepin-turbo
    dtkcore
    dtkwidget
    dtkwm
    qtx11extras
  ];

  patches = [
    (fetchpatch {
      url = https://github.com/linuxdeepin/deepin-screenshot/pull/52/commits/e14508b223fd9965854ed41c944cea2ea19e6e0c.patch;
      sha256 = "18zvz98z3hr8pcdyb706za6h2nwx23zsjb1hgyp21ycinhzr9j9h";
    })
  ];

  postPatch = ''
    searchHardCodedPaths
    patchShebangs generate_translations.sh
    fixPath ${deepin-turbo} /usr/bin/deepin-turbo-invoker src/dbusservice/com.deepin.Screenshot.service
    fixPath $out /usr/bin/deepin-screenshot src/dbusservice/com.deepin.Screenshot.service
    substituteInPlace src/mainwindow.cpp --replace '"xdg-open,%1"' '"${xdg_utils}/bin/xdg-open,%1"'
  '';

  postFixup = ''
    searchHardCodedPaths $out
  '';

  passthru.updateScript = deepin.updateScript { inherit ;name = "${pname}-${version}"; };

  meta = with stdenv.lib; {
    description = "Easy-to-use screenshot tool for Deepin Desktop Environment";
    homepage = https://github.com/linuxdeepin/deepin-screenshot;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo flokli ];
  };
}
