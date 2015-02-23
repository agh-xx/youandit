define main (self, buf, frame, len)
{
  buf = NULL == buf ? self.buffers[self.cur.frame] : buf;
  len = NULL == len ? length (buf.ar_len) : len;

  variable
    row = qualifier ("row", buf.indices[wherefirst_eq (buf.rows, buf.pos[0])]),
    col = qualifier ("col", buf.pos[1]),
    msg = sprintf ("[%s], [%d], (%d/%d) %d, %.0f%%  F:%d", buf.name,
      qualifier ("hlchar", srv->char_at ()), row + 1, len + 1, col + 1,
        (100.0 / len) * row, frame),
    msglen = NULL == msg ? 0 : strlen (msg),
    spaces = COLUMNS - msglen;

  buf.infoline = sprintf ("%s%s", msglen ? msg  : "", spaces ?
    repeat (" ", spaces) : "");
}
