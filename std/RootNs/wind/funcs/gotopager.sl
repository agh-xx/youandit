define main (self)
{
 
  variable ftype = qualifier ("ftype");

  if (NULL == ftype)
    (@self.pfuncs["pager"])
      (self;;__qualifiers ());
  else
    {
    ifnot (assoc_key_exists (FTYPES, ftype))
      {
      srv->send_msg (sprintf ("%s: Not such filetype", ftype), -1);
      if (qualifier_exists ("dont_goto_prompt")
        || qualifier_exists ("send_break_at_exit")
        || qualifier_exists ("send_break"))
        throw Break;

      throw GotoPrompt;
      }

    (@FTYPES[ftype].pager) (;;__qualifiers ());
    }
 
}
