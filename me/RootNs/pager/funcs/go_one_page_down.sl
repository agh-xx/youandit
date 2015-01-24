define main (self, row, col, buf, frame, frame_size, len)
{
  variable end;

  if (buf.indices[-1] == len || len < frame_size)
    return;

  buf.linefirst = buf.indices[0] + frame_size - 1;
  end = buf.indices[-1] + frame_size - 1;

  if (end > len)
    {
    end = len;
    buf.linefirst = len - frame_size + 1;
    }

  srv->clear_frame (frame_size, self.dim[frame].rowfirst,
      self.dim[frame].rowlast, COLOR.normal, qualifier_exists ("clear_infoline"));
 
  self.set (buf, frame, len; setind, setrows, frame_size = frame_size, end = end);

  srv->write_ar_at (self.getbuf (buf, qualifier ("file", buf.fname)), COLOR.normal, buf.rows, 0);

  self.set (buf, frame, len;setpos, row = self.dim[frame].rowfirst, col = col);
}
