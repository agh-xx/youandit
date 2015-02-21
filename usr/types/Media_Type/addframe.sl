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

  if (1 == self.frames || 3 == self.frames)
    self.cur.frame = self.frames - 1;

  if (3 == self.frames)
    {
    self.cur.mainbufframe = 2;
    self.cur.mainbuf = buf.fname;
    buf.type = "shell_type";
    self.cur.mode = "shell";
    ar = [sprintf ("Shell in a Media Window, Started at: %s", strftime ("%c"))];
    }
  else if (1 == self.frames)
    ar = [" "];
  else if (2 == self.frames)
    ar = ["Nothing is playing"];

  buf.firstchar = Integer_Type[length (ar) + 1];
  buf.firstchar[*] = 0;
  writefile (ar, buf.fname);
  buf.mtime = lstat_file (buf.fname).st_mtime;

  self.setframesize (;frame_size = 5);
  self.setwindim ();
  self.setframes ();

  ifnot (qualifier_exists ("dont_draw"))
    {
    self.writeinfolines ();

    self.drawwind (;frame_size = 5);
    }

  if (qualifier_exists ("goto_prompt"))
    self.gotoprompt ();
}
