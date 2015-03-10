variable
  PROC_FD,
  SOCKET_FD,
  PIDS = Assoc_Type[String_Type],
  FUNCS = Assoc_Type[Ref_Type],
  HOME = getenv ("HOME"),
  MSGROW = getenv ("MSGROW"),
  COLUMNS = getenv ("COLUMNS"),
  ROOTDIR = getenv ("ROOTDIR"),
  BINDIR = getenv ("BINDIR"),
  TEMPDIR = getenv ("TEMPDIR"),
  DEBUG = atoi (getenv ("DEBUG")),
  SLSH_EXEC = getenv ("SLSH_EXEC"),
  SUDO_EXEC = getenv ("SUDO_EXEC"),
  PROMPTROW = getenv ("PROMPTROW"),
  ROOT_PID = atoi (getenv ("ROOT_PID")),
  SRV_SOCKADDR = getenv ("SRV_SOCKADDR"),
  PROC_SOCKADDR = getenv ("PROC_SOCKADDR"),
  SRV_FILENO = atoi (getenv ("SRV_FILENO")),
  SRV_SOCKET = @FD_Type (SRV_FILENO),
  DONTRECONNECT = 1,
  TTY_INITED = 0;

set_slang_load_path (getenv ("LOAD_PATH"));
set_import_module_path (getenv ("IMPORT_PATH"));

putenv (sprintf ("PATH=%s", getenv ("PATH")));

() = evalfile (sprintf ("%s/lib/dirs", path_dirname (__FILE__)));

try
  {
  import ("fork");
  import ("socket");
  import ("getkey");
  }
catch ImportError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
      strtok (sprintf ("Caught an exception:%s\n\
        Message:     %s\n\
        Object:      %S\n\
        Function:    %s\n\
        Line:        %d\n\
        File:        %s\n\
        Description: %s\n\
        Error:       %d\n",
        _push_struct_field_values (__get_exception_info)), "\n"));
  exit (1);
  }

try
  {
  () = evalfile (sprintf ("%s/I_Ns/lib/except_to_arr", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/lib/need", STDNS), "i");
  () = evalfile (sprintf ("%s/SockNs/sock_funcs", STDNS), "sock");
  () = evalfile (sprintf ("%s/SrvNs/Client", STDNS), "srv");
  }
catch ParseError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
      strtok (sprintf ("Caught an exception:%s\n\
        Message:     %s\n\
        Object:      %S\n\
        Function:    %s\n\
        Line:        %d\n\
        File:        %s\n\
        Description: %s\n\
        Error:       %d\n",
        _push_struct_field_values (__get_exception_info)), "\n"));
  exit (1);
  }

define read_fd (fd)
{
  variable
    buf,
    str = "";

  while (read (fd, &buf, 1024) > 0)
    str = sprintf ("%s%s", str, buf);

  return strlen (str) ? str : NULL;
}

define _print (msg)
{
  variable fp = fopen (getenv ("MSGFILE"), "a+");
  () = fprintf (fp, "%s\n", msg);
  () = fclose (fp);
}

variable
  print_err = &_print,
  print_out = &_print;

define ineed (lib)
{
  try
    i->need (lib);
  catch ParseError:
    throw ParseError, __get_exception_info.message;
}

define get_bg_pid ()
{
  variable
    i,
    pid,
    status,
    list = listdir (BGDIR);

    if (length (list))
      _for i (0, length (list) - 1)
        {
        if (any ([".CONSTANT", ".START"] == path_extname (list[i])))
          continue;

        pid = atoi (path_basename (list[i]));
        () = kill (pid, SIGALRM);
        status = waitpid (pid, 0);
        assoc_delete_key (PIDS, string (pid));
        }
}

