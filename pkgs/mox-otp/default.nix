{ buildPythonApplication, lib, fetchgit
, python3
}:

buildPythonApplication rec {
  pname = "mox-otp";
  version = "0.3.1";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/mox-otp";
    description = "Command line tool to query MOX CPU read-only OTP device";
    platforms = platforms.linux;
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/mox-otp.git";
    rev = "v" + version;
    sha256 = "0sknaqv7aga99x99mh5gvinx3fc4rl9pyaq8j71nmhblf50cfwk4";
  };
}
