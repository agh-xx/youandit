private variable mytypedir = sprintf ("%s/%s", path_dirname (__FILE__),
    path_basename_sans_extname  (__FILE__));

private define go_start_of_file (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), row, col, buf, frame,
      frame_size, len;;__qualifiers ());
}

private define set (self, buf, frame, len)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), buf, frame, len
      ;;__qualifiers ());
}

define main (self, name)
{
  variable
    frame,
    frames = qualifier ("frames", 1),
    me = root.windows[name];

  me.readline = self.addreadline ();
  me.readline.commands = {COMMANDS};

  me.history = self.addhistory (;file = sprintf ("%s/.shellhistory.txt", DATADIR));
  me.history.read ();

  me.pfuncs["g"] = &go_start_of_file;

  me.set = &set;

  loop (frames)
    me.addframe (;;__qualifiers ());

  throw Return, " ", 0;
}