define call_bg (argv, env, dim, passwd)
{
  variable
    fp,
    pid,
    index,
    stdinr,
    stdinw,
    status,
    fexec = SLSH_EXEC;

  ifnot (NULL == passwd)
    fexec = SUDO_EXEC;
 
  argv = [SLSH_EXEC, sprintf ("%s/bg/Call.slc", path_dirname (__FILE__)), argv];

  env = [env,
      sprintf ("DEBUG=%d", DEBUG),
      sprintf ("LINES=%d", dim[0]),
      sprintf ("COLUMNS=%d", dim[1]),
      sprintf ("SRV_FILENO=%d", SRV_FILENO),
      sprintf ("LOAD_PATH=%s", get_slang_load_path ()),
      sprintf ("IMPORT_PATH=%s", get_import_module_path ())];
 
  COLUMNS = dim[1];
  MSGROW = dim[0] - 1;

  ifnot (NULL == passwd)
    {
    argv = [SUDO_EXEC, "-E", "-S", "-C", sprintf ("%d", SRV_FILENO + 1), argv];

    (stdinr, stdinw) = pipe ();
 
    () = write (stdinw, passwd + "\n");
    () = close (stdinw);

    () = dup2_fd (stdinr, 0);
    }

  pid = fork ();

  if (-1 == pid)
    {
    srv->send_msg_and_refresh ("background fork failed", -1);
    return;
    }

  if ((0 == pid) && -1 == execve (fexec, argv, env))
    {
    () = kill (pid, SIGKILL);
    srv->send_msg_and_refresh ("failed to create background proccess", -1);
    return NULL;;
    }
 
  return pid;
}

define edVi ()
{
  variable
    issudo,
    pid,
    infdr,
    infdw,
    status,
    fexec = SLSH_EXEC,
    argv = [SLSH_EXEC, sprintf ("%s/%s/init.slc", path_dirname (__FILE__),
      _function_name ())];

  issudo = sock->get_int_send_bit (PROC_FD, 0);

  if (issudo)
    {
    fexec = SUDO_EXEC;
    variable passwd = sock->get_str_send_bit (PROC_FD, 0);
    argv = [SUDO_EXEC, "-E", "-S", "-C", sprintf ("%d", SRV_FILENO + 1), argv];
    (infdr, infdw) = pipe ();
    () = write (infdw, passwd + "\n");
    () = close (infdw);
    () = dup2_fd (infdr, 0);
    }
 
  variable
    outfdw,
    outfdr,
    errfdw,
    errfdr,
    outfds = dup_fd (fileno (stdout)),
    errdfs = dup_fd (fileno (stderr));

   (outfdr, outfdw) = pipe ();
   (errfdr, errfdw) = pipe ();
 
   () = dup2_fd (outfdw, 1);
   () = dup2_fd (errfdw, 2);

  variable
    file = sock->get_str_send_bit (PROC_FD, 0),
    term = sock->get_str_send_bit (PROC_FD, 0),
    lang = sock->get_str_send_bit (PROC_FD, 0),
    dim = sock->get_int_ar_send_bit (PROC_FD, 0);

  argv = [argv, file];

  variable env = [
      sprintf ("LANG=%s", lang),
      sprintf ("SRV_SOCKADDR=%s", SRV_SOCKADDR),
      sprintf ("SRV_FILENO=%d", SRV_FILENO),
      sprintf ("ROOTDIR=%s", ROOTDIR),
      sprintf ("TEMPDIR=%s", TEMPDIR),
      sprintf ("TERM=%s", term),
      sprintf ("LOAD_PATH=%s", get_slang_load_path ()),
      sprintf ("IMPORT_PATH=%s", get_import_module_path ()),
      sprintf ("STDNS=%s", STDNS),
      sprintf ("LINES=%d", dim[0]),
      sprintf ("COLUMNS=%d", dim[1])];

  pid = fork ();

  if (-1 == pid)
    {
    srv->send_msg_and_refresh ("fork failed", -1);
    return 1;
    }

  if ((0 == pid) && -1 == execve (fexec, argv, env))
    {
    () = kill (pid, SIGKILL);
    srv->send_msg_and_refresh ("failed to create proccess", -1);
    return 1;
    }

  status = waitpid (pid, 0);
 
  () = _close (_fileno (outfdw));
  () = _close (_fileno (errfdw));
 
  () = dup2_fd (outfds, 1);
  () = dup2_fd (errdfs, 2);
 
  variable
    ERR = 0x042,
    GOTO_EXIT = 0x06f,
    READ_STDOUT = 0x0B,
    READ_STDERR = 0x016,
    out = read_fd (outfdr),
    err = read_fd (errfdr);

  if (ERR == status.exit_status)
    {
    variable EDVI_SOCKADDR = sprintf ("%s/_pipes/edVi.sock", TEMPDIR);
    variable EDVI_SOCKET = socket (PF_UNIX, SOCK_STREAM, 0);
    forever
      {
      try
        connect (EDVI_SOCKET, EDVI_SOCKADDR);
      catch AnyError:
        continue;

       break;
      }

    sock->get_bit_send_int (EDVI_SOCKET, GOTO_EXIT);
    }

  ifnot (NULL == out)
    {
    () = sock->get_bit_send_int (PROC_FD, READ_STDOUT);
    () = sock->get_bit_send_str_ar (PROC_FD, strchop (out, '\n', 0));
    }

  ifnot (NULL == err)
    {
    () = sock->get_bit_send_int (PROC_FD, READ_STDERR);
    () = sock->get_bit_send_str_ar (PROC_FD, strchop (err, '\n', 0));
    }

  () = sock->get_bit_send_int (PROC_FD, status.exit_status);
}

