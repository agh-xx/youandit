define main (self, row, col, buf, frame, frame_size, len)
{
  variable
    str,
    line = self.getbufline (buf, qualifier ("file", buf.fname),
      buf.indices[wherefirst_eq (buf.rows, row)]),
    linelen = strlen (line);

  if (COLUMNS < linelen)
    {
    if (col == COLUMNS - 1)
      {
      variable index = &buf.firstchar[row - 1];

      if (@index + COLUMNS + 1 <= linelen)
        {
        @index++;
        str = substr (line, @index + 1, @index + COLUMNS - 1);
        srv->write_str_at (str, COLOR.normal, row, 0);
        srv->set_color_in_region (COLOR.border, row, COLUMNS - 1, 1, 1);
        }
      }
    else
      {
      if (COLUMNS - 1 > col + self.pcount)
        self.set (buf, frame, len;
          setpos, col = col + 1 + (self.pcount ? self.pcount - 1 : 0), row = row);
      else
        self.set (buf, frame, len; setpos, col = COLUMNS - 1, row = row);

      srv->set_color_in_region (COLOR.border, row, COLUMNS - 1, 1, 1);
      }
    }
  else
    if (linelen - 1 > col + self.pcount)
      self.set (buf, frame, len;
        setpos, col = col + 1 + (self.pcount ? self.pcount - 1 : 0), row = row);
    else
      self.set (buf, frame, len; setpos, col = linelen - 1, row = row);
}
