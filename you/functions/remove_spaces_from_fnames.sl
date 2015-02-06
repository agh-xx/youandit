define main ()
{
  variable
    index,
    retval,
    gotopager = 0,
    file = SCRATCHBUF,
    argv = __pop_list (_NARGS - 1);
 
  argv = list_to_array (argv, String_Type);

  index = proc->is_arg ("--pager", argv);
  ifnot (NULL == index)
    {
    gotopager = 1;
    argv[index] = NULL;
    argv = argv[wherenot (_isnull (argv))];
    }

  ifnot (length (argv))
    {
    srv->send_msg ("Wrong number of arguments", -1);
    throw GotoPrompt;
    }
 
  writefile (["REMOVE SPACES FROM FILENAMES OUTPUT", repeat ("_", COLUMNS)], file);

  retval =  proc->call (["remove_spaces_from_fnames", "--nocl",
        sprintf ("--execdir=%s/scripts", path_dirname (__FILE__)),
        sprintf ("--msgfname=%s", CW.msgbuf),
        sprintf ("--mainfname=%s", file),
        argv]);
 
  writefile (sprintf ("EXIT CODE: %d", retval), file; mode = "a");

  ifnot (gotopager)
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
  else
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});

  throw GotoPrompt;
}