FUNCS["edVi"] = &edVi;

define call (argv, env, dim, passwd)
{
  get_bg_pid ();

  variable
    fp,
    pid,
    index,
    stdinr,
    stdinw,
    status,
    fexec = SLSH_EXEC;

  ifnot (NULL == passwd)
    fexec = SUDO_EXEC;
 
  argv = [SLSH_EXEC, sprintf ("%s/fg/Call.slc", path_dirname (__FILE__)), argv];

  env = [env,
      sprintf ("DEBUG=%d", DEBUG),
      sprintf ("LINES=%d", dim[0]),
      sprintf ("COLUMNS=%d", dim[1]),
      sprintf ("SRV_FILENO=%d", SRV_FILENO),
      sprintf ("LOAD_PATH=%s", get_slang_load_path ()),
      sprintf ("IMPORT_PATH=%s", get_import_module_path ())];
 
  COLUMNS = dim[1];
  MSGROW = dim[0] - 1;

  ifnot (NULL == passwd)
    {
    argv = [SUDO_EXEC, "-E", "-S", "-C", sprintf ("%d", SRV_FILENO + 1), argv];

    (stdinr, stdinw) = pipe ();
 
    () = write (stdinw, passwd + "\n");
    () = close (stdinw);

    () = dup2_fd (stdinr, 0);
    }

  pid = fork ();

  if (-1 == pid)
    {
    srv->send_msg_and_refresh ("fork failed", -1);
    return 1;
    }

  if ((0 == pid) && -1 == execve (fexec, argv, env))
    {
    () = kill (pid, SIGKILL);
    srv->send_msg_and_refresh ("failed to create proccess", -1);
    return 1;
    }
 
  status = waitpid (pid, 0);
  return status.exit_status;
}

define init_server ()
{
  SOCKET_FD = socket (PF_UNIX, SOCK_STREAM, 0);
  bind (SOCKET_FD, PROC_SOCKADDR);
  listen (SOCKET_FD, 2);
  PROC_FD = accept (SOCKET_FD);
}

