define main ()
{
  variable
    fname = 2 == _NARGS ? () : NULL,
    myname = path_basename_sans_extname (__FILE__),
    self = CW,
    mainfname = self.buffers[self.cur.frame].fname,
    linenr = qualifier ("linenr"),
    command = [myname,
      sprintf ("--execdir=%s/scripts", STDNS),
      sprintf ("--editor=%s", EDITOR),
      sprintf ("--fname=%s", NULL == fname ? mainfname : fname),
      sprintf ("--infodir=%s/scripts/info/%s", STDNS, myname),
      sprintf ("--linenr=%d", NULL == linenr ? 0 : linenr),
      sprintf ("--msgfname=%s", CW.msgbuf),
      sprintf ("--mainfname=%s", mainfname)],
    retval;
 
  if (NULL == EDITOR)
    {
    srv->send_msg ("Could't find any editor in path", -1);
    ifnot (qualifier_exists ("dont_goto_prompt"))
      throw GotoPrompt;

    throw Break;
    }
 
  srv->reset_smg ();
 
  ifnot (NULL == qualifier_exists ("nocl"))
    command = [command, "--nocl"];

  retval = proc->call (command);

  srv->init ();

  self.drawwind (;;struct {@__qualifiers (), reread_buf});

  srv->send_msg (sprintf ("%s returned %d", path_basename (EDITOR), retval),
      0 == retval ? 0 : -1);
 
  ifnot (qualifier_exists ("dont_goto_prompt"))
    throw GotoPrompt;

  throw Break;
}
