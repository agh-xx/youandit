define main ()
{
  variable
    fname = SCRATCHBUF,
    self = CW,
    mainfname = self.buffers[self.cur.frame].fname;
 
  if (-1 == access (fname, F_OK))
    {
    srv->send_msg_and_refresh (sprintf ("%s: No such filename", fname), -1);
    throw Break;
    }

  writefile ([repeat ("_", COLUMNS), readfile (fname)], mainfname;mode = "a");
  self.drawframe (self.cur.frame);

  throw GotoPrompt;
}
