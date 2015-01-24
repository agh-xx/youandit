define main (self, buf, frame, len)
{
  if (2 == frame || self.cur.mode == "pager")
    {
    variable
      row = qualifier ("row", buf.indices[wherefirst_eq (buf.rows, buf.pos[0])]),
      col = qualifier ("col", buf.pos[1]),
      frame2msg = sprintf ("[%s], [%d], (%d/%d) %d, %.0f%%  F:%d", buf.name,
      qualifier ("hlchar", srv->char_at ()), row + 1, len + 1, col,
        (100.0 / len) * row, frame);
    }

  variable
    msg = "process table",
    spaces = repeat (" ", COLUMNS - strlen (msg));

  self.buffers[frame].infoline = sprintf ("%s%s", msg, spaces);
}
