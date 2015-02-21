define main (self, commands)
{
  variable
    i,
    ar,
    str,
    col,
    len,
    fmt,
    bar,
    chr,
    tmp,
    help,
    indices,
    orighelp = qualifier ("help"),
    header = qualifier ("header", "command:");

  if (load ("hl", "hl_item", 1;form_ar = NULL == orighelp ? 1 : 0) == -1)
    {
    variable err = ();
    throw ParseError, strjoin (err, "\n");
    }
 
  forever
    {
    indices = strlen (self.cur.argv[0])
      ? wherenot (strncmp (commands, self.cur.argv[0], strlen (self.cur.argv[0])))
      : [0:length (commands) - 1];

    ar = commands[[indices]];

    ifnot (length (ar))
      {
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", 0;
      }

    if (1 == length (ar) && 0 == qualifier_exists ("accept_one_len"))
      {
      CW.drawwind (;dont_reread);
      root.topline ();
      self.cur.argv[0] = ar[0];
      self.cur.col = strlen (ar[0]) + 1;
      self.parse_args ();
      throw Return, " ", 0;
      }

    ifnot (NULL == orighelp)
      help = orighelp[[indices]];
 
    str = "";
    self.firstindices (&str, ar, self.cur.argv[0]);
 
    if (strlen (str))
      {
      self.cur.argv[0] = str;
      self.cur.col = strlen (str) + 1;
      self.parse_args ();
      self.my_prompt ();
      }

    bar = @ar;

    ifnot (NULL == orighelp)
      {
      fmt = sprintf ("%%-%ds  %%s", max (strlen (bar)));
      bar = array_map (String_Type, &sprintf, fmt, bar, help);
      }
 
    tmp = "";
    chr = hl->hlitem (self, bar, self.cur.argv[0], self.cur.col, &tmp;goto_prompt);

    if (' ' == chr)
      {
      CW.drawwind (;dont_reread);
      root.topline ();

      self.cur.argv[self.cur.index] = strchop (tmp, ' ', 0)[0];
      self.cur.col = strlen (self.cur.argv[0]) + 1;
      self.parse_args ();

      throw Return, " ", 0;
      }

    if (any (keys->cmap.backspace == chr) && self.cur.col > 1)
      {
      self.delete_at ();
      self.parse_args ();
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", 0;
      }
 
    if (033 == chr && qualifier_exists ("return_on_esc"))
      return chr;

    if (any ([' ', '\r'] == chr) || 0 == ('!' <= chr <= 'z'))
      {
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", '\r' == chr;
      }

    self.cur.argv[0] += char (chr);

    self.cur.col = strlen (self.cur.argv[0]) + 1;
    self.parse_args ();
    self.my_prompt ();
    }
}
