define main ()
{
  variable
    argv,
    file,
    index,
    status,
    gotopager = 0,
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

  argv = [file_exec, args];

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
