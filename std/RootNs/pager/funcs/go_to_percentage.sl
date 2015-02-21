define main (self, row, col, buf, frame, frame_size, len)
{
  if (100 < self.pcount)
    {
    srv->send_msg (sprintf ("%d: is more than 100 for percentage", self.pcount), 1);
    return;
    }

  % default middle
  self.pcount = 1 == self.pcount ? 50 : self.pcount;

  % code from vim editor
  variable linenr = (self.pcount * len + 99) / 100;

  buf.linefirst = linenr > frame_size ? linenr - frame_size + 1 : 0;

  if (buf.linefirst)
    {
    self.set (buf, frame, len; setind, setrows, frame_size = frame_size, end = linenr);

    srv->clear_frame (frame_size, self.dim[frame].rowfirst,
        self.dim[frame].rowlast, COLOR.normal, qualifier_exists ("clear_infoline"));

    srv->write_ar_at (self.getbuf (buf, qualifier ("file", buf.fname)), COLOR.normal, buf.rows, 0);
    }

  row =  buf.rows[0];

  variable
    linelen = strlen (self.getbufline (buf, qualifier ("file", buf.fname),
      buf.indices[wherefirst_eq (buf.rows, row)])) - 1;

  if (col > linelen)
    col = linelen;

  self.set (buf, frame, len; setpos, col = col, row = row);
}
