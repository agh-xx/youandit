define main (self)
{
  if (any (keys->cmap.histup == self.cur.chr))
    {
    if (1 == self.historycompletion (;;__qualifiers ()))
      throw Return, " ", -1;

    self.cur.col = 1 + strlen (self.cur.line);
    self.parse_args ();
    self.my_prompt ();

    throw Return, " ", 1;
    }

  if (any (keys->cmap.lastcmp == self.cur.chr))
    {
    if (1 == self.lastcomponentcompletion ())
      throw Return, " ", -1;

    self.parse_args ();
    self.my_prompt ();
    throw Return, " ", 1;
    }

  if ('\r' == self.cur.chr)
    {
    CW.drawwind (;dont_reread);
    root.topline ();
    self.my_prompt ();
    throw Return, " ", -1;
    }

  if (033 == self.cur.chr)
    {
    self.cur.argv  = [""];
    throw Return, " ", -1;
    }

  self.routine ();

  self.parse_args ();

  self.my_prompt ();

  throw Return, " ", 0;
}
