define main ()
{
  variable
    index,
    retval,
    status,
    gotopager = 0,
    file = SCRATCHBUF,
    args = __pop_list (_NARGS - 1);
 
  args = list_to_array (args, String_Type);

  index = proc->is_arg ("--pager", args);
  ifnot (NULL == index)
    {
    gotopager = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }
 
  index = proc->is_arg ("--help", args);
  ifnot (NULL == index)
    {
    ifnot (gotopager)
      ved (sprintf ("%s/info/weather/help.txt", path_dirname (__FILE__));drawonly);
    else
      ved (sprintf ("%s/info/weather/help.txt", path_dirname (__FILE__));drawwind);

    throw GotoPrompt;
    }
 
  variable p = proc->init (0, 1, 1);

  p.stdout.file = SCRATCHBUF;
  p.stderr.file = SCRATCHBUF;
  p.stderr.wr_flags = ">>";
 
  args = [args, sprintf ("--dline=%s", repeat ("_", COLUMNS))];

  status = p.execv ([PROC_EXEC, sprintf ("%s/scripts/weather", path_dirname (__FILE__)),
    args], NULL);

  if (NULL == status)
    throw GotoPrompt;

  file = SCRATCHBUF;
 
  if (gotopager || status.exit_status)
    ved (file;drawwind);
  else
    ved (file;drawonly);

  throw GotoPrompt;
}
