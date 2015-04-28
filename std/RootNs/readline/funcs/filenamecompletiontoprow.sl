define main (self, fname)
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

  if (' ' != (@fname)[0])
    @fname += self.appendslash (@fname);

  forever
    {
    pat = "";
    tmp = strlen (@fname) ? @fname : "";

    file = ' ' == (@fname)[-1] ? getcwd () :
      sprintf ("%s%s", eval_dir (tmp;dont_change), self.appendslash (tmp));
 
    if (2 < strlen (file))
      if ("./" == file[[0:1]] && 0 == strlen (@fname))
        file = file[[2:]];
 
    if (access (file, F_OK) || '/' != (@fname)[-1])
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
 
    if (qualifier_exists ("only_dirs") && length (ar))
      ar = ar[where (array_map (Char_Type, &isdirectory,
        array_map (String_Type, &path_concat, file, ar)))];

    ifnot (length (ar))
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
        @fname = sprintf ("%s%s", str, self.appendslash (str));
        if ("./" == (@fname)[[0:1]])
          @fname = substr (@fname, 3, -1);
        }
      }

    tmp = "";
    chr = hl->hlitem (self, append_dir_indicator (file, ar), file, self.cur.col, &tmp;
      header = @fname, goto_prompt);
 
    if (033 == chr)
      {
      CW.drawwind (;dont_reread);
      root.topline ();

      throw Return, " ", 0;
      }

    if (' ' == chr)
      {
      file = path_concat (file, tmp[-1] == '/' ? substr (tmp, 1, strlen (tmp) -1) : tmp);
      st = stat_file (file);

      ifnot (NULL == st)  % THIS SHOULD NOT FAIL
        {
        isdir = stat_is ("dir", st.st_mode);
        @fname = sprintf ("%s%s", file, isdir ? "/" : "");
        if ("./" == (@fname)[[0:1]])
          @fname = substr (@fname, 3, -1);
 
        if (isdir)
          continue;
        }
      }
 
    if (any (keys->cmap.backspace == chr) && strlen (@fname))
      {
      @fname = substr (@fname, 1, strlen (@fname) - 1);
      continue;
      }

    if (' ' == chr)
      if (length (ar))
        {
        ar = array_map (String_Type, &path_concat, file, ar);
        ar = ar[wherenot (array_map (Char_Type, &strncmp, ar,
          @fname + " ", strlen (@fname) + 1))];
        if (length (ar))
          @fname = sprintf ("%s%s", ar[0], self.appendslash (ar[0]));
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
 
    @fname += char (chr);
    @fname += self.appendslash (@fname);
    }
}
