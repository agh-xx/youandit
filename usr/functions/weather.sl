define main ()
{
  variable
    index,
    retval,
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
    writefile (readfile (sprintf ("%s/info/weather/help.txt", path_dirname (__FILE__))), file);

    ifnot (gotopager)
      (@CW.gotopager) (CW, file;drawonly);
    else
      (@CW.gotopager) (CW, file);

    throw GotoPrompt;
    }

  writefile ([repeat ("_", COLUMNS)], file);

  retval = proc->call (["weather", "--nocl", args,
      sprintf ("--execdir=%s/scripts", path_dirname (__FILE__)),
      sprintf ("--msgfname=%s", CW.msgbuf),
      sprintf ("--mainfname=%s", file)
      ]);
 
  if (retval)
   throw GotoPrompt;

  ifnot (gotopager)
    (@CW.gotopager) (CW, file;drawonly);
  else
    (@CW.gotopager) (CW, file);
 
  throw GotoPrompt;
}
