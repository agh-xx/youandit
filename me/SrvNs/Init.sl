
SRV_PID = fork ();

if (-1 == SRV_PID)
  root->exit_me (1, sprintf ("failed to create slsmg process\n%s\n",
      errno_string (errno)));

if ((0 == SRV_PID) && -1 == execve (SLSH_EXEC,
    [SLSH_EXEC, sprintf ("%s/Srv.slc", path_dirname (__FILE__))],
    array_map (String_Type, &sprintf, "%s=%s",
    [
    "STDNS",
    "USRNS",
    "SRV_SOCKADDR",
    "TERM",
    "LANG",
    "LOAD_PATH",
    "IMPORT_PATH"
    ],
    [
    STDNS,
    USRNS,
    SRV_SOCKADDR,
    getenv ("TERM"),
    getenv ("LANG"),
    get_slang_load_path (),
    get_import_module_path ()
    ]
    )))
  root->exit_me (1, sprintf ("failed to create slsmg process: %s",
      errno_string (errno)));

if (any ([-1, 0] == pid_status (SRV_PID)))
  root->exit_me (1, NULL);
