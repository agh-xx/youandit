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

  ifnot (length (args))
    {
    srv->send_msg ("Wrong number of arguments", -1);
    throw GotoPrompt;
    }
 
  writefile (["REMOVE SPACES FROM FILENAMES OUTPUT", repeat ("_", COLUMNS)], file);

  retval =  proc->call (["remove_spaces_from_fnames", "--nocl",
        sprintf ("--execdir=%s/scripts", path_dirname (__FILE__)),
        sprintf ("--msgfname=%s", CW.msgbuf),
        sprintf ("--mainfname=%s", file),
        args]);
 
  writefile (sprintf ("EXIT CODE: %d", retval), file; mode = "a");

  ifnot (gotopager)
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
  else
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});

  throw GotoPrompt;
}
