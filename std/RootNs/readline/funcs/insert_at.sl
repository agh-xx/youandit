define main (self)
{
  variable
    i,
    arglen,
    len = 0,
    chr = char (qualifier ("chr", self.cur.chr));

  self.cur.col++;
 
  _for i (0, self.cur.index)
    {
    arglen = strlen (self.cur.argv[i]);
    len += arglen + 1;
    }

  len = self.cur.col - (len - arglen);

  if (self.cur.col == len)
    self.cur.argv[i] += chr;
  else
    ifnot (len)
      if (i > 0)
        self.cur.argv[i-1] += chr;
      else
        self.cur.argv[i] = chr + self.cur.argv[i];
    else
      self.cur.argv[i] = sprintf ("%s%s%s", substr (self.cur.argv[i], 1, len - 1), chr,
        substr (self.cur.argv[i], len, -1));
}
