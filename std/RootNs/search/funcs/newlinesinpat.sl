define main (self)
{
  variable
    i;

  _for i (1, strlen (self.pattern))
    if ('n' == self.pattern[i] && '\\' == self.pattern[i-1])
      self.newlines++;

  throw Break;
}
