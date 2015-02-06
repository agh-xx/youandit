() = evalfile ("strtoint");

variable
  git = which ("git"),
  out_flags = O_WRONLY|O_CREAT,
  err_flags = out_flags,
  msg,
  url,
  newfile,
  file,
  repo,
  branch,
  patch,
  revision,
  repo,
  pid,
  status,
  argv,
  out_fd = dup_fd (fileno (stdout)),
  err_fd = dup_fd (fileno (stderr)),
  stdoutw,
  stdoutr,
  stderrw,
  stderrr;

define chdir_to_repo (repo, file)
{
  if (-1 == chdir (repo))
    {
    writefile (sprintf ("%s, cannot change dir, ERRNO: %s", repo, errno_string (errno)),
      file; mode = "a+");
    return -1;
    }

  return 0;
}

define open_files (out_file, err_file, out_mode, err_mode)
{
  out_flags |= out_mode == "w" ? O_TRUNC : O_APPEND;
  err_flags |= err_mode == "w" ? O_TRUNC : O_APPEND;

  stdoutw = open (out_file, out_flags, S_IRWXU);
  stderrw = open (err_file, err_flags, S_IRWXU);
}

define git_init ()
{
  variable
    file = qualifier ("file"),
    repo = qualifier ("repo");

  argv = [git, "init"];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_branch ()
{
  variable
    curbranch,
    ar;

  argv = [git, "branch"];
 
  (stdoutr, stdoutw) = pipe ();
  (stderrr, stderrw) = pipe ();

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
 
  () = array_map (Integer_Type, &_close, [2, 1, _fileno (stderrw), _fileno (stdoutw)]);

  if (status.exit_status)
    {
    ar = strchop (read_fd (stderrr), '\n', 0);
    writefile (ar, file;mode="a+");
    return 1;
    }
 
  ar = read_fd (stdoutr);
  if (NULL == ar)
    {
    writefile ([""],  file);
    return 1;
    }

  ar = strtrim_end (strchop (ar, '\n', 0));
  ar = ar[where (strlen (ar))];

  curbranch = substr (ar[wherenot (array_map (
    Integer_Type, &strncmp, ar, "* ", 2))][0], 3, -1);

  ar = [
    sprintf ("Current tree has %d branches", length (ar)),
    repeat ("_", atoi (getenv ("COLUMNS"))),
    strtrim_beg (strtrim_beg (ar, "*")),
    repeat ("_", atoi (getenv ("COLUMNS"))),
    sprintf ("Current Branch: %s", curbranch, 2)
    ];
 
  writefile (ar, file);

  return 0;
}

define git_merge ()
{
  argv = [git, "merge", branch];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_branchdelete ()
{
  argv = [git, "branch", "-d", branch];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_branchchange ()
{
  argv = [git, "checkout", branch];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_branchnew ()
{
  argv = [git, "branch", branch];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_add ()
{
  argv = [git, "add", "-v", newfile];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_commitall ()
{
  argv = [git,  "commit", "-a", "-v", sprintf ("--message=%s", msg)];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_commit ()
{
  argv = [git,  "commit", "-v", sprintf ("--message=%s", msg)];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_status ()
{
  argv = [git, "status", "-s"];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_diff ()
{
  argv = [git, "diff"];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_fulllog ()
{
  variable
    lin = repeat ("_", COLUMNS);

  argv = [git, "log", "--pretty=format:commit: %h %H%n%s%ncommiter: %cn  %cD%n" + lin];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_log ()
{
  variable
    lin = repeat ("_", COLUMNS),
    year = string (localtime (_time).tm_year + 1900 - 2);

  argv = [git, "log", "--pretty=format:commit: %h %H%n%s%ncommiter: %cn  %cD%n" + lin,
    "--after=" + year];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_push_upstream ()
{
  argv = [git, "push", "--verbose", "--repo", url];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_get_upstream_url ()
{
  variable url;

  argv = [git, "config", "-l"];

  (stdoutr, stdoutw) = pipe ();
  (stderrr, stderrw) = pipe ();

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);

  () = array_map (Integer_Type, &_close, [2, 1, _fileno (stderrw), _fileno (stdoutw)]);

  if (status.exit_status)
    {
    url = strchop (read_fd (stderrr), '\n', 0);
    writefile (url, file;mode="a+");
    return 1;
    }

  url = read_fd (stdoutr);
  if (NULL == url)
    {
    writefile (["I cant get upstream's url"],  file);
    return 1;
    }

  url = strtrim_end (strchop (url, '\n', 0));
  url = url[wherenot (strncmp (url, "remote.upstream.url", strlen ("remote.upstream.url")))];
  ifnot (length (url))
    {
    writefile (["I cant get upstream's url"],  file);
    return 1;
    }
 
  url = strchop (url[0], '=', 0)[1];

  writefile (url,  file);

  return 0;
}

define git_pull ()
{
  argv = [git, "pull"];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_bisect_init ()
{
  argv = [git, "bisect", "start"];

  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);

  argv = [git, "bisect", "bad"];
 
  sleep (0.1);
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;

  argv = [git, "bisect", "good", revision];

  if ('~' == revision[0] && NULL != strtoint (revision[[1:]]))
    argv[-1] = sprintf ("HEAD%s", revision);

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);

  sleep (0.1);
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_bisect_bad ()
{
  argv = [git, "bisect", "bad"];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);

  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_bisect_good ()
{
  argv = [git, "bisect", "good"];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);

  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_bisect_reset ()
{
  argv = [git, "bisect", "reset"];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);

  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_applypatch ()
{
  argv = [git, "apply", "-p1", "--verbose", patch];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}


define git_logpatch ()
{
  argv = [git, "log", "-p"];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_lastlog ()
{
  argv = [git, "log", "-1", "HEAD", "-p"];

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define git_showdiffrevision ()
{
  argv = [git, "log", "--no-walk", "-p", revision];

  if ('~' == revision[0] && NULL != strtoint (revision[[1:]]))
    argv[-1] = sprintf ("%s%s", branch, revision);

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (argv[0], argv))
    return 1;
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define main ()
{
  variable
    func = NULL,
    mode = "w",
    retval,
    c = cmdopt_new ();

  c.add ("revision", &revision;type = "string");
  c.add ("patch", &patch;type = "string");
  c.add ("func", &func;type = "string");
  c.add ("file", &file;type = "string");
  c.add ("repo", &repo;type = "string");
  c.add ("newfile", &newfile;type = "string");
  c.add ("branch", &branch;type = "string");
  c.add ("msg", &msg;type = "string");
  c.add ("url", &url;type = "string");
  c.add ("mode", &mode;type = "string");

  () = c.process (__argv, 1);

  func = __get_reference (sprintf ("%s->git_%s",
        path_basename_sans_extname (__FILE__), func));
 
  if (NULL == func)
    {
    (@print_err) (sprintf ("No such function: %s", func));
    return 1;
    }

  if (-1 == chdir_to_repo (repo, file))
    return 1;

  ifnot ("none" == mode)
    open_files (file, file, mode, mode);

  retval = (@func);

  if ("none" == mode)
    return retval;

  () = _close (_fileno (stdoutw));
  () = _close (_fileno (stderrw));

  () = dup2_fd (out_fd, 1);
  () = dup2_fd (err_fd, 2);

  return retval;
}
