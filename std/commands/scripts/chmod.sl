() = evalfile ("mode_conversion");
() = evalfile ("modetoint");
() = evalfile ("fswalk");

private variable EXIT_CODE = 0;

private define chmod_it (file, mode)
{
  variable
    strmode,
    st = qualifier ("st", stat_file (file)),
    strcurmode = stat_mode_to_string (st.st_mode),
    cur_mode = modetoint (st.st_mode);

  if (-1 == chmod (file, mode))
    {
    (@print_err) (sprintf (
      "%s: could not change mode bits, ERRNO: %s", file, errno_string (errno)));
    EXIT_CODE = 1;
    }
  else
    {
    strmode = stat_mode_to_string (stat_file (file).st_mode);
    if (cur_mode == mode)
      (@print_out) (sprintf ("mode of `%s' retained as 0%o (%s)",
         file, mode, strmode));
    else
      (@print_out) (sprintf ("mode of `%s' changed from 0%o (%s) to 0%o (%s)",
         file, cur_mode, strcurmode, mode, strmode));
    }
}

private define file_callback (file, st, mode)
{
  if (stat_is ("lnk", st.st_mode))
    return 1;

  chmod_it (file, mode);
  return 1;
}

private define dir_callback (dir, st, mode)
{
  if (NULL == mode)
    return 1;
 
  if (stat_is ("lnk", st.st_mode))
    return 1;

  chmod_it (dir, mode);
  return 1;
}

define main ()
{
  variable
    i,
    fs,
    files,
    strmode,
    directories = NULL,
    mode = NULL,
    recursive = NULL,
    c = cmdopt_new (&_usage);
 
  c.add ("mode", &mode;type = "str");
  c.add ("recursive", &recursive);
  c.add ("directories", &directories);
  c.add ("help", &_usage);
  c.add ("info", &info);

  i = c.process (__argv, 1);

  if (i == __argc)
    {
    (@print_err) (sprintf ("%s: it requires a filename", __argv[0];print_in_msg_line));
    return 1;
    }
 
  if (NULL == mode)
    {
    (@print_err) (sprintf ("%s: --mode was not given", __argv[0];print_in_msg_line));
    return 1;
    }

  mode = mode_conversion (mode);

  if (NULL == mode)
    {
    variable err = ();
    (@print_err) (err);
    return 1;
    }
 
  files = __argv[[i:]];
  files = files[where (strncmp (files, "--", 2))];
 
  _for i (0, length (files) - 1)
    {
    if (-1 == access (files[i], F_OK))
      {
      (@print_err) (sprintf ("%s: No such file", files[i]));
      continue;
      }

    if (isdirectory (files[i]))
      {
      ifnot (NULL == recursive)
        {
        fs = fswalk_new (&dir_callback, &file_callback;
          dargs = {NULL == directories ? NULL : mode}, fargs = {mode});

        fs.walk (files[i]);
        }
      else
        if (stat_is ("lnk", stat_file (files[i]).st_mode))
          continue;
        else
          chmod_it (files[i], mode);

      continue;
      }
 
    if (stat_is ("lnk", stat_file (files[i]).st_mode))
      continue;

    chmod_it (files[i], mode);
    }

  return EXIT_CODE;
}
