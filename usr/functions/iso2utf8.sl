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
    args = __pop_list (_NARGS - 1);

  args = list_to_array (args);
 
  index = proc->is_arg ("--pager", args);
  ifnot (NULL == index)
    {
    gotopager = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }
 
  if (NULL == proc->is_arg ("--help", args) &&
      NULL == proc->is_arg ("--info", args))
    writefile (["ICONV OUTPUT", repeat ("_", COLUMNS)], file);

  retval = proc->call (["iso2utf8", "--nocl",
      sprintf ("--execdir=%s/scripts", path_dirname (__FILE__)),
      sprintf ("--msgfname=%s", CW.msgbuf),
      sprintf ("--mainfname=%s", file),
      args]);

  if (NULL == proc->is_arg ("--help", args) &&
      NULL == proc->is_arg ("--info", args))
    ifnot (gotopager)
      (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
    else
      (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});
  else
    CW.drawwind ();

  throw GotoPrompt;
}
