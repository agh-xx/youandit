define main (self, command, retval)
{
  variable
    fmt,
    coms,
    args,
    windows;
 
  if ("bgkillpid" == command)
    {
    (args, coms) = proc->get_bg_list ();
    ifnot (length (args))
      {
      self.cur.argv = NULL;
      srv->send_msg ("There is no bg pid to kill", 1);
      throw Return, " ", -1;
      }
 
    args = array_map (String_Type, &sprintf, "%4d void %s", args, coms);

    @retval = self.argcompletion (;file = NULL,
      args = args,
      base = self.cur.argv[0],
      header = "get pid",
      accept_ws);

    throw Return, " ", 0;
    }

  if (any (["windownewdontfocus", "windownew"] == command))
    {
    if (3 == length (self.cur.argv))
      throw Return, " ", 0;
 
    args = listdir (STDTYPESDIR);
    args = args[where (array_map (Integer_Type, &isdirectory,
          array_map (String_Type, &sprintf, "%s/%s", STDTYPESDIR, args)))];

    fmt = sprintf ("%%-%ds void Window Type", max (strlen (args)));
    args = array_map (String_Type, &sprintf, fmt, args);

    @retval = self.argcompletion (;file = NULL,
      args = args,
      arg = self.cur.index ? strlen (self.cur.argv[1]) ? self.cur.argv[1] : "" : "",
      base = self.cur.argv[0],
      header = sprintf ("windownew%s", "windownew" == command ? "" : "dontfocus"),
      accept_ws);

    throw Return, " ", 0;
    }

  if (any (["windowgoto", "windowdelete"] == command))
    {
    windows = list_to_array (root.windnames);
    windows = windows[wherenot ((CW.name == windows) or (mytypename == windows))];
 
    if ("windowdelete" == command)
      windows = windows[wherenot (maintypename == windows)];

    ifnot (length (windows))
      {
      srv->send_msg ("There is only one window", 1);
      self.cur.argv = [""];
      self.cur.col = 1;
      self.parse_args ();
      self.my_prompt ();
      throw Return, " ", 1;
      }
 
    fmt = sprintf ("%%-%ds void Window Name", max (strlen (windows)));
    windows = array_map (String_Type, &sprintf, fmt, windows);

    @retval = self.argcompletion (;file = NULL,
      args = windows,
      arg = self.cur.index ? strlen (self.cur.argv[1]) ? self.cur.argv[1] : "" : "",
      base = self.cur.argv[0],
      header = sprintf ("window%s:", "windowgoto" == command ? "goto" : "delete"),
      accept_ws);

    throw Return, " ", 0;
    }

  throw Return, " ", 0;
}
