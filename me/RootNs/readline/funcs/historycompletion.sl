define main (self)
{
  variable
    i,
    ar,
    col,
    len,
    chr,
    index = 0,
    histar = qualifier ("histar", CW.history.list),
    header = qualifier ("header", "HISTORY COMPLETION");

  forever
    {
    ar = strlen (self.cur.line)
      ? histar[where (array_map (Char_Type, &string_match,
          histar, strjoin (self.cur.argv, "||"), 1))]
      : histar;

    ifnot (length (ar))
      throw Return, " ", 0;

    ifnot (index + 1)
      index = length (ar) - 1;

    if (length (ar) <= index)
      index = 0;

    len = 1;

    i = 0;
    while ((i + 1) * COLUMNS <= self.cur.col)
      i++;

    col = self.cur.col - (COLUMNS * i);

    () = root.lib.printout ([strjoin (strtok (ar[index], "||"), " ")], col, &len;
      header = header,
      lines = LINES - (strlen (self.cur.line) / COLUMNS),
      row = PROMPTROW - (strlen (self.cur.line) / COLUMNS) + i);

    index ++;

    self.my_prompt ();

    chr = input->en_getch ();

    if (any (keys->cmap.histup == chr))
      continue;
 
    if (any (keys->cmap.histdown == chr))
      {
      index --;
      continue;
      }

    if (any (keys->cmap.backspace == chr) && self.cur.col > 1)
      {
      self.delete_at ();
      self.parse_args ();
      self.my_prompt ();
      continue;
      }

    if (' ' == chr)
      {
      self.cur.argv = strtok (ar[index-1], "||");
      self.cur.col = strlen (strjoin (self.cur.argv, " ")) + 1;
      self.parse_args ();
      ifnot (qualifier_exists ("dont_draw"))
        {
        CW.drawwind (;dont_reread);
        root.topline ();
        }
      throw Return, " ", 0;
      }

    if ('\r' == chr)
      {
      self.cur.argv = strtok (ar[index-1], "||");
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", 1;
      }

    ifnot (' ' < chr <= '~')
      {
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", 0;
      }
 
    self.insert_at (;chr = chr);
    self.parse_args ();
    self.my_prompt ();
    }
}
