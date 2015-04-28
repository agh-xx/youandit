define main ()
{
  variable
    i,
    pid,
    command,
    linenr = 0,
    fname = NULL,
    editor = NULL,
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
 
  variable p = proc->init (0, 0, 1);
  
  variable status = p.execv (command, NULL);

  if (NULL == status)
    {
    (@print_err) (sprintf ("Couldn't fork %s", editor));
    return 1;
    }
 
  if (status.exit_status)
    if (length (p.stderr.out))
      array_map (Void_Type, print_err, p.stderr.out);

  return status.exit_status;
}
