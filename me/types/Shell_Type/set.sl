define main (self, buf, frame, len)
{
  variable
    fram,
    row,
    col,
    end,
    size_ar,
    frame_last_row,
    frame_first_row;

  if (qualifier_exists ("setline"))
    {
    ifnot (qualifier_exists ("iamreal"))
      {
      fram = qualifier ("frame", 0);
      buf.linefirst = len >= self.frames_size[fram] ? len - self.frames_size[fram] + 1 : 0;
      }
    else
      buf.linefirst = qualifier ("linefirst", 0);

    if (buf.linefirst > len || buf.linefirst < 0)
      buf.linefirst = 0;
    }

  if (qualifier_exists ("setpos"))
    {
    row = qualifier ("row", 0);
    col = qualifier ("col", 0);
    frame_first_row = self.dim[frame].rowfirst;
    frame_last_row = self.dim[frame].rowlast;

    if (COLUMNS <= col || 0 > col)
      col = 0;
 
    if (row < frame_first_row)
      row = frame_first_row;

    if (row > frame_last_row)
      row = frame_last_row;

    buf.pos = [row, col];
    }

  if (qualifier_exists ("setind"))
    {
    size_ar = qualifier ("frame_size", self.frames_size[frame]),
    end = qualifier_exists ("iamreal")
      ? qualifier ("end", len >= size_ar ? size_ar - 1 : len)
      : qualifier ("end", len);

    if (end > len)
      end = len;

    buf.indices = [buf.linefirst:end];
    }

  if (qualifier_exists ("setrows"))
    {
    buf.rows = [self.dim[frame].rowfirst:
    self.dim[frame].rowfirst + length (buf.indices) - 1];
    }

  throw Break;
}
