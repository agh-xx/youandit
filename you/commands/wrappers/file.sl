define main ()
{
  variable
    index,
    retval,
    gotopager = 0,
    buf = CW.buffers[CW.cur.frame],
    file_exec = which ("file"),
    args = __pop_list (_NARGS - 1);

  if (NULL == file_exec)
    {
    srv->send_msg ("file executable couldn't be found in PATH", -1);
    throw GotoPrompt;
    }

  ifnot (length (args))
    {
    srv->send_msg ("A filename is required", -1);
    throw GotoPrompt;
    }

  args = list_to_array (args);

  index = proc->is_arg ("--pager", args);
  ifnot (NULL == index)
    {
    gotopager = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  variable argv = [file_exec, args];

  variable
    pid,
    status,
    stdoutw,
    stderrw,
    err_fd = dup_fd (fileno (stderr)),
    out_fd = dup_fd (fileno (stdout));

  stdoutw = open (SCRATCHBUF, O_WRONLY|O_CREAT|O_TRUNC, S_IWUSR|S_IRUSR);
  stderrw = open (CW.msgbuf, O_WRONLY|O_APPEND, S_IWUSR|S_IRUSR);

  pid = fork ();

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);

  if ((0 == pid) && -1 == execv (argv[0], argv))
    {
    srv->send_msg ("file fork failed", -1);
    throw GotoPrompt;
    }
 
  status = waitpid (pid, 0);

  () = _close (_fileno (stderrw));
  () = _close (_fileno (stdoutw));
  () = dup2_fd (err_fd, 2);
  () = dup2_fd (out_fd, 1);
 
  if (status.exit_status)
    writefile (sprintf ("EXIT STATUS: %d", status.exit_status), SCRATCHBUF;mode="a");

  ifnot (gotopager)
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = SCRATCHBUF, send_break});
  else
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = SCRATCHBUF, send_break_at_exit});

  throw GotoPrompt;
}
