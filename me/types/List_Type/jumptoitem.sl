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
  ar = readfile (fname);

  self.cur.frame = 0;

  () = self.setar (buf, qualifier ("file", buf.fname));

  buf.firstchar = Integer_Type[length (ar) + 1];
  buf.firstchar[*] = 0;
  buf.mtime = lstat_file (buf.fname).st_mtime;
 
  self.setwindim ();

  self.set (buf, 0, length (ar) - 1; setline, setpos, setind, setrows);

  self.pcount = row;
  buf.pos[1] = col - 1;
  (@self.pfuncs["go_to_line"])
    (self, &buf.pos[0], &buf.pos[1], buf, 0, self.frames_size[0], length (ar) - 1);

  self.drawframe (0);
  self.writeinfolines ();
  self.gotopager ();
}
