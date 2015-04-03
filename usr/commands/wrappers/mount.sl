ineed ("fileis");

define main ()
{
  variable
    p,
    file,
    argv,
    index,
    retval,
    status,
    passwd,
    issudo = NULL,
    gotopager = 0,
    mountpoint = NULL,
    device = NULL,
    mount = which ("mount"),
    args = __pop_list (_NARGS - 1);

  if (NULL == mount)
    {
    srv->send_msg ("mount couldn't be found in PATH", -1);
    throw GotoPrompt;
    }

  args = list_to_array (args, String_Type);

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

  ifnot (length (args))
  {
  p = proc->init (0, 1, 1);
 
  p.stdout.file = SCRATCHBUF;
  p.stderr.file = CW.msgbuf;
  p.stderr.wr_flags = ">>";
 
  status = p.execv ([mount], NULL);

  if (NULL == status)
    throw GotoPrompt;

  file = status.exit_status ? CW.msgbuf : SCRATCHBUF;

  ifnot (gotopager)
    ved (file;drawonly);
  else
    ved (file;drawwind);

  throw GotoPrompt;
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
 
  device = (
      retval = where (is_substr (args, "--device=")),
      length (retval)
        ? (retval = strchop (args[retval[0]], '=', 0),
          2 == length (retval)
            ? retval[1]
            : NULL)
        : NULL);

  if (NULL == device)
    {
    srv->send_msg ("--device= option is required", -1);
    throw GotoPrompt;
    }

  ifnot (isblock (device))
    {
    srv->send_msg (sprintf ("%s is not a block device", device), -1);
    throw GotoPrompt;
    }

  argv = [mount, "-v", device, mountpoint];

  ifnot (NULL == issudo)
    {
    argv = [
      SUDO_EXEC, "-S", "-E",  "-C", sprintf ("%d", _fileno (SRV_SOCKET) + 1),
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
 
  p = proc->init (NULL != issudo, 1, 1);

  ifnot (NULL == issudo)
    p.stdin.in = passwd;

  p.stdout.file = SCRATCHBUF;
  p.stderr.file = CW.msgbuf;
  p.stderr.wr_flags = ">>";
 
  status = p.execv (argv, NULL);
  if (NULL == status)
    throw GotoPrompt;

  file = status.exit_status ? CW.msgbuf : SCRATCHBUF;

  if (status.exit_status)
    ved (file;func='G', drawwind);
  else
    ifnot (gotopager)
      ved (file;drawonly);
    else
      ved (file;drawwind);

  throw GotoPrompt;
}
