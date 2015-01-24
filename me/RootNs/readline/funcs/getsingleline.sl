define main (self)
{
  self.cur.line = "";
  self.cur.col = 1;
  self.cur.chr = 0;
  self.cur.argv = [""];
  self.cur.index = 0;

  forever
    {
    self.cur.chr = (@getch);

    if (any (keys->cmap.changelang == self.cur.chr))
      {
      root.func.call ("change_getch");
      self.my_prompt (;;__qualifiers ());
      continue;
      }

    if (1 == self.cur.col)
      srv->send_msg ("", 0);
 
  if (any (keys->cmap.histup == self.cur.chr))
    {
    if (1 == self.historycompletion (;;__qualifiers ()))
      {
      ifnot (qualifier_exists ("dont_draw"))
        CW.drawwind (;dont_reread);

      root.topline ();
      throw Break;
      }

    self.cur.col = 1 + strlen (self.cur.line);
    self.my_prompt (;;__qualifiers ());
    continue;
    }

    if (any (keys->cmap.fname == self.cur.chr))
      {
      variable
        start = ' ' == self.cur.line[-1] ? " " : self.cur.argv[-1];

      () = self.filenamecompletion (start);
      self.cur.col = 1 + strlen (self.cur.line);
      self.my_prompt (;;__qualifiers ());
      continue;
      }

    if ('\r' == self.cur.chr)
      {
      ifnot (qualifier_exists ("dont_draw"))
        CW.drawwind (;dont_reread);
      root.topline ();
      throw Break;
      }

    if (033 == self.cur.chr)
      {
      self.cur.argv = NULL;
      throw Break;
      }

    self.routine (;accept_ws);

    self.parse_args ();

    self.my_prompt (;;__qualifiers ());
    }
}
