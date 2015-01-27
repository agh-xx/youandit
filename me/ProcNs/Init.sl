PROC_PID = fork ();

if (-1 == PROC_PID)
  root->exit_me (1, sprintf ("failed to create proc process\n%s\n",
      errno_string (errno)));

if ((0 == PROC_PID) && -1 == execve (SLSH_EXEC,
    [SLSH_EXEC, sprintf ("%s/Srv.slc", path_dirname (__FILE__))],
    [
    array_map (String_Type, &sprintf, "%s=%s",
    [
    "MSGFILE",
    "ROOTDIR",
    "SLSH_EXEC",
    "FIFO_ROOT",
    "SRV_SOCKADDR",
    "PROC_SOCKADDR",
    "PATH",
    "HOME",
    "LOAD_PATH",
    "IMPORT_PATH",
    "SUDO_EXEC"
    ],
    [
    sprintf ("%s/%s/msg.txt", TMPDIR, mytypename),
    ROOTDIR,
    SLSH_EXEC,
    FIFO_ROOT,
    SRV_SOCKADDR,
    PROC_SOCKADDR,
    getenv ("PATH"),
    getenv ("HOME"),
    get_slang_load_path (),
    get_import_module_path (),
    NULL != SUDO_EXEC ? SUDO_EXEC : "NULL"
    ]),
    array_map (String_Type, &sprintf, "%s=%d",
    [
    "DEBUG",
    "MSGROW",
    "COLUMNS",
    "ROOT_PID",
    "PROMPTROW",
    "SRV_FILENO"
    ],
    [
    DEBUG,
    MSGROW,
    COLUMNS,
    ROOT_PID,
    PROMPTROW,
    _fileno (SRV_SOCKET)
    ])]))
  root->exit_me (1, sprintf ("failed to create proc process: %s",
      errno_string (errno)));

if (any ([-1, 0] == pid_status (PROC_PID)))
  root->exit_me (1, NULL);
