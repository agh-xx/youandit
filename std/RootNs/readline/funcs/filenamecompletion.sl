define main (self, start)
{
  if (load ("hl", "hl_item", 1) == -1)
    {
    variable err = ();
    throw ParseError, strjoin (err, "\n");
    }

  variable
    ar,
    st,
    str,
    tmp,
    file,
    isdir,
    retval,
    chr = 0,
    pat = "";

 if (' ' != start[0])
    {
    tmp = self.appendslash (start);
    if ("/" == tmp)
      {
      self.cur.argv[self.cur.index] += tmp;
      self.cur.col += strlen (tmp);
      self.parse_args ();
      self.my_prompt ();
      }
    }

  forever
    {
    pat = "";
    tmp = strlen (self.cur.line) ? self.cur.argv[self.cur.index] : "";

    file = ' ' == (self.cur.line)[-1] ? getcwd () :
      sprintf ("%s%s", eval_dir (tmp;dont_change), self.appendslash (tmp));
 
    if (2 < strlen (file))
      if ("./" == file[[0:1]] && 0 == strlen (self.cur.argv[self.cur.index]))
        file = file[[2:]];
 
    if (access (file, F_OK) || '/' != (self.cur.line)[-1])
      {
      pat = path_basename (file);
      file = path_dirname (file);
      }
 
    retval = 0;
    ar = self.listdirectory (&retval, file, pat, strlen (pat));

    if (-1 == retval || 0 == length (ar))
      {
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", 0;
      }

    ifnot (1 == length (ar))
      {
      str = "";
      self.firstindices (&str, ar, pat);

      if (strlen (str))
        {
        str = path_concat (file, str);
        self.cur.argv[self.cur.index] = sprintf ("%s%s", str, self.appendslash (str));
        if ("./" == self.cur.argv[self.cur.index][[0:1]])
          self.cur.argv[self.cur.index] = substr (self.cur.argv[self.cur.index], 3, -1);

        self.cur.col = strlen (strjoin (self.cur.argv[[:self.cur.index]], " ")) + 1;
        self.parse_args ();
        self.my_prompt ();
        }
      }

    tmp = "";
    chr = hl->hlitem (self, append_dir_indicator (file, ar), file, self.cur.col, &tmp;
      goto_prompt);
 
    if (033 == chr)
      {
      CW.drawwind (;dont_reread);
      root.topline ();

      self.cur.col = strlen (strjoin (self.cur.argv[[:self.cur.index]], " ")) + 1;
      self.parse_args ();

      throw Return, " ", 0;
      }

    if (' ' == chr)
      {
      file = path_concat (file, tmp[-1] == '/' ? substr (tmp, 1, strlen (tmp) - 1) : tmp);
      st = lstat_file (file);
 
      ifnot (NULL == st)  % THIS SHOULD NOT FAIL
        {
        isdir = stat_is ("dir", st.st_mode);
        self.cur.argv[self.cur.index] = sprintf ("%s%s", file, isdir ? "/" : "");

        if ("./" == self.cur.argv[self.cur.index][[0:1]])
          self.cur.argv[self.cur.index] = substr (self.cur.argv[self.cur.index], 3, -1);
        self.cur.col = strlen (strjoin (self.cur.argv[[:self.cur.index]], " ")) + 1;
        self.parse_args ();
 
        if (isdir)
          {
          self.my_prompt ();
          continue;
          }
        }
      }
 
    if (any (keys->cmap.backspace == chr) && strlen (self.cur.line))
      {
      self.delete_at ();
      self.parse_args ();
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", 0;
      }

    if (' ' == chr)
      if (length (ar))
        {
        ar = array_map (String_Type, &path_concat, file, ar);
        ar = ar[wherenot (array_map (Char_Type, &strncmp, ar,
          self.cur.argv[self.cur.index] + " ", strlen (self.cur.argv[self.cur.index]) + 1))];

        if (length (ar))
          {
          self.cur.argv[self.cur.index] = sprintf ("%s%s", ar[0], self.appendslash (ar[0]));
          self.cur.col = strlen (strjoin (self.cur.argv[[:self.cur.index]], " ")) + 1;
          self.parse_args ();
          }
        }
      else
        {
        CW.drawwind (;dont_reread);
        root.topline ();
        throw Return, " ", 0;
        }

    if ('\r' == chr || 0 == chr || 0 == (' ' < chr <= '~'))
      {
      CW.drawwind (;dont_reread);
      root.topline ();
      throw Return, " ", '\r' == chr;
      }

    self.insert_at (;chr = chr);

    if (strlen (self.appendslash (self.cur.argv[self.cur.index])))
      self.insert_at (;chr = '/');
 
    self.parse_args ();
    self.my_prompt ();
    }
}
