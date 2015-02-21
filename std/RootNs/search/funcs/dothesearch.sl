define main (self)
{
  variable retval;
  self.newlines = 0;
  self.wrap = 0;
  self.orig_index = self.index;
  self.newlinesinpat ();

  retval = self.origstr ();
  ifnot (NULL == retval)
    throw Break;

  if (self.type == "forward")
    self.forward ();
  else
    self.backward ();
}
