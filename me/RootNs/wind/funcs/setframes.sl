define main (self)
{
  variable
    i,
    buf,
    len;

  _for i (0, length (self.buffers) - 1)
    {
    buf = self.buffers[i];
    len = length (buf.ar_len) - 1;
    self.set (buf, i, len; setline, setpos, setind, setrows);
    self.setinfoline (buf, i, len);
    }

  throw Break;
}
