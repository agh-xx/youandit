define main ()
{
  variable
    i,
    f,
    file,
    index,
    status,
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

  variable p = proc->init (0, 1, 1);

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
