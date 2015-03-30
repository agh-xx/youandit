define main ()
{
  variable
    fname,
    iswritable;

  ifnot (2 == _NARGS)
    {
    srv->send_msg ("(readfile) filename is required", -1);
 
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
 
    throw GotoPrompt;
    }

  fname = ();

  if (-1 == access (fname, F_OK|R_OK))
    {
    srv->send_msg (sprintf ("%s: can't open, ERRNO: %s", fname, errno_string (errno)), -1);
 
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
 
    throw GotoPrompt;
    }
 
  ifnot (stat_file (fname).st_size)
    {
    srv->send_msg (sprintf ("%s: has zero length", fname), -1);

    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
 
    throw GotoPrompt;
    }

  iswritable = access (fname, W_OK);
 
  srv->send_msg (sprintf ("%sReading %s", -1 == iswritable
        ? "[File Is Not Writable!], " : "", fname), iswritable);

  (@CW.gotopager) (CW, fname);

  throw GotoPrompt;
}
