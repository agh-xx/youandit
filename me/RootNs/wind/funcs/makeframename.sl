define main (self)
{
  variable
    framename = sprintf ("%s/%s/buf_%d_%s.txt", TMPDIR, self.name,
      self.frames - 1, string (_time)[[-5:]]);

  while (0 == access (framename, F_OK))
    framename = sprintf ("%s/%s/buf_%d_%s.txt", TMPDIR, self.name,
      self.frames - 1, string (_time)[[-5:]]);
 
  throw Return, " ", framename;
}
