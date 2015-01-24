define main (s)
{
  variable sa = struct
    {
    name = ["mplayer"],
    type = ["Media_Type"],
    help = ["A media player based on mplayer"],
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
