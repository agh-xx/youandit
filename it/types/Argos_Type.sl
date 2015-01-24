private variable
  mytype = path_basename_sans_extname  (__FILE__),
  mytypedir = sprintf ("%s/%s", path_dirname (__FILE__), mytype);

private define setinfoline (self, buf, frame, len)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), buf, frame, len
      ;;__qualifiers ());
}

private define addframe (self)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
}

private define executeargv (self, argv)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), argv;;__qualifiers ());
}

private define readline (self)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
}

define main (self, name)
{
  variable
    histfile = sprintf ("%s/data/.history.txt", mytypedir),
    typecommands = [
      "closeshell",
      "toogleverbose",
      "test"],
    sorted = array_sort (typecommands),
    typecommandshelp = [
      "close the shell frame",
      "set/unset (toogle) verbose",
      "test"]
       [sorted];

  root.windows[name] = struct
    {
    @root.windows[name],
    setinfoline = &setinfoline,
    addframe = &addframe,
    specdir = sprintf ("%s/specs", mytypedir),
    libdir =  sprintf ("%s/lib", mytypedir),
    verbose = 1,
    cur = struct
      {
      @root.windows[name].cur,
      command,
      },
    };

  variable me = root.windows[name];
 
  me.frame_size = 7;

  me.readline = struct
    {
    @self.addreadline (),
    help = typecommandshelp,
    mode = mytype
    };

  me.readline.readline = &readline;
  me.readline.executeargv = {&executeargv, me.readline.executeargv};
  me.readline.commands =
    {
    typecommands[sorted],
    COMMANDS
    };

  me.history = self.addhistory (;file=histfile);
  me.history.read ();

  me.cur.mode = "";

  loop (2)
    me.addframe (;;__qualifiers ());

  throw Return, " ", 0;
}
