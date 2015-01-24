define main (self, row, col, buf, frame, frame_size, len)
{
  variable
    linenr = buf.indices[wherefirst_eq (buf.rows, row)],
    linelen = strlen (self.getbufline (buf, qualifier ("file", buf.fname),
      linenr)) - 1,
    prrow,
    prevlinelen;

  if (self.pcount)
    {
    if (linenr - self.pcount + 1 < 0)
      (@self.pfuncs["g"]) (self, row, col, buf, frame, frame_size, len;; __qualifiers ());
    else
      {
      self.pcount = linenr + 1 - self.pcount;
      (@self.pfuncs["go_to_line"]) (self, &row, &col, buf, frame, frame_size, len);
      }

    throw Break;
    }

  if (row == self.dim[frame].rowfirst)
    ifnot (buf.indices[wherefirst_eq (buf.rows, row)])
      throw Break;
    else
      {
      buf.indices --;
      buf.linefirst --;
      srv->clear_frame (frame_size, self.dim[frame].rowfirst,
        self.dim[frame].rowlast, COLOR.normal, qualifier_exists ("clear_infoline"));

      srv->write_ar_at (self.getbuf (buf, qualifier ("file", buf.fname)), COLOR.normal, buf.rows, 0);

      prrow = row;
      }
  else
    prrow = row - 1;

  prevlinelen = strlen (self.getbufline (buf, qualifier ("file", buf.fname),
    buf.indices[wherefirst_eq (buf.rows, prrow)])) - 1;

  if (col == linelen - 1 || col > prevlinelen - 1 ||
      (COLUMNS < linelen && col == COLUMNS - 1))
    (@self.pfuncs["-"]) (self, prrow, col, buf, frame, frame_size, len;;__qualifiers ());
  else
    self.set (buf, frame, len; setpos, row = row - 1, col = col);
}
