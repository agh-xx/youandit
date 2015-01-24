() = evalfile ("mode_conversion");

define main ()
{
  variable
    files,
    retval,
    exit_code = 0,
    mode = NULL,
    i,
    c = cmdopt_new (&_usage);

  c.add ("mode", &mode;type = "str");
  c.add ("help", &_usage);
  c.add ("info", &info);

  i = c.process (__argv, 1);

  if (__argc == i)
    {
    (@print_err) (sprintf ("%s: a fifo name is required as argument", __argv[0]));
    return 1;
    }

  files = __argv[[i:]];
  files = files[where (strncmp (files, "--", 2))];

  ifnot (NULL == mode)
    {
    mode = mode_conversion (mode);
    if (NULL == mode)
      {
      variable err = ();
      (@print_err) (err);
      return 1;
      }
    }
  else
    mode = 420;

  _for i (0, length (files) - 1)
    {
    retval = mkfifo (files[i], mode);

    if (-1 == retval)
      {
      (@print_err) (sprintf ("Couldn't create fifo: %s", errno_string (errno)));
      exit_code = -1;
      }
    else
      (@print_norm) (sprintf ("%s: fifo created, with access %s", files[i],
      stat_mode_to_string (stat_file (files[i]).st_mode)));
    }

  return exit_code;
}
