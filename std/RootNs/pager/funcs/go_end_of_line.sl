define main (self, row, col, buf, frame, frame_size, len)
{
  variable
    linelen = strlen (self.getbufline (buf, qualifier ("file", buf.fname),
      buf.indices[wherefirst_eq (buf.rows, row)])) - 1,
    ncol = COLUMNS > linelen ? linelen : COLUMNS - 1;

  self.set (buf, frame, len; setpos, col = ncol, row = row);
}
