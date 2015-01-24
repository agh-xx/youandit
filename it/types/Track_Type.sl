private variable mytypedir = sprintf ("%s/%s", path_dirname (__FILE__),
    path_basename_sans_extname  (__FILE__));

%private define mycompletion (self, retval, command)
%{
%  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), retval, command
%      ;;__qualifiers ());
%}
%
%private define setinfoline (self, buf, frame, len)
%{
%  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), buf, frame, len
%      ;;__qualifiers ());
%}
%
%private define addframe (self)
%{
%  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
%}

private define executeargv (self, argv)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), argv;;__qualifiers ());
}

%private define readline (self)
%{
%  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
%}

define main (self, name)
{
  variable
    i,
    fp,
    frame,
    repos,
    trackers,
    histfile = sprintf ("%s/data/.history.txt", mytypedir),
    trackcommands = ["trackadd", "!", "closeshell",
      "trackset", "inittracker", "rmrepofromdb"],
    sorted = array_sort (trackcommands),
    trackcommandshelp = [
      "add a tracker to the db arg: (name)",
      "run a shell command",
      "close the shell frame",
      "set the current tracker arg: (a tracker name from db)",
      "initialize tracker and add to the db arg: (a name)",
      "remove tracker from db arg: (tracker)"][sorted];

  if (-1 == access (sprintf ("%s/data/trackers.txt", mytypedir), F_OK))
    {
    fp = fopen (sprintf ("%s/data/trackers.txt", mytypedir), "w");
    if (NULL == fp)
      {
      srv->send_msg_and_refresh ("Inited Track Failed: cannot create db file", -1);
      throw Return, " ", NULL;
      }

    if (-1 == fclose (fp))
      {
      srv->send_msg_and_refresh (sprintf ("Inited Track Failed: %s",
            errno_string (errno)), -1);
      throw Return, " ", NULL;
      }

    trackers = NULL;
    }
  else
    trackers = readfile (sprintf ("%s/data/tracker.txt", mytypedir));

  root.windows[name] = struct
    {
    @root.windows[name],
    %setinfoline = &setinfoline,
    %addframe = &addframe,
    %track = track,
    trackersfile = sprintf ("%s/data/trackers.txt", mytypedir),
    datadir = sprintf ("%s/data", mytypedir),
    trackers = trackers,
    cur = struct
      {
      @root.windows[name].cur,
      command,
      tracker,
      },
    };

  variable me = root.windows[name];

  me.maxframes = 2;

  me.readline = struct
    {
    @self.addreadline (),
    %mycompletion = &mycompletion,
    help = trackcommandshelp,
    mode = "track"
    };

  %me.readline.readline = &readline;
  me.readline.executeargv = {&executeargv, me.readline.executeargv};
  me.readline.commands =
    {
    trackcommands[sorted],
    COMMANDS
    };

  me.history = self.addhistory (;file=histfile);
  me.history.read ();

  me.cur.mode = "";
  me.addframe (;;__qualifiers ());

  throw Return, " ", 0;
}
