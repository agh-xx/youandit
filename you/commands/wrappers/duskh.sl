define main ()
{
  variable
    i,
    f,
    index,
    gotopager = 0,
    du = which ("du"),
    args = __pop_list (_NARGS - 1);

  if (NULL == du)
    {
    srv->send_msg ("du couldn't be found in PATH", -1);
    throw GotoPrompt;
    }

  variable argv = [du, "-s", "-c", "-k", "-h"];

  if (length (args))
    args = list_to_array (args);
  else
    args = [getcwd ()];

  index = proc->is_arg ("--pager", args);
  ifnot (NULL == index)
    {
    gotopager = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  _for i (0, length (args) - 1)
    {
    f = args[i];
    ifnot (isdirectory (f))
      argv = [argv, f];
    else
      argv = [argv, array_map (String_Type, &path_concat, f, listdir (f))];
    }

  variable
    fp,
    pid,
    file,
    status,
    stdoutw,
    stderrw,
    buf = CW.buffers[CW.cur.frame],
    err_fd = dup_fd (fileno (stderr)),
    out_fd = dup_fd (fileno (stdout));

  stdoutw = open (SCRATCHBUF, O_WRONLY|O_CREAT|O_TRUNC, S_IWUSR|S_IRUSR);
  stderrw = open (CW.msgbuf, O_WRONLY|O_APPEND, S_IWUSR|S_IRUSR);

  pid = fork ();

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);

  if ((0 == pid) && -1 == execv (argv[0], argv))
    throw GotoPrompt;
 
  status = waitpid (pid, 0);

  () = _close (_fileno (stderrw));
  () = _close (_fileno (stdoutw));
  () = dup2_fd (err_fd, 2);
  () = dup2_fd (out_fd, 1);

  file = status.exit_status ? CW.msgbuf : SCRATCHBUF;
 
  ifnot (gotopager)
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
  else
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});

  throw GotoPrompt;
}
