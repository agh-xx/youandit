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
    if (self.wrap && index <= self.orig_index)
      {
      self.retval = 0;
      throw Break;
      }

    if (self.newlines)
      {
      if (index + self.newlines > self.len)
        {
        index--;
        continue;
        }

      if (index < 0)
        {
        self.wrap = 1;
        orig_index = self.len;
        str = strjoin (self.ar[[self.len-self.newlines:]], "\n");
        index = self.len - 1;
        }
      else
        {
        orig_index = index;
        str = strjoin (self.ar[[index-self.newlines:index]], "\n");
        index--;
        }
      }
    else
      {
      index--;
      if (index < 0)
        {
        orig_index = self.len;
        self.wrap = 1;
        index = self.len;
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
