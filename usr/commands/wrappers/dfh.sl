define main ()
{
  variable
    file,
    argv,
    index,
    status,
    gotopager = 0,
    args = __pop_list (_NARGS - 1),
    df = which ("df");

  if (NULL == df)
    {
    srv->send_msg ("df couldn't be found in PATH", -1);
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
 
  argv = [df, "-h"];

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
