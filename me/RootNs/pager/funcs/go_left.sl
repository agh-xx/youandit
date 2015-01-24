define main (self, row, col, buf, frame, frame_size, len)
{
  variable
    str,
    line = self.getbufline (buf, qualifier ("file", buf.fname),
      buf.indices[wherefirst_eq (buf.rows, row)]),
    linelen = strlen (line);

  if (COLUMNS < linelen)
    ifnot (col)
      {
      variable index = &buf.firstchar[row-1];
      if (@index)
        {
        str = substr (line, @index, @index + COLUMNS);
        srv->write_str_at (str, COLOR.normal, row, 0);
        @index--;
        }
      }

  self.set (buf, frame, len; setpos, col = col - 1 - self.pcount, row = row);
}
