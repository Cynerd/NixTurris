{ buildPythonApplication, lib, fetchgit
, python3
}:

buildPythonApplication rec {
  pname = "mox-otp";
  version = "0.3";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/mox-otp";
    description = "Command line tool to query MOX CPU read-only OTP device";
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/mox-otp.git";
    rev = "v" + version;
    sha256 = "12k9mgv1kmv9cawgx0ccq4m4liqizszvvsl457jkkirb7rbzhw5y";
  };
}
