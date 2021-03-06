ineed ("isleap");
ineed ("checktmfmt");

define main ()
{
  variable
    tf,
    tok,
    err,
    tim,
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
    srv->send_msg ("You need the --tf=ss:mm:hh:dd:mm:yy switch", 0);
    throw GotoPrompt;
    }

  tim = args[0];

  ifnot ("--tf=" == substr (tim, 1, 5))
    {
    srv->send_msg ("You need the --tf=ss:mm:hh:dd:mm:yy switch", 0);
    throw GotoPrompt;
    }
 
  tim = strchop (tim, '=', 0)[1];
  tok = strchop (tim, ':', 0);
  if (6 != length (tok))
    {
    srv->send_msg ("time format is wrong, it should be ss:mm:hh:dd:mm:yy", 0);
    throw GotoPrompt;
    }

  tok = array_map (Integer_Type, &atoi, tok);
  tim = localtime (_time);
  set_struct_fields (tim, tok[0], tok[1], tok[2], tok[3], tok[4], tok[5]);

  retval = checktmfmt (tim);
  if (NULL == retval)
    {
    err = ();
    srv->send_msg (err, -1);
    throw GotoPrompt;
    }

  tf = strjoin (array_map (String_Type, &sprintf, "%.2d",
    [tim.tm_mon, tim.tm_mday, tim.tm_hour, tim.tm_min,
    tim.tm_year]));

  writefile (["SET CLOCK OUTPUT", repeat ("_", COLUMNS)], file);

  retval = proc->call (["setdate", "--nocl", "--sudo",
      sprintf ("--execdir=%s/scripts", path_dirname (__FILE__)),
      sprintf ("--msgfname=%s", CW.msgbuf),
      sprintf ("--mainfname=%s", file),
      tf]);

  ifnot (retval)
    {
    ifnot (gotopager)
      ved (file;drawonly);
    else
      ved (file;drawwind);
    }

  throw GotoPrompt;
}
