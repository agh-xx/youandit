define main ()
{
  variable dir = String_Type[1];
  dir[*] = path_dirname (__FILE__);

  throw Return, " ", struct
    {
    name = ["git"],
    type = ["Git_Type"],
    help = ["A git application"],
    dir = dir
    };
}
