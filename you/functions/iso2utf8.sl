define main ()
{
  if (1 == _NARGS)
    {
    srv->send_msg ("Wrong number of arguments", -1);
    throw GotoPrompt;
    }

  variable
    index,
    retval,
    gotopager = 0,
    file = SCRATCHBUF,
    argv = __pop_list (_NARGS - 1);

  argv = list_to_array (argv);
 
  index = proc->is_arg ("--pager", argv);
  ifnot (NULL == index)
    {
    gotopager = 1;
    argv[index] = NULL;
    argv = argv[wherenot (_isnull (argv))];
    }
 
  if (NULL == proc->is_arg ("--help", argv) &&
      NULL == proc->is_arg ("--info", argv))
    writefile (["ICONV OUTPUT", repeat ("_", COLUMNS)], file);

  retval = proc->call (["iso2utf8", "--nocl",
      sprintf ("--execdir=%s/scripts", path_dirname (__FILE__)),
      sprintf ("--msgfname=%s", CW.msgbuf),
      sprintf ("--mainfname=%s", file),
      argv]);

  if (NULL == proc->is_arg ("--help", argv) &&
      NULL == proc->is_arg ("--info", argv))
    ifnot (gotopager)
      (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
    else
      (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});
  else
    CW.drawwind ();

  throw GotoPrompt;
}
