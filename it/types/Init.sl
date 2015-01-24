define main (s)
{
  variable sa = struct
    {
    name = [
      "argos",
      "track",
      "ps",
      "curl"],
    type = [
      "Argos_Type",
      "Track_Type",
      "Ps_Type",
      "Curl_Type"],
    help = [
      "A package manager (NOT FUNCTIONAL)",
      "A development tracker (NOT FUNCTIONAL)",
      "process table (NOT FUNCTIONAL",
      "A download manager (NEEDS TESTING)"],
    };

  variable dir = String_Type[length (sa.name)];
  dir[*] = path_dirname (__FILE__);

  throw Return, " ", struct
    {
    name = [s.name, sa.name],
    type = [s.type, sa.type],
    help = [s.help, sa.help],
    dir = [s.dir, dir]
    };
}
