ineed ("extract");

define main ()
{
  variable
    i,
    files,
    dir = NULL,
    strip = NULL,
    exit_code = 0,
    noverbose = NULL,
    c = cmdopt_new (&_usage);

  c.add ("no-verbose", &noverbose);
  c.add ("to-dir", &dir;type = "string");
  c.add ("strip", &strip);
  c.add ("help", &_usage);
  c.add ("info", &info);

  i = c.process (__argv, 1);

  if (i == __argc)
    {
    (@print_err) (sprintf ("%s: additional argument is required", __argv[0]));
    return 1;
    }

  files = __argv[[i:]];
  files = files[where (strncmp (files, "--", 2))];

  noverbose = NULL == noverbose ? "1" : "0";
 
  dir = NULL == dir ? getcwd () : dir;

  exit_code = array_map (Integer_Type, &extract, files, noverbose, dir, strip);
 
  if (any (exit_code))
    return 1;

  return 0;
}
