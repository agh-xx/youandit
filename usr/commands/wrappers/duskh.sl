define main ()
{
  variable
    i,
    f,
    file,
    index,
    status,
    issudo = NULL,
    passwd,
    retval,
    gotopager = 0,
    du = which ("du"),
    args = __pop_list (_NARGS - 1);

  if (NULL == du)
    {
    srv->send_msg ("du couldn't be found in PATH", -1);
    throw GotoPrompt;
    }

  variable argv = [du, "-s", "-c", "-k", "-h"];

  args = list_to_array (args, String_Type);

  ifnot (length (args))
    args = [getcwd ()];

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

    argv = [
      SUDO_EXEC, "-S", "-E",  "-C", sprintf ("%d", _fileno (SRV_SOCKET) + 1),
      argv];
    }

  _for i (0, length (args) - 1)
    {
    f = args[i];
    ifnot (isdirectory (f))
      argv = [argv, f];
    else
      argv = [argv, array_map (String_Type, &path_concat, f, listdir (f))];
    }

  variable p = proc->init (NULL != issudo, 1, 1);

  ifnot (NULL == issudo)
    p.stdin.in = passwd;

  p.stdout.file = SCRATCHBUF;
  p.stderr.file = CW.msgbuf;
  p.stderr.wr_flags = ">>";
 
  status = p.execv (argv, NULL);
  if (NULL == status)
    throw GotoPrompt;

  file = status.exit_status ? CW.msgbuf : SCRATCHBUF;

  ifnot (gotopager)
    ved (file;drawonly);
  else
    ved (file;drawwind);

  throw GotoPrompt;
}
