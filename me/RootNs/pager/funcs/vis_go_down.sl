define main (self, row, col, buf, frame)
{
 
  if (row + 1 > buf.rows[-1] && row + 1 <= self.dim[frame].rowlast)
    throw Return, " ", -1;

  if (row == self.dim[frame].rowlast)
    if (buf.indices[-1] == length (buf.ar) - 1)
      throw Return, " ", -1;
    else
      buf.indices++;

  self.set (buf, frame, len; setpos, row = row + 1, col = col);

  throw Return, " ", 0;
}
