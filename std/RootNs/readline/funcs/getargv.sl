define main (self)
{
  forever
    {
    if (1 < self.cur.state)
      CW.writeinfolines ();
 
    if (2 < self.cur.state)
      CW.drawframe (CW.frames - 1);

    if (1 < self.cur.state)
      srv->refresh ();

    self.cur.state = 1;

    srv->write_prompt (NULL, 1);
 
    if (NULL == self.lastcur)
      if (List_Type == typeof (self.readline))
        (@self.readline[0]) (self);
      else
        self.readline ();
    else
      {
      self.cur = @self.lastcur;
      self.lastcur = NULL;
 
      self.my_prompt ();

      if (List_Type == typeof (self.readline))
        (@self.readline[0]) (self;dont_init);
      else
        self.readline (;dont_init);
      }

    if (NULL == self.cur.argv)
      {
      root.topline ();
      continue;
      }

    ifnot (strlen (self.cur.argv[-1]))
      self.cur.argv = self.cur.argv[[:-2]];
 
    ifnot (length (self.cur.argv))
      {
      root.topline ();
      continue;
      }

    break;
    }
 
  % limited glob * support
  % supported patterns are foo* or *foo or *
  variable
    i,
    ar,
    dirname,
    basename,
    glob = 0,
    args = self.cur.argv[[1:]],
    argv = [self.cur.argv[0]];

  _for i (0, length (args) - 1)
    {
    if ('-' != args[i][0])
      {
      if ('*' == args[i][-1])
        {
        glob = 1;
        basename = path_basename (args[i]);
        dirname = eval_dir (path_dirname (args[i]));
        ar = listdir (dirname);

        if ("*" != basename)
          ar = ar[wherenot (array_map (Char_Type, &strncmp, ar, basename,
            strlen (basename) - 1))];

        ar = ar[array_sort (ar)];

        argv = [argv, array_map (String_Type, &path_concat, dirname, ar)];
        }
      else if (string_match (args[i], "*"))
        {
        glob = 1;
        basename = path_basename (args[i])[[1:]];
        dirname = eval_dir (path_dirname (args[i]));
        ar = listdir (dirname);

        ar = ar[where (array_map (Integer_Type, &string_match, ar,
              sprintf ("%s$", basename) ))];

        ar = ar[array_sort (ar)];

        argv = [argv, array_map (String_Type, &path_concat, dirname, ar)];
        }
      else
        argv = [argv, args[i]];
      }
    else
      argv = [argv, args[i]];
    }

  if (glob && 0 == length (argv[[1:]]))
    {
    srv->send_msg ("No matches found", 1);
    CW.gotoprompt ();
    }

  list_insert (self.arg_last_component, argv[-1]);

  if (10 < length (self.arg_last_component))
    self.arg_last_component = self.arg_last_component[[:9]];

  throw Return, " ", argv;
}
