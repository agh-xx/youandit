define main (self, row, col, buf, frame, frame_size, len)
{
  variable
    line = self.getbufline (buf, qualifier ("file", buf.fname),
      buf.indices[wherefirst_eq (buf.rows, row)]),
    linelen = strlen (line);

  ifnot (COLUMNS < linelen)
    (@self.pfuncs["$"]) (self, row, col, buf, frame, frame_size, len;; __qualifiers ());
  else
    {
    variable str = sprintf ("%s", substr (line, linelen - COLUMNS + 1, -1));
    srv->write_str_at (str, COLOR.normal, row, 0);

    self.set (buf, frame, len; setpos, col = COLUMNS - 1, row = row);

    buf.firstchar[row-1] = linelen - COLUMNS;
    }
}
