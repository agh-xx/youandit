define main ()
{
  variable
    retval,
    fname,
    ar,
    self;

  ifnot (2 == _NARGS)
    {
    srv->send_msg ("wrong number of args, a filename is required", -1);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
    throw GotoPrompt;
    }

  fname = ();
  self = CW;
 
  ifnot (qualifier_exists ("array"))
    ar = readfile (self.buffers[self.cur.frame].fname);
  else
    ar = qualifier ("array");

  ifnot (access (fname, F_OK))
    {
    if (-1 == access (fname, R_OK))
      {
      srv->send_msg (sprintf ("%s: is not writable", fname), -1);
      if (qualifier_exists ("dont_goto_prompt"))
        throw Break;
      else
        throw GotoPrompt;
      }

    retval = root.lib.ask ([sprintf ("%s: exists", fname),
       "do you want to override?", "[y/n/escape to abort]"],
       ['y', 'n'];header = "QUESTION FROM THE WRITE FUNCTION");

    if ('n' == retval || 033 == retval)
      {
      srv->send_msg ("Aborting ...", 0);
      if (qualifier_exists ("dont_goto_prompt"))
        throw Break;
      else
        throw GotoPrompt;
      }
    }

  try
    {
    writefile (ar, fname);
    srv->send_msg (sprintf ("Written %d lines to %s", length (ar), fname), 0);
    }
  catch AnyError:
    root.lib.printtostdout (exception_to_array ());
  finally
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
    else
      throw GotoPrompt;
}
