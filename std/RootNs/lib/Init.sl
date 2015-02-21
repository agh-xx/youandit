private define betaprintout (self, ar, col, len)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()), ar, col, len
    ;;__qualifiers ());
}

private define printout (self, ar, col, len)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()), ar, col, len
    ;;__qualifiers ());
}

private define printtostdout (self, msg)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()), msg
    ;;__qualifiers ());
}

private define ask (self, quest, ar)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name),
    quest, ar;;__qualifiers());
}

private define validate_passwd (self, passwd)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    passwd;;__qualifiers ());
}

private define getpasswd (self)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define rand_int_ar_uniq (self, imin, imax, num)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    imin, imax, num;;__qualifiers ());
}

private define get_engl_chr (self)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers());
}

define main (self)
{
  throw Return, " ", struct
    {
    exec = self.exec,
    betaprintout = &betaprintout,
    printout = &printout,
    printtostdout = &printtostdout,
    ask = &ask,
    validate_passwd = &validate_passwd,
    getpasswd = &getpasswd,
    rand_int_ar_uniq = &rand_int_ar_uniq,
    };
}
