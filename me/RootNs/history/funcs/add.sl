define main (self, argv)
{
  argv = strjoin (argv, "||");
  ifnot (strlen (argv))
    throw Break;

  self.list = self.list[wherenot (self.list == argv)];

  self.list = [argv, length (self.list) > self.len ?
    self.list[[:self.len-1]] : self.list];

  throw Break;
}
