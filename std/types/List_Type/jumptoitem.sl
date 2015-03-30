define main (self, action)
{
  if ("+" == action)
    {
    if (self.cur.linenr == self.len)
      self.cur.linenr = 1;
    else
      self.cur.linenr++;
    }
  else if ("-" == action)
    if (1 == self.cur.linenr)
      self.cur.linenr = self.len;
    else
      self.cur.linenr--;

  variable
    ar,
    tok = strchop (self.reportlist[self.cur.linenr-1], '|', 0),
    col = atoi (strtok (tok[1])[2]),
    row = atoi (strtok (tok[1])[0]),
    fname = sprintf ("%s%s", qualifier_exists ("dir") ? qualifier ("dir") + "/" : "",
        tok[0]),
    buf = self.buffers[0];

  if (-1 == access (fname, F_OK))
    {
    srv->send_msg (sprintf ("%s: No such filename", fname), -1);
    throw GotoPrompt;
    }

  buf.fname = fname;

  (@self.gotopager) (self, fname);
  %(@self.gotopager) (self, fname;func = 'G', count = row);
  self.drawframe (0;reread_buf);
  self.writeinfolines ();
  throw GotoPrompt;
}
