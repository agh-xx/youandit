define _uname (args)
{
  variable
    msg = "",
    i,
    s = uname ();

  _for i (0,strlen (args) - 1)
    {
    switch (args[i])

      {
      case 's': msg += " " + s.sysname;
      }
 
      {
      case 'n': msg += " " + s.nodename;
      }
 
      {
      case 'r': msg += " " + s.release;
      }

      {
      case 'v' : msg += " " + s.version;
      }

      {
      case 'm' : msg += " " + s.machine;
      }
 
      {
      case 'p' :
        variable
         ar = readfile ("/proc/cpuinfo");

       msg += " " + strtok (
         ar[wherefirst (array_map
           (Integer_Type, &string_match,  ar, "^model name.*: ", 1))], ":")[1];
      }
 
      {
      (@print_err) (sprintf ("%s: No such option", args[i]));
      }
    }

  return msg[[1:]];
}
