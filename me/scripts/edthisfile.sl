define main ()
{
  variable
    fname = NULL,
    editor = NULL,
    linenr = 0,
    command,
    i,
    status,
    pid,
    c = cmdopt_new (&_usage);

  c.add ("editor", &editor;type="string");
  c.add ("fname", &fname;type="string");
  c.add ("linenr", &linenr;type="int");
  c.add ("help", &_usage);
  c.add ("info", &info);
 
  i = c.process (__argv, 1);

  if (NULL == editor)
    {
    (@print_err) ("--editor= option is missing";print_in_msg_line);
    return 1;
    }

  if (NULL == fname)
    {
    (@print_err) ("--fname= option is missing";print_in_msg_line);
    return 1;
    }

  if (any (["vim", "jed"] == path_basename (editor)))
    command = [editor, sprintf ("+%d", linenr), fname];
  else
    command = [editor, fname];
 
  variable p = @init_proc (0, 0, 1, command);

  if (-1 == sysproc (p))
    {
    (@print_err) (sprintf ("Couldn't fork %s", editor));
    return 1;
    }
 
  if (p.status.exit_status)
    if (length (p.stderr.ar))
      array_map (Void_Type, print_err, p.stderr.ar);

  return p.status.exit_status;
}
