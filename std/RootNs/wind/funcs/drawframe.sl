define main (self, frame)
{
  variable
    ar,
    len,
    buf = self.buffers[frame],
    mtime = lstat_file (buf.fname).st_mtime;

  if (mtime > buf.mtime || qualifier_exists ("reread_buf"))
    {
    len = (self.setar (buf, qualifier ("file", buf.fname)), pop (),
      length (buf.ar_len) - 1);

    buf.mtime = mtime;
    buf.firstchar = Integer_Type[len + 1];
    buf.firstchar[*] = 0;

    self.set (buf, frame, len;;struct {@__qualifiers (), setline, setpos, setind, setrows});

    ar = self.getbuf (buf, qualifier ("file", buf.fname));

    self.setinfoline (buf, frame, len; row = buf.pos[0], col = buf.pos[1]);
    }
  else
    ar = self.getbuf (buf, qualifier ("file", buf.fname));

  srv->draw_frame (
    [self.frames_size[frame], self.dim[frame].rowfirst,
    self.dim[frame].rowlast, COLOR.normal, qualifier_exists ("clear_infoline")],
    {ar, COLOR.normal, buf.rows, 0},
    {buf.infoline, [self.dim[frame].infolinecolor, self.dim[frame].infoline, 0]},
    [buf.pos[0], buf.pos[1]]);

  throw Break;
}
