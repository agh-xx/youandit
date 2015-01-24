define main (self, row, col, buf, frame, frame_size, len)
{
  variable linelen = buf.ar_len[-1] - 1;

  buf.linefirst = len >= frame_size ? len - frame_size + 1 : 0;

  if (col > linelen)
    col = linelen;

  self.set (buf, frame, len; setpos, col = col, row = buf.rows[-1]);

  if (buf.linefirst)
    {
    self.set (buf, frame, len; setind, setrows, frame_size = frame_size, end = len);

    srv->clear_frame (frame_size, self.dim[frame].rowfirst,
        self.dim[frame].rowlast, COLOR.normal, qualifier_exists ("clear_infoline"));

    srv->write_ar_at (self.getbuf (buf, qualifier ("file", buf.fname)), COLOR.normal, buf.rows, 0);
    }
}
