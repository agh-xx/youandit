private variable mytypedir = sprintf ("%s/%s", path_dirname (__FILE__),
  path_basename_sans_extname  (__FILE__));

private define jumptoitem (self, action)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), action;;__qualifiers ());
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
    listcommands = ["closeshell", "n", "p"],
    sorted = array_sort (listcommands),
    listcommandshelp = [
      "close the shell window",
      "jump to the next item in the report list",
      "jump to the previous item in the report list"][sorted];

  root.windows[name] = struct
    {
    @root.windows[name],
    reportlist = qualifier ("reportlist"),
    addframe = &addframe,
    jumptoitem = &jumptoitem,
    len,
    cur = struct
      {
      @root.windows[name].cur,
      linenr = 1
      }
    };

  variable me = root.windows[name];
 
  me.minframes = 2;
  me.len = length (me.reportlist);

  me.readline = struct
    {
    @self.addreadline (),
    help = listcommandshelp,
    mode = "listreport"
    };

  me.readline.readline = &readline;
  me.readline.executeargv = {&executeargv, me.readline.executeargv};
  me.readline.commands =
    {
    listcommands[sorted],
    COMMANDS
    };

  me.history = self.addhistory (;file = sprintf ("%s/.history.txt", me.datadir));
  me.history.read ();

  me.cur.mode = "";

  loop (2)
    me.addframe (;;__qualifiers ());

  throw Return, " ", 0;
}
