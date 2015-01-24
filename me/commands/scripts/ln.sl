() = evalfile ("ln");

define main ()
{
  variable
    i,
    source,
    dest,
    opts = struct
      {
      backup = NULL,
      suffix = "~",
      interactive = NULL,
      force = NULL,
      symbolic = NULL,
      nodereference = NULL,
      },
    c = cmdopt_new (&_usage);

  c.add ("backup", &opts.backup);
  c.add ("suffix", &opts.suffix;type="string");
  c.add ("i|interactive", &opts.interactive);
  c.add ("s|symbolic", &opts.symbolic);
  c.add ("no-dereference", &opts.nodereference);
  c.add ("force", &opts.force);
  c.add ("help", &_usage);
  c.add ("info", &info);

  i = c.process (__argv, 1);

  if (i + 2 > __argc)
    {
    (@print_err) (sprintf ("%s: argument is required", __argv[0]));
    return 1;
    }

  source = eval_dir (__argv[i];dont_change);
  dest = eval_dir (__argv[i+1];dont_change);
 
 return ln (source, dest, opts);
}
