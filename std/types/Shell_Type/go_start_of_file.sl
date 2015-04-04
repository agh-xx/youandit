define main (self, row, col, buf, frame, frame_size, len)
{
  variable
    end = len >= frame_size ? frame_size - 1 : len,
    linelen = strlen (self.getbufline (buf, qualifier ("file", buf.fname), 0)) - 1;

  buf.linefirst = 0;

  if (buf.indices[0])
    {
    self.set (buf, frame, len; setind, end = end, frame_size = frame_size);

    srv->clear_frame (frame_size, self.dim[frame].rowfirst,
      self.dim[frame].rowlast, COLOR.normal, qualifier_exists ("clear_infoline"));

    srv->write_ar (self.getbuf (buf, qualifier ("file", buf.fname)), COLOR.normal, buf.rows, 0);
    }

  if (col > linelen)
    col = linelen;
 
  self.set (buf, frame, len; setpos, col = col , row = 0);
}
