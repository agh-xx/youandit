define main (self)
{
  variable
    orig_index,
    start,
    end,
    retval,
    str,
    ncol;

  if ("\\" == self.pattern)
    {
    self.retval = 0;
    throw Return, " ", 0;;
    }

  if (self.newlines)
    {
    if (self.type == "forward")
      {
      if (self.index + self.newlines > self.len)
        {
        self.wrap = 1;
        orig_index = 0;
        self.index = 0;
        str = strjoin (self.ar[[:self.newlines-1]], "\n");
        }
      else
        {
        ncol = 1;
        orig_index = self.index;
        str = sprintf ("%s\n%s", self.ar[self.index][[self.col:]],
          strjoin (self.ar[[self.index+1:self.index+self.newlines-1]], "\n"));
        }
      }
    else
      {
      while (self.index + self.newlines > self.len)
        self.index--;

      if (self.index < 0)
        {
        self.wrap = 1;
        self.index = self.len;
        orig_index = self.len;
        str = strjoin (self.ar[[self.len-self.newlines:]], "\n");
        }
      else
        {
        orig_index = self.index;
        str = sprintf ("%s\n%s",
          strjoin (self.ar[[self.index-self.newlines-1:self.index-1]]),
          self.ar[self.index][[0:self.col]]);
        }
      }
    }
  else
    if (self.type == "forward")
      {
      ncol = 1;
      orig_index = self.index;
      str = self.ar[self.index][[self.col:]];
      }
    else
      {
      orig_index = self.index;
      str = self.ar[self.index];
      retval = self.searchexec (str, &start, &end);

      if (retval)
        {
        if (start > self.col)
          self.index--;
        throw Return, " ", NULL;
        }
      throw Return, " ", NULL;
      }

    retval = self.searchexec (str, &start, &end);

    if (retval)
      {
      self.retval = 1;
      self.linenr = orig_index;
      self.start = __is_initialized (&ncol) ? start + self.col : start;
      self.end = end;
      throw Return, " ", 0;
      }

    throw Return, " ", NULL;
}
