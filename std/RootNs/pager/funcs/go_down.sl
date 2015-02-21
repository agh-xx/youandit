define main (self, row, col, buf, frame, frame_size, len)
{
  variable
    linenr = buf.indices[wherefirst_eq (buf.rows, row)],
    linelen = strlen (self.getbufline (buf, qualifier ("file", buf.fname),
      linenr)) - 1,
    nrow,
    nextlinelen;
  %if (row + 1 > buf.rows[-1] && row + 1 < CURWIND.dim[frame].rowlast)

  if (self.pcount)
    {
    if (self.pcount + linenr > len)
      (@self.pfuncs["G"]) (self, row, col, buf, frame, frame_size, len;; __qualifiers ());
    else
      {
      self.pcount += linenr + 1;
      (@self.pfuncs["go_to_line"]) (self, &row, &col, buf, frame, frame_size, len;; __qualifiers ());
      }

    throw Break;
    }

  if (row + 1 > buf.rows[-1] && row + 1 <= self.dim[frame].rowlast)
    throw Break;

  if (row == self.dim[frame].rowlast)
    {
    if (buf.indices[-1] == length (buf.ar_len) - 1)
      throw Break;

    srv->clear_frame (frame_size, self.dim[frame].rowfirst,
        self.dim[frame].rowlast, COLOR.normal, qualifier_exists ("clear_infoline"));
    buf.linefirst++;
    buf.indices++;

    srv->write_ar_at (self.getbuf (buf, qualifier ("file", buf.fname)), COLOR.normal, buf.rows, 0);

    nrow = row;
    }
  else
    nrow = row + 1;

  nextlinelen = strlen (self.getbufline (buf, qualifier ("file", buf.fname),
    buf.indices[wherefirst_eq (buf.rows, nrow)]));

  if (col == linelen - 1 || col > nextlinelen - 1 ||
      (COLUMNS < linelen && col == COLUMNS - 1))
    (@self.pfuncs["-"]) (self, nrow, col, buf, frame, frame_size, len;;__qualifiers ());
  else
    self.set (buf, frame, len; setpos, row = row + 1, col = col);
}
