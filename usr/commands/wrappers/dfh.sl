define main ()
{
  variable
    file,
    argv,
    index,
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

  variable p = @i->init_proc (0, 1, 1, argv);

  p.stdout.file = SCRATCHBUF;
  p.stdout.wr_flags = ">|";

  p.stderr.file = CW.msgbuf;
  p.stderr.wr_flags = ">>";

  if (-1 == i->sysproc (p))
    throw GotoPrompt;

  file = p.status.exit_status ? CW.msgbuf : SCRATCHBUF;
 
  ifnot (gotopager)
    (@CW.gotopager) (CW, file;drawonly);
  else
    (@CW.gotopager) (CW, file);

  throw GotoPrompt;
}
