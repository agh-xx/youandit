define main ()
{
  variable
    index,
    gotopager = 0,
    file = SCRATCHBUF,
    argv = __pop_list (_NARGS - 1),
    pids,
    coms;

  (pids, coms) = proc->get_bg_list ();

  ifnot (length (pids))
    {
    srv->send_msg ("No background jobs", 0);
    throw GotoPrompt;
    }

  if (length (argv))
    {
    argv = list_to_array (argv);
    index = proc->is_arg ("--pager", argv);
    ifnot (NULL == index)
      gotopager = 1;
    }
 
  writefile (array_map (String_Type, &sprintf, "%d : %s", pids, coms), SCRATCHBUF);

  ifnot (gotopager)
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
  else
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});

  throw GotoPrompt;
}
