private define write (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define read (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define add (self, argv)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    argv;;__qualifiers ());
}

define main (self)
{
  throw Return, " ", struct
    {
    exec = self.exec,
    read = &read,
    write = &write,
    add = &add,
    list = String_Type[0],
    len = 100,
    file = qualifier ("file", sprintf ("%s/.history.txt", ROOTDIR)),
    };
}
