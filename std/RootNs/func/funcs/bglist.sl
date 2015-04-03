define main ()
{
  variable
    pids,
    coms,
    index,
    gotopager = 0,
    file = SCRATCHBUF,
    args = __pop_list (_NARGS - 1);

  (pids, coms) = proc->get_bg_list ();

  ifnot (length (pids))
    {
    srv->send_msg ("No background jobs", 0);
    throw GotoPrompt;
    }
 
  args = list_to_array (args, String_Type);
  index = proc->is_arg ("--pager", args);
  ifnot (NULL == index)
    gotopager = 1;
 
  writefile (array_map (String_Type, &sprintf, "%d : %s", pids, coms), file);

  ifnot (gotopager)
    (@CW.gotopager) (CW, file;drawonly);
  else
    (@CW.gotopager) (CW, file);

  throw GotoPrompt;
}
