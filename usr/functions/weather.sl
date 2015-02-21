define main ()
{
  variable
    index,
    retval,
    gotopager = 0,
    file = SCRATCHBUF,
    buf = CW.buffers[CW.cur.frame],
    argv = __pop_list (_NARGS - 1);
 
  argv = list_to_array (argv, String_Type);

  index = proc->is_arg ("--pager", argv);
  ifnot (NULL == index)
    {
    gotopager = 1;
    argv[index] = NULL;
    argv = argv[wherenot (_isnull (argv))];
    }
 
  index = proc->is_arg ("--help", argv);
 
  ifnot (NULL == index)
    {
    writefile (readfile (sprintf ("%s/info/weather/help.txt", path_dirname (__FILE__))), file);
    ifnot (gotopager)
      (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
    else
      (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});

    throw GotoPrompt;
    }

  writefile ([repeat ("_", COLUMNS)], file);

  retval = proc->call (["weather", "--nocl", argv,
      sprintf ("--execdir=%s/scripts", path_dirname (__FILE__)),
      sprintf ("--msgfname=%s", CW.msgbuf),
      sprintf ("--mainfname=%s", file)
      ]);
 
  if (retval)
   throw GotoPrompt;
 
  ifnot (gotopager)
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
  else
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});

  throw GotoPrompt;
}
