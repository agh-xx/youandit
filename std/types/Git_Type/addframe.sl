define main (self)
{
  if (self.frames + 1 > self.maxframes)
    {
    srv->send_msg (sprintf (
          "%d: Max Frames variable length exceeded", self.maxframes), -1);

    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;

    self.gotoprompt ();
    }

  self.frames++;

  variable
    ar,
    framename = self.makeframename (),
    sname = path_basename_sans_extname (framename);

  self.buffers = [self.buffers, @Frame_Type];

  variable buf = self.buffers[-1];
  buf.fname = framename;
  buf.name = sname;
  buf.type = qualifier ("type", strlow (self.type));

  self.cur.frame = self.frames -1;

  if (2 == self.frames)
    {
    self.cur.mainbufframe = 1;
    self.cur.mainbuf = buf.fname;
    buf.type = "shell_type";
    self.cur.mode = "shell";
    ar = [sprintf ("Shell in a Git Window, Started at: %s", strftime ("%c"))];
    }
  else if (1 == self.frames)
    {
    if (NULL == self.repos)
      ar = ["No Repos Available", "Use the 'addrepo' command to add a new repository"];
    else
      ar = ["Available Repositories", repeat ("_", COLUMNS), self.repos];
    }

  buf.firstchar = Integer_Type[length (ar) + 1];
  buf.firstchar[*] = 0;
  writefile (ar, buf.fname);
  buf.mtime = lstat_file (buf.fname).st_mtime;

  self.setframesize ();
  self.setwindim ();
  self.setframes ();

  ifnot (qualifier_exists ("dont_draw"))
    {
    self.writeinfolines ();

    self.drawwind (;reread_buf);
    }

  if (qualifier_exists ("goto_prompt"))
    self.gotoprompt ();
}
