private variable mytypedir = sprintf ("%s/%s", path_dirname (__FILE__),
    path_basename_sans_extname  (__FILE__));

private define mycompletion (self, retval, command)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), retval, command
      ;;__qualifiers ());
}

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
    frame,
    i,
    repos,
    fp,
    histfile = sprintf ("%s/.history.txt", root.windows[name].datadir),
    gitcommands = [
      "bisectinit", "bisectgood", "bisectbad", "bisectreset",
      "applypatch", "pull", "repoadd", "!",  "add", "closeshell",
      "status", "diff", "fulllog", "log", "logpatch", "commitall",
      "commit", "lastlog", "branchchange", "branchnew", "branchdelete",
      "merge", "reposet", "initrepo", "rmrepofromdb",
      "branches", "diffrevision", "pushupstream"],
    sorted = array_sort (gitcommands),
    gitcommandshelp = [
      "Start Bisecting arg: (a full revision hash || ~nr to mean HEAD - nr commits)",
      "Bisect: This is a good revision",
      "Bisect: This is a bad revision",
      "Bisect: End bisecting",
      "Apply a patch with with -p1 (pathname component level one) arg: (patch)",
      "fetch and merge",
      "add an existing repository to the db  arg: (a directory name with a git tree)",
      "run a shell command",
      "add a file|directory to the index,    arg: (a filename)",
      "close the shell frame",
      "show the status of the repository (git status)",
      "show changes to the repository",
      "show full log (git log)",
      "show log of the last two years",
      "show full log and the unified patch (git log -p)",
      "commit all changes (git --all)",
      "commit only those files that added to the index",
      "show last log and the unified patch (git log -1 HEAD -p)",
      "change to another branch, if any,     arg: (an existing 'branch')",
      "create a new branch,                  arg: (a 'branch' name)",
      "delete a branch                       arg: (an existing 'branch')",
      "merge changes from \"branch\" into the current one arg: (a 'branch' name)",
      "set the current repo arg: (a repo from db)",
      "initialize repo and add to the db arg: (a directory)",
      "remove repo from db arg: (repo)",
      "show branches (git branch)",
      "diff of a rev arg: (a full|abbr hash || ~nr to mean - nr revs to cur branch)",
      "push changes to upstream remote address"
      ]
      [sorted],
    git = which ("git");

  if (NULL == git)
    {
    srv->send_msg_and_refresh ("git is not installed", -1);
    throw Return, " ", NULL;
    }
 
  if (-1 == access (sprintf ("%s/repos.txt", root.windows[name].datadir), F_OK))
    {
    fp = fopen (sprintf ("%s/repos.txt", root.windows[name].datadir), "w");
    if (NULL == fp)
      {
      srv->send_msg_and_refresh ("Inited Git Failed: cannot create repo file", -1);
      throw Return, " ", NULL;
      }

    if (-1 == fclose (fp))
      {
      srv->send_msg_and_refresh (sprintf ("Inited Git Failed: %s",
            errno_string (errno)), -1);
      throw Return, " ", NULL;
      }

    repos = NULL;
    }
  else
    repos = readfile (sprintf ("%s/repos.txt", root.windows[name].datadir));

  root.windows[name] = struct
    {
    @root.windows[name],
    setinfoline = &setinfoline,
    addframe = &addframe,
    git = git,
    reposfile = sprintf ("%s/repos.txt", root.windows[name].datadir),
    repos = repos,
    cur = struct
      {
      @root.windows[name].cur,
      command,
      repo,
      branch,
      nrbrances,
      branches
      },
    };

  variable me = root.windows[name];

  me.maxframes = 2;

  me.readline = struct
    {
    @self.addreadline (),
    mycompletion = &mycompletion,
    help = gitcommandshelp,
    mode = "git"
    };

  me.readline.readline = &readline;
  me.readline.executeargv = {&executeargv, me.readline.executeargv};
  me.readline.commands =
    {
    gitcommands[sorted],
    COMMANDS
    };

  me.history = self.addhistory (;file=histfile);
  me.history.read ();

  me.cur.mode = "";
  me.addframe (;;__qualifiers ());

  throw Return, " ", 0;
}
