() = evalfile ("uname");

define main ()
{
  variable
    args = {},
    _all = NULL,
    i,
    c = cmdopt_new (&_usage);

  c.add ("kernel-name", &args;type="string", optional="s", append);
  c.add ("kernel-release", &args;type="string", optional="r", append);
  c.add ("kernel-version", &args;type="string", optional="v", append);
  c.add ("machine", &args;type="string", optional="m", append);
  c.add ("processor", &args;type="string", optional="p", append);
  c.add ("nodename", &args;type="string", optional="n", append);
  c.add ("all", &_all);
  c.add ("help", &_usage);
  c.add ("info", &info);

  i = c.process (__argv, 1);

  ifnot (length (args))
    args = {"s"};

  ifnot (NULL == _all)
    args = {"s", "n", "r", "v", "m", "p"};

  args = strjoin (list_to_array (args));

  (@print_norm) (_uname (args));

  return 0;
}
