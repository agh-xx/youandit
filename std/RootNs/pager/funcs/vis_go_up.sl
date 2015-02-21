define main (self, row, col, buf, frame)
{
  if (row == self.dim[frame].rowfirst)
    ifnot (buf.indices[wherefirst_eq (buf.rows, row)])
      throw Return, " ", -1;
    else
      buf.indices --;

  self.set (buf, frame, len; setpos, row = row - 1, col = col);

  throw Return, " ", 0;
}
