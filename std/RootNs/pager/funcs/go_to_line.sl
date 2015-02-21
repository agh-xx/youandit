define main (self, row, col, buf, frame, frame_size, len)
{
  variable linelen, end;

  if (self.pcount > len + 1 || self.pcount < 1)
    throw Break;

  buf.linefirst = self.pcount - 1;

  if (len < frame_size)
    {
    buf.linefirst = 0;
    @row = self.pcount;
    end = len;
    }
  else if (self.pcount + frame_size > len)
    {
    buf.linefirst = len - frame_size + 1;
    @row = buf.rows[-1] - (len - self.pcount + 1);
    end = len;
    }
  else
    {
    end = self.pcount + frame_size - 2;
    @row = buf.rows[0];
    }

  if (buf.linefirst || qualifier_exists ("go_anyway"))
    {
    self.set (buf, frame, len; setind, setrows, frame_size = frame_size, end = end);

    srv->clear_frame (frame_size, self.dim[frame].rowfirst,
        self.dim[frame].rowlast, COLOR.normal, qualifier_exists ("clear_infoline"));

    srv->write_ar_at (self.getbuf (buf, qualifier ("file", buf.fname)), COLOR.normal,
      buf.rows, 0);
 
    }

  linelen = strlen (self.getbufline (buf, qualifier ("file", buf.fname),
    buf.indices[wherefirst_eq (buf.rows, @row)])) - 1;

  if (@col > linelen)
    @col = linelen;
 
  self.set (buf, frame, len; setpos, col = @col, row = @row);
}
