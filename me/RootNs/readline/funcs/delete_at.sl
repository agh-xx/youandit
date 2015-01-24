define main (self)
{
  variable
    i,
    arglen,
    len = 0;

  ifnot (qualifier_exists ("is_delete"))
    self.cur.col --;
 
  _for i (0, self.cur.index)
    {
    arglen = strlen (self.cur.argv[i]);
    len += arglen + 1;
    }
 
  len = self.cur.col - (len - arglen);

  if (0 > len)
    {
    if (arglen)
      self.cur.argv[i-1] += self.cur.argv[i];
 
    self.cur.argv[i] = NULL;
    self.cur.argv = self.cur.argv[wherenot (_isnull (self.cur.argv))];
    }
  else
    ifnot (len)
      self.cur.argv[i] = substr (self.cur.argv[i], 2, -1);
    else
      if (len + 1 == arglen)
        self.cur.argv[i] = substr (self.cur.argv[i], 1, len);
      else
        self.cur.argv[i] = substr (self.cur.argv[i], 1, len) +
          substr (self.cur.argv[i], len + 2, -1);
}
