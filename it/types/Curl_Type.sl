private variable mytypedir = sprintf ("%s/%s", path_dirname (__FILE__),
    path_basename_sans_extname  (__FILE__));

private variable Info_Type = struct
{
  exit_status = 0,
  saved_file,
  bytes_received,
  total_time,
  err,
};

private define at_exit (self)
{
  variable fp = fopen (self.lockfile, "w");
  () = fclose (fp);
}

private define executeargv (self, argv)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), argv;;__qualifiers ());
}

define main (self, name)
{
  variable
    i,
    histfile = sprintf ("%s/data/.history.txt", mytypedir),
    curlcommands = ["addurl", "filelist"],
    sorted = array_sort (curlcommands),
    curlcommandshelp = [
      "add url[s]",
      "add filelist"][sorted];

  root.windows[name] = struct
    {
    @root.windows[name],
    downloaddir = "/home/share/Downloads/",
    urls = Assoc_Type[Struct_Type],
    lockfile = sprintf ("%s/%s/lock", TMPDIR, name),
    rows,
    at_exit = &at_exit,
    };

  variable cw = root.windows[name];

  cw.readline = struct
    {
    @self.addreadline (),
    help = curlcommandshelp,
    disable_shell,
    disable_addframe,
    disable_pager,
    mode = "curl"
    };

  cw.readline.executeargv = {&executeargv};
  cw.readline.commands =
    {
    curlcommands[sorted],
    CORECOMS
    };

  cw.history = self.addhistory (;file=histfile);
  cw.history.read ();

  cw.cur.mode = "";

  cw.addframe (;;__qualifiers ());

  throw Return, " ", 0;
}
