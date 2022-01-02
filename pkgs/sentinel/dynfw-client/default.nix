{ buildPythonApplication, lib, fetchgit
, ipset
}:

buildPythonApplication rec {
  pname = "sentinel-dynfw-client";
  version = "1.4.0";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/sentinel/dynfw-client";
    description = "Dynamic firewall client";
    platforms = platforms.linux;
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/sentinel/dynfw-client.git";
    rev = "v" + version;
    sha256 = "1g0wbhsjzifvdfvig6922cl3yfj1f96yvg11s4vgiaxca9yspcmp";
  };

  buildInputs = [ipset];
  preConfigure = ''
    ls
    find -type f | xargs sed -i 's#/usr/sbin/ipset#${ipset}#g' 
    '';
}
