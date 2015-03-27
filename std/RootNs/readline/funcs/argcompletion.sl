define main (self)
{
  if (load ("hl", "hl_item", 1;form_ar = 0) == -1)
    {
    variable err = ();
    throw ParseError, strjoin (err, "\n");
    }

  variable
    i,
    col,
    bar,
    len,
    tmp,
    type,
    desc,
    chr = 0,
    whatdir = "cd" == self.cur.argv[0]
      ? COREDIR
      :  NULL != wherefirst (self.cur.argv[0] == CORECOMS)
        ? COREDIR
        : NULL != wherefirst (self.cur.argv[0] == USRCOMS)
          ? USRCOMMANDSDIR
          : PERSCOMMANDSDIR,
    file = qualifier ("file", sprintf ("%s/../info/%s/args.txt", whatdir, self.cur.argv[0])),
    header = qualifier ("header", sprintf ("ARG %s COMPLETION", strup (self.cur.mode))),
    args = qualifier ("args"),
    arg = qualifier ("arg", self.cur.argv[self.cur.index]),
    base = qualifier ("base", strjoin (self.cur.argv[[:self.cur.index - 1]], " ")),
    baselen = strlen (base) + 1,
    ar = NULL == args
      ? access (file, F_OK)
        ? NULL
        : readfile (file)
      : args;

  if (NULL == ar)
    throw Return, " ", 0;

  self.cur.col = baselen + ("." != arg ? strlen (arg) : 0) + 1;

  len = length (ar),
  type = String_Type[len],
  desc = String_Type[len];

  ifnot (len)
    throw Return, " ", 0;

  args = String_Type[len];

  _for i (0, len - 1)
    if (3 != sscanf (ar[i], "%s %s %[ -ώ]", &args[i], &type[i], &desc[i]))
      throw Return, " ", 0;

  if (1 == len)
    {
    arg = strchop (args[0], ',', 0);
    self.cur.argv[self.cur.index] = 1 < length (arg) ? arg[-1] : arg[0];
    self.cur.col = baselen + strlen (self.cur.argv[self.cur.index]) + 1;
    self.parse_args ();

    if ("void" != type[0])
      if (any (["int", "string"] == type[0]))
        {
        CW.drawwind (;dont_reread);
        root.topline ();
        srv->send_msg_and_refresh (sprintf ("\ttype should be %s", type[0]), 0);
        }
      else if ("pcrepattern" == type[0] || "--pat=" == arg[0])
        {
        srv->send_msg (sprintf ("\ttype should be a %s [tab for completion in the top line]", type[0]), 0);
        self.my_prompt ();

        tmp = qualifier ("pat", "");
 
        self.getpattern (&tmp;;__qualifiers ());
 
        if ("" == tmp)
          srv->send_msg ("WARNING: pattern is an empty string", 1);
        else
          {
          self.cur.argv[self.cur.index] += tmp;
          self.cur.col = baselen + strlen (self.cur.argv[self.cur.index]) + 1;
          self.parse_args ();
          }
        }
      else if (any (["filename", "directory"] == type[0]))
        {
        srv->send_msg (sprintf ("\ttype should be a %s [tab for completion in the top line]", type[0]), 0);
        self.my_prompt ();

        tmp = qualifier ("pat", "");

        if ("directory" == type[0])
          () = self.filenamecompletiontoprow (&tmp;only_dirs);
        else
          () = self.filenamecompletiontoprow (&tmp);

        self.cur.argv[self.cur.index] += tmp;
        self.cur.col = baselen + strlen (self.cur.argv[self.cur.index]) + 1;
        self.parse_args ();
        }
 
    throw Return, " ", 0;
    }

  bar = array_sort (args);
  args = args[bar];
  type = type[bar];
  desc = desc[bar];

  forever
    {
    ifnot (strlen (arg))
      ifnot (qualifier_exists ("accept_ws"))
        {
        CW.drawwind (;dont_reread);
        root.topline ();
        throw Return, " ", 0;
        }

    ar = where (array_map (Char_Type, &string_match, args, sprintf ("^%s", arg), 1));

    ifnot (length (ar))
      {
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", 0;
      }

    if (1 == length (ar))
      {
      arg = strchop (args[ar[0]], ',', 0);
      self.cur.argv[self.cur.index] = 1 < length (arg) ? arg[-1] : arg[0];
      self.cur.col = baselen + strlen (self.cur.argv[self.cur.index]) + 1;
      self.parse_args ();

      if ("void" != type[ar[0]])
        if (any (["int", "string"] == type[ar[0]]))
          {
          CW.drawwind (;dont_reread);
          root.topline ();
          srv->send_msg_and_refresh (sprintf ("\ttype should be %s", type[ar[0]]), 0);
          }
        else if ("pcrepattern" == type[ar[0]] || "--pat=" == arg[0])
          {
          srv->send_msg (sprintf ("\ttype should be a %s [tab for completion in the top line]", type[ar[0]]), 0);
          self.my_prompt ();

          tmp = qualifier ("pat", "");
 
          self.getpattern (&tmp;;__qualifiers ());
 
          if ("" == tmp)
            srv->send_msg ("WARNING: pattern is an empty string", 1);
          else
            {
            self.cur.argv[self.cur.index] += tmp;
            self.cur.col = baselen + strlen (self.cur.argv[self.cur.index]) + 1;
            self.parse_args ();
            }
          }
        else if (any (["filename", "directory"] == type[ar[0]]))
          {
          srv->send_msg (sprintf ("\ttype should be a %s [tab for completion in the top line]", type[ar[0]]), 0);
          self.my_prompt ();

          tmp = qualifier ("pat", "");
 
          if ("directory" == type[ar[0]])
            () = self.filenamecompletiontoprow (&tmp;only_dirs);
          else
            () = self.filenamecompletiontoprow (&tmp);

          self.cur.argv[self.cur.index] += tmp;
          self.cur.col = baselen + strlen (self.cur.argv[self.cur.index]) + 1;
          self.parse_args ();
          }

      throw Return, " ", 0;
      }
 
    ifnot (any (keys->cmap.backspace == chr))
      {
      variable b = "";
      self.firstindices (&b, args[ar], arg);
      if (strlen (b))
        arg = b;
      }

    self.cur.col = baselen + strlen (arg) + 1;
    self.cur.argv[self.cur.index] = arg;
    self.parse_args ();
    self.my_prompt ();

    ar = array_map (String_Type, &sprintf, "%-17s %s", args[ar], desc[ar]);

    tmp = "";
    chr = hl->hlitem (self, ar, arg, self.cur.col, &tmp;goto_prompt);
 
    if (' ' == chr)
      {
      ar = strchop (tmp, ' ', 0);
      arg = ar[0];
      self.cur.argv[self.cur.index] = arg;
      self.cur.col = baselen + strlen (arg) + 1;
      self.parse_args ();
 
      i = wherefirst (arg == args);

      if ("void" == type[i])
        {
        CW.drawwind (;dont_reread);
        root.topline ();
        }
      else
        if (any (["int", "string"] == type[i]))
          {
          CW.drawwind (;dont_reread);
          root.topline ();
          srv->send_msg_and_refresh (sprintf ("\ttype should be %s", type[i]), 0);
          }
        else if ("pcrepattern" == type[i] || "--pat=" == arg)
          {
          srv->send_msg (sprintf ("\ttype should be a %s [tab for completion in the top line]", type[i]), 0);
          self.my_prompt ();

          tmp = qualifier ("pat", "");
 
          self.getpattern (&tmp;;__qualifiers ());
          if ("" == tmp)
            srv->send_msg ("WARNING: pattern is an empty string", 1);
          else
            {
            self.cur.argv[self.cur.index] += tmp;
            self.cur.col = baselen + strlen (self.cur.argv[self.cur.index]) + 1;
            self.parse_args ();
            }
          }
        else if (any (["filename", "directory"] == type[i]))
          {
          srv->send_msg (sprintf ("\ttype should be a %s [tab for completion in the top line]", type[i]), 0);
          self.my_prompt ();

          tmp = qualifier ("pat", "");

          if ("directory" == type[i])
            () = self.filenamecompletiontoprow (&tmp;only_dirs);
          else
            () = self.filenamecompletiontoprow (&tmp);

          self.cur.argv[self.cur.index] += tmp;
          self.cur.col = baselen + strlen (self.cur.argv[self.cur.index]) + 1;
          self.parse_args ();
          }

      throw Return, " ", 0;
      }

    if (any (keys->cmap.backspace == chr)
        && self.cur.col > baselen + 1)
      {
      CW.drawwind (;dont_reread);
      root.topline ();

      arg = substr (arg, 1, strlen (arg) - 1);
      self.cur.argv[self.cur.index] = arg;
      self.cur.col = baselen + strlen (arg) + 1;
      self.parse_args ();
      self.my_prompt ();
      continue;
      }

    if (' ' == chr)
      {
      CW.drawwind (;dont_reread);
      root.topline ();

      self.cur.argv[self.cur.index] = arg;
      self.cur.col = baselen + strlen (arg) + 1;
      self.parse_args ();

      if (length (where (array_map (Char_Type, &string_match, args, arg)))
          && strlen (arg) > 1)
        throw Return, " ", 0;

      self.my_prompt ();
      continue;
      }

    if ('\r' == chr || 0 == (' ' < chr <= '~'))
      {
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", '\r' == chr;
      }

    if ("." == arg && qualifier_exists ("base"))
      arg = char (chr);
    else
      arg += char (chr);

    CW.drawwind (;dont_reread);
    root.topline ();
    self.cur.argv[self.cur.index] = arg;
    self.cur.col = baselen + strlen (self.cur.argv[self.cur.index]) + 1;
    self.parse_args ();
    self.my_prompt ();
    }
}
