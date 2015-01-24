define main (self)
{
  while (_stkdepth > 1)
    pop ();

  variable mode = strlow (strchop (self.type, '_', 0)[0]);
  self.cur.mode = mode;
  root.topline ();

  self.readline.cur.mode = mode;

  variable
    argv = self.readline.getargv (),
    index = mode != self.readline.cur.mode;

  self.history.add (argv);

  if (any (["shell"] == mode))
    self.readline.executeargv (argv);
  else
    (@self.readline.executeargv[index]) (self, argv);
}