define get ()
{
  variable
    i,
    func,
    file,
    type,
    retval,
    err = NULL,
    largv = {};

  type = sock->get_str_send_bit (PROC_FD, 0);

  while (type != "end")
    {
    list_append (largv, (@sock->sock_f_g_srv[type]) (PROC_FD, 0));
    type = sock->get_str_send_bit (PROC_FD, 0);
    }

  file = largv[0];
  func = largv[1];

  try
    {
    () = evalfile (file, func);
    func = __get_reference (sprintf ("%s->%s", func, func));
    retval = (@func) (__push_list (largv[[2:]]));
    }
  catch ParseError:
    err =["Get: PARSE ERROR", exception_to_array ()];
  catch AnyError:
    err = ["Get: RUNTIME ERROR", exception_to_array ()];
 
  ifnot (NULL == err)
    {
    () = sock->get_bit_send_bit (PROC_FD, 1);
    () = sock->get_bit_send_str_ar (PROC_FD, err);
    return;
    }

  () = sock->get_bit_send_bit (PROC_FD, 0);

  type = string (typeof (retval));
  if ("Array_Type" == type)
    type = sprintf ("%S_Ar", _typeof (retval));

  () = (@sock->sock_f_s_srv[type]) (PROC_FD, retval);
}

FUNCS["get"] = &get;

define bglist ()
{
  ifnot (length (PIDS))
    {
    () = sock->get_bit_send_int_ar (PROC_FD, [0]);
    return;
    }
 
  variable
    pids = assoc_get_keys (PIDS),
    coms = assoc_get_values (PIDS);

  () = sock->get_bit_send_int_ar (PROC_FD, pids);
  () = sock->get_bit_send_str_ar (PROC_FD, coms);
}

FUNCS["bglist"] = &bglist;

define bgpids ()
{
  () = sock->get_bit_send_int_ar (PROC_FD, length (PIDS) ? assoc_get_keys (PIDS) : [0]);
}

FUNCS["bgpids"] = &bgpids;

define bgkillpid ()
{
  variable
    status,
    pid = sock->get_int_send_bit (PROC_FD, 0);
 
  ifnot (assoc_key_exists (PIDS, string (pid)))
    () = sock->get_bit_send_int (PROC_FD, 256);

  assoc_delete_key (PIDS, string (pid));

  () = kill (pid, SIGALRM);
  status = waitpid (pid, 0);

  () = sock->get_bit_send_int (PROC_FD, status.exit_status);
}

FUNCS["bgkillpid"] = &bgkillpid;

define cd (dir)
{
  if (-1 == chdir (dir[0]))
    {
    () = sock->get_bit_send_int (PROC_FD, 1);
    () = sock->get_bit_send_str (PROC_FD, errno_string (errno));
    return;
    }

  () = sock->get_bit_send_int (PROC_FD, 0);
}

FUNCS["cd"] = &cd;

define main ()
{
  variable
    ar,
    env,
    dim,
    argv,
    is_fg,
    passwd,
    retval,
    is_sudo,
    funcs = assoc_get_keys (FUNCS);

  forever
    {
    passwd = NULL;

    argv = sock->get_str_ar_send_bit (PROC_FD, 0);
 
    if (any (funcs == argv[0]))
      {
      if (1 < length (argv))
        (@FUNCS[argv[0]]) (argv[[1:]]);
      else
        (@FUNCS[argv[0]]);

      continue;
      }

    env = sock->get_str_ar_send_bit (PROC_FD, 0);
    ar = sock->get_int_ar_send_bit (PROC_FD, 0);

    (is_fg, is_sudo, dim) = ar[0], ar[1], ar[[2:]];

    if (is_sudo)
      passwd = sock->get_str_send_bit (PROC_FD, 0);
 
    ifnot (is_fg)
      retval = call_bg (argv, env, dim, passwd);
    else
      retval = call (argv, env, dim, passwd);

    () = sock->get_bit_send_int (PROC_FD, retval);

    ifnot (is_fg)
      ifnot (NULL == retval)
        PIDS[string (retval)] = strjoin (argv, " ");
    }
}

signal (SIGINT, SIG_IGN);

init_server ();

main ();
