public variable STACK = NULL;

define main ()
{
  variable
    err,
    retval,
    st_cwd,
    st_new,
    stack_len,
    cwd = getcwd (),
    stack_maxlen = 9,
    dir = _NARGS > 1 ? () : NULL,
    stackfile = sprintf ("%s/../info/cd/stackfile.sl", COREDIR),
    self = ();

  ifnot (access (stackfile + "c", F_OK))
    () = evalfile (stackfile + "c");
  else if (0 == access (stackfile, F_OK))
    () = evalfile (stackfile);

  ifnot (NULL == dir)
    if ('-' == dir[0])
      if (strlen (dir) - 1)
        if (any (['0':'9'] == substr (dir, 2, -1)[0]))
          if (NULL != STACK)
            if (atoi (substr (dir, 2, -1)) < length (STACK))
              dir = STACK[atoi (substr (dir, 2, -1))];

  if (NULL == dir)
    dir = "~";

  if ("-" == dir)
    ifnot (NULL == STACK)
      dir = STACK[-1];
    else
      {
      srv->send_msg ("No other entry on the stack", 1);
      throw GotoPrompt;
      }

  dir = eval_dir (dir);

  st_new = stat_file (dir);

  ifnot (isdirectory (dir;st = st_new))
    {
    srv->send_msg (sprintf ("%s: doesn't exist", dir), -1);
    throw GotoPrompt;
    }

  st_cwd = stat_file (cwd);

  if (st_cwd.st_ino == st_new.st_ino && st_cwd.st_dev == st_new.st_dev)
    {
    srv->send_msg ("current directory is the same with the argument", -1);
    throw GotoPrompt;
    }

  if (-1 == chdir (dir))
    {
    srv->send_msg (sprintf ("chdir failed: %s", errno_string (errno)), -1);
    throw GotoPrompt;
    }
 
  () = sock->send_str_ar_get_bit (PROC_SOCKET, ["cd", dir]);
  retval = sock->send_bit_get_int (PROC_SOCKET, 0);

  if (retval)
    {
    err = sock->send_bit_get_str (PROC_SOCKET, 0);
    srv->send_msg (sprintf ("chdir failed: %s", err), -1);
    throw GotoPrompt;
    }

  if (NULL == STACK)
    STACK = {cwd};
  else
    {
    stack_len = length (STACK);
    if (stack_len == stack_maxlen)
      STACK = list_concat (STACK[[1:]], {cwd});
    else
      list_append (STACK, cwd);
    }

  writefile (sprintf ("STACK = {\n\"%s\"\n};",
    strjoin (list_to_array (STACK), "\",\n\"")), stackfile);

  byte_compile_file (stackfile, 0);

  STACK = list_to_array (STACK);
  STACK = array_map (String_Type, &sprintf, "\-%d void  %s",  [0:length(STACK)-1:1],
     STACK);

  writefile (["--help void Show help", "--info void Show information", STACK],
     sprintf ("%s/../info/cd/args.txt", COREDIR));
 
  CW.dir = dir;
 
  srv->send_msg (sprintf ("current dir is: %s", dir), 0);

  throw GotoPrompt;
}
