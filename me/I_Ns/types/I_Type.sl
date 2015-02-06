private variable mytypedir = sprintf ("%s/%s", path_dirname (__FILE__),
    path_basename_sans_extname  (__FILE__));

private define ag (self)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
}

private define executeargv (self, argv)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), argv;;__qualifiers ());
}

private define startroutine (self, keys)
{
  return self.exec (sprintf ("%s/%s", mytypedir, _function_name ()),
    keys;;__qualifiers ());
}

define main (self, name)
{
  variable
    rootcommands = ["bytecompile", "debugconsole", "sync_this_tree", "sync_another_tree",
      "backuptree", "checknet", "trytofixbrokenwindow"],
    sorted = array_sort (rootcommands),
    rootcommandshelp = ["bytecompile application", "the debug console",
      "sync current distribution from a previus backup", "sync another tree from current",
      "backup distribution", "checknet", "try to fix broken window in case of a problem"];

  root.windows[name] = struct
    {
    @root.windows[name],
    ag = &ag
    };
 
  variable me = root.windows[name];

  me.maxframes = 2;
  me.readline = struct
    {@self.addreadline (),
    help = rootcommandshelp[sorted],
    };

  me.readline.executeargv = &executeargv;
  me.readline.startroutine = &startroutine;
  me.readline.commands =
    {
    rootcommands[sorted]
    };

  me.history = self.addhistory (;file = sprintf ("%s/data/.history.txt", mytypedir));
  me.history.read ();
 
  me.addframe (;;
    struct {@__qualifiers (), framename = me.msgbuf});

  throw Return, " ", 0;
}
