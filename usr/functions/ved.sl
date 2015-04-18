define main ()
{
  variable
    lnr,
    file,
    index,
    func = &ved,
    count = NULL,
    args = __pop_list (_NARGS - 1);

  args = list_to_array (args, String_Type);

  index = proc->is_arg ("--lnr=", args);
  ifnot (NULL == index)
    {
    lnr = strchop (args[index], '=', 0);
    if (2 == length (lnr))
      count = atoi (lnr[1]);

    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  index = proc->is_arg ("--sudo", args);
  ifnot (NULL == index)
    {
    func = &vedsudo;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  ifnot (length (args))
    file = CW.buffers[CW.cur.frame].fname;
  else
    file = args[0];

  if (file == "-")
    file = SCRATCHBUF;
 
  ifnot (NULL == count)
    (@func) (file;func = 'G', count = count);
  else
    (@func) (file);

  if (file == SCRATCHBUF || file != CW.buffers[CW.cur.frame].fname)
    CW.drawframe (CW.cur.frame);
 
  throw GotoPrompt;
}
