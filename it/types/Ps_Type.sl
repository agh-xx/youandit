private variable mytypedir = sprintf ("%s/%s", path_dirname (__FILE__),
  path_basename_sans_extname  (__FILE__));

private define executeargv (self, argv)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), argv;;__qualifiers ());
}

private define readline (self)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
}

variable default = &sigint_handler;

%define ps_sigint_handler (sig)
%{
%  signal (sig, default);
%  throw GotoPrompt;
%}

%signal (SIGINT, &ps_sigint_handler);

define main (self, name)
{
  variable
    i,
    ps = which ("ps"),
    histfile = sprintf ("%s/data/.history.txt", mytypedir),
    pscommands = [
      "refresh",
    ],
    sorted = array_sort (pscommands),
    pscommandshelp = [
      "refresh"][sorted];

  root.windows[name] = struct
    {
    @root.windows[name],
    outputfile = sprintf ("%s/ps/out.txt", TMPDIR),
    argv,
    pid,
    };

  variable me = root.windows[name];

  me.readline = struct
    {
    @self.addreadline (),
    help = pscommandshelp,
    mode = "ps"
    };

  me.readline.readline = &readline;
  me.readline.executeargv = {&executeargv, me.readline.executeargv};
  me.readline.commands =
    {
    pscommands[sorted],
    CORECOMS
    };

  me.history = self.addhistory (;file=histfile);
  me.history.read ();

  me.argv = ["ps_proc", "--nocl",
      sprintf ("--out_fn=%s", me.outputfile),
      sprintf ("--mainfname=%s", me.outputfile),
      sprintf ("--execdir=%s", mytypedir),
      sprintf ("--msgfname=%s", me.msgbuf)];

  me.cur.mode = "ps";

  me.addframe (;;struct {@__qualifiers (), framename = me.outputfile});

%  me.pid = proc->call (me.argv);
%  me.drawframe (0);
%  srv->refresh ();

  throw Return, " ", 0;
}
