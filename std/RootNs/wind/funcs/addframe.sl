define main (self)
{
  variable
    buf,
    framename,
    ar = qualifier ("array", qualifier ("headerarr", [sprintf
      ("Session started at: %s", strftime ("%c"))]));
 
  if (self.frames + 1 > self.maxframes)
    {
    srv->send_msg (sprintf ("%d: Max Frames variable length exceeded", self.maxframes), -1);

    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;

    self.gotoprompt ();
    }

  self.frames++;

  framename = qualifier ("framename", self.makeframename ());

  self.buffers = [self.buffers, @Frame_Type];

  buf = self.buffers[-1];
  buf.fp = fopen (framename, "w+");
  buf.fname = framename;
  buf.name = path_basename_sans_extname (framename);
  buf.type = qualifier ("type", strlow (self.type));

  ifnot (qualifier_exists ("dont_make_it_current"))
    {
    self.cur.frame = self.frames - 1;
    self.cur.mainbuf = buf.fname;
    self.cur.mainbufframe = self.frames - 1;
    }

  buf.firstchar = Integer_Type[length (ar) + 1];
  buf.firstchar[*] = 0;

  ifnot (qualifier_exists ("dont_write"))
    {
    () = ar_to_fp (ar, "%s\n",
      qualifier ("file") ? fopen (qualifier ("file"), "w+") : buf.fp);
    buf.mtime = lstat_file (buf.fname).st_mtime;
    }

  self.setframesize (;;__qualifiers ());
  self.setwindim ();
  self.setframes ();

  ifnot (qualifier_exists ("dont_draw"))
    {
    self.writeinfolines ();
    self.drawwind (;;__qualifiers ());
    }

  if (qualifier_exists ("goto_prompt"))
    self.gotoprompt ();
}
