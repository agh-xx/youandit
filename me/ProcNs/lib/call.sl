define is_arg (arg, argv)
{
  variable index = wherenot (strncmp (argv, arg, strlen (arg)));
  return length (index) ? index[0] : NULL;
}

define call (_argv)
{
  variable
    i,
    fp,
    pid,
    arg,
    argv = @_argv,
    index,
    stdinr,
    stdinw,
    status,
    retval,
    passwd,
    is_sudo,
    is_fg = 1,
    argv0 = argv[0],
    fexec = SLSH_EXEC,
    args = ["--chdir=", "--execdir=", "--nocl", "--infodir=",
            "--mainfname=", "--msgfname=", "--interactive", "--clear"
           ],
    env =  ["CHDIR", "EXECDIR", "NOWRITECL", "INFODIR",
            "STDOUT", "STDERR", "INTERACTIVE", "CLEAR"];
 
  index = is_arg ("--bg", argv);
  ifnot (NULL == index)
    {
    is_fg = 0;
    argv[index] = NULL;
    argv = argv[wherenot (_isnull (argv))];
    }

  index = is_arg ("--fg", argv);
  ifnot (NULL == index)
    {
    is_fg = 1;
    argv[index] = NULL;
    argv = argv[wherenot (_isnull (argv))];
    }

  _for i (0, length (args) - 1)
    {
    index = is_arg (args[i], argv);
    ifnot (NULL == index)
      {
      if ('=' == argv[index][strlen (args[i]) - 1])
        {
        arg = strtok (argv[index], "=");
        if (strlen (arg[1]))
          env[i] = sprintf ("%s=%s", env[i], arg[1]);
        else
          env[i] = NULL;
        }
      else
        env[i] = sprintf ("%s=1", env[i]);

      ifnot ("--interactive" == args[i])
        {
        argv[index] = NULL;
        argv = argv[wherenot (_isnull (argv))];
        }
      }
    else
      env[i] = NULL;
    }
 
  env = env[wherenot (_isnull (env))];
  if (qualifier_exists ("env"))
    env = [env, qualifier ("env")];

  ifnot (NULL == wherefirst ("INTERACTIVE=1" == env))
    is_fg = 1;
 
  env = [env,
    array_map (String_Type, &sprintf, "%s=%s",
      ["TERM", "ROOTDIR", "SRV_SOCKADDR", "PATH", "HOME", "LANG", "FIFO_ROOT"],
      [getenv ("TERM"), ROOTDIR, SRV_SOCKADDR, getenv ("PATH"), getenv ("HOME"),
       getenv ("LANG"), FIFO_ROOT]),
    array_map (String_Type, &sprintf, "%s=%d",
      ["LINES", "COLUMNS", "ROOT_PID"],
       [LINES, COLUMNS, ROOT_PID]),
       ];

  is_sudo = is_arg ("--sudo", argv);

  ifnot (NULL == is_sudo)
    {
    if (NULL == SUDO_EXEC)
      {
      srv->send_msg ("sudo hasn't been found in PATH", -1);
      throw GotoPrompt;
      }

    argv[is_sudo] = NULL;
    argv = argv[wherenot (_isnull (argv))];
    passwd = root.lib.getpasswd ();

    ifnot (strlen (passwd))
      {
      srv->send_msg ("Password is an empty string. Aborting ...", -1);
      throw GotoPrompt;
      }
 
    retval = root.lib.validate_passwd (passwd);
    if (NULL == retval)
      {
      srv->send_msg ("This is not a valid password", -1);
      throw GotoPrompt;
      }
    }
  else
    is_sudo = 0;

  () = sock->send_str_ar_get_bit (PROC_SOCKET, argv);
  () = sock->send_str_ar_get_bit (PROC_SOCKET, env);
  () = sock->send_int_ar_get_bit (PROC_SOCKET, [is_fg, is_sudo, LINES, COLUMNS]);

  if (is_sudo)
    () = sock->send_str_get_bit (PROC_SOCKET, passwd);

  status = sock->send_bit_get_int (PROC_SOCKET, 0);

  return status;
}
