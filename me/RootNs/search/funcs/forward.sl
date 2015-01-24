define main (self)
{
  variable
    str,
    start,
    end,
    retval = 0,
    orig_index,
    index = self.index;

  forever
    {
    if (self.wrap && index >= self.orig_index)
      {
      self.retval = 0;
      throw Break;
      }

    if (self.newlines)
      {
      if (index + self.newlines > self.len)
        {
        self.wrap = 1;
        orig_index = 0;
        str = strjoin (self.ar[[0:self.newlines]], "\n");
        index++;
        }
      else
        {
        orig_index = index;
        str = strjoin (self.ar[[index:index+self.newlines]], "\n");
        index++;
        }
      }
    else
      {
      index++;

      if (index > self.len)
        {
        self.wrap = 1;
        orig_index = 0;
        index = 0;
        }
      else
        orig_index = index;

      str = self.ar[index];
      }

    retval = self.searchexec (str, &start, &end);

    if (retval)
      {
      self.retval = 1;
      self.linenr = orig_index;
      self.start = start;
      self.end = end;
      throw Break;
      }
    }
}
