define main ()
{
  variable
    file,
    index,
    retval,
    passwd,
    issudo = NULL,
    gotopager = 0,
    buf = CW.buffers[CW.cur.frame],
    mountpoint = NULL,
    umount = which ("umount"),
    args = __pop_list (_NARGS - 1);

  if (NULL == umount)
    {
    srv->send_msg ("umount couldn't be found in PATH", -1);
    throw GotoPrompt;
    }

  if (length (args))
    args = list_to_array (args);
  else
    args = String_Type[0];

  index = proc->is_arg ("--pager", args);
  ifnot (NULL == index)
    {
    gotopager = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  index = proc->is_arg ("--sudo", args);
  ifnot (NULL == index)
    {
    issudo = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  mountpoint = (
      retval = where (is_substr (args, "--mountpoint=")),
      length (retval)
        ? (retval = strchop (args[retval[0]], '=', 0),
          2 == length (retval)
            ? retval[1]
            : NULL)
        : NULL);
 
  if (NULL == mountpoint)
    {
    srv->send_msg ("--mountpoint= option is required", -1);
    throw GotoPrompt;
    }

  if (-1 == access (mountpoint, F_OK))
    {
    srv->send_msg (sprintf ("%s mountpoint doesn't exists", mountpoint), -1);
    throw GotoPrompt;
    }

  variable argv = [umount, "-v", mountpoint];

  ifnot (NULL == issudo)
    {
    argv = [
      SUDO_EXEC, "-S", "-E",  "-C", sprintf ("%d", _fileno (SRV_SOCKET)+ 1),
      argv];

    passwd = root.lib.getpasswd ();

    ifnot (strlen (passwd))
      {
      srv->send_msg ("Password is an empty string. Aborting ...", -1);
      throw GotoPrompt;
      }

    retval = root.lib.validate_passwd (passwd);

    if (NULL == retval)
      {
      srv->send_msg ("This is not a valid password", -1);
      throw GotoPrompt;
      }
    }

  variable
    pid,
    status,
    stdoutw,
    stderrw,
    err_fd = dup_fd (fileno (stderr)),
    out_fd = dup_fd (fileno (stdout));

  stdoutw = open (SCRATCHBUF, O_WRONLY|O_CREAT|O_TRUNC, S_IWUSR|S_IRUSR);
  stderrw = open (CW.msgbuf, O_WRONLY|O_APPEND, S_IWUSR|S_IRUSR);

  ifnot (NULL == issudo)
    {
    variable stdinr, stdinw;

    (stdinr, stdinw) = pipe ();

    () = write (stdinw, passwd + "\n");
    () = close (stdinw);
    }
 
  pid = fork ();

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
 
  ifnot (NULL == issudo)
    () = dup2_fd (stdinr, 0);

  if ((0 == pid) && -1 == execv (argv[0], argv))
    throw GotoPrompt;
 
  status = waitpid (pid, 0);

  () = _close (_fileno (stderrw));
  () = _close (_fileno (stdoutw));
  () = dup2_fd (err_fd, 2);
  () = dup2_fd (out_fd, 1);

  file = status.exit_status ? CW.msgbuf : SCRATCHBUF;
 
  if (status.exit_status)
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, func = "G"});
  else
    ifnot (gotopager)
      (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
    else
      (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});

  throw GotoPrompt;
}
