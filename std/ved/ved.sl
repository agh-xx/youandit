typedef struct
  {
  _addr,
  _fd,
  _ftype,
  _state,
  p_,
  } Ved_Type;

private variable B = Assoc_Type[Ved_Type];
private variable funcs = Assoc_Type[Ref_Type];
private variable cb;
private variable
  CONNECTED = 0x1,
  IDLED = 0x2,
  JUST_DRAW = 0x064,
  GOTO_EXIT = 0x0C8,
  OPENFILE = 0xd3,
  BUFFER = 0xde,
  BUFFERS = 0xe9,
  SEND_COLS = 0x0190,
  SEND_CHAR = 0x01F4,
  SEND_EL_CHAR = 0x012C,
  SEND_FILE = 0x0258,
  SEND_ROWS = 0x02BC,
  SEND_FTYPE = 0x0320,
  SEND_INFOCLRFG = 0x0384,
  SEND_INFOCLRBG = 0x0385,
  SEND_PROMPTCOLOR = 0x03E8,
  SEND_MSGROW = 0x044C,
  SEND_FUNC = 0x04b0,
  SEND_LINES = 0x0514;

private variable
  ISSUDO = 0,
  FILE,
  FUNC,
  FTYPE,
  COUNT,
  DRAWONLY,
  VED_SOCKET;

private define buf_exit (fn)
{
  ifnot (assoc_key_exists (B, fn))
    return;

  variable status = waitpid (B[fn].p_.pid, 0);
  B[fn].p_.atexit ();

  assoc_delete_key (B, fn);
}

private define send_lines ()
{
  sock->send_int (VED_SOCKET, LINES);
}

private define send_func ()
{
  sock->send_int (VED_SOCKET, NULL == FUNC ? 0 : FUNC);
  ifnot (NULL == FUNC)
    {
    () = sock->get_int (VED_SOCKET);
    sock->send_int (VED_SOCKET, NULL == COUNT ? 0 : 1);

    ifnot (NULL == COUNT)
      {
      () = sock->get_int (VED_SOCKET);
      sock->send_int (VED_SOCKET, COUNT);
      }
    }
}

private define just_draw ()
{
  sock->send_int (VED_SOCKET, DRAWONLY);
}

private define send_rows ()
{
  variable
    frame = CW.cur.frame,
    rows = [CW.dim[frame].rowfirst:CW.dim[frame].rowlast + 1];

  sock->send_int_ar (rows);
}

private define send_file ()
{
  sock->send_str (VED_SOCKET, FILE);
}

private define send_el_chr ()
{
  getchar_lang = &input->el_getch;
  sock->send_int (VED_SOCKET, (@getch));
  getchar_lang = &input->en_getch;
}

private define send_chr ()
{
  sock->send_int (VED_SOCKET, (@getch));
}

private define send_cols ()
{
  sock->send_int (VED_SOCKET, COLUMNS);
}

private define send_msgrow ()
{
  sock->send_int (VED_SOCKET, MSGROW);
}

private define send_ftype ()
{
  sock->send_str (VED_SOCKET, FTYPE);
}

private define send_infoclrfg ()
{
  sock->send_int (VED_SOCKET, COLOR.activeframe);
}

private define send_infoclrbg ()
{
  sock->send_int (VED_SOCKET, COLOR.info);
}

private define send_promptcolor ()
{
  sock->send_int (VED_SOCKET, COLOR.prompt);
}

private define broken_sudoproc_broken ()
{
  variable passwd = root.lib.getpasswd ();

  ifnot (strlen (passwd))
    {
    srv->send_msg ("Password is an empty string. Aborting ...", -1);
    return NULL;
    }

  variable retval = root.lib.validate_passwd (passwd);

  if (NULL == retval)
    {
    srv->send_msg ("This is not a valid password", -1);
    return NULL;
    }

  variable p = proc->init (1, 1, 1);

  p.stdin.in = passwd;
  return p;
}

private define doproc (sockaddr, issudo)
{
  variable p;

  ifnot (issudo)
    p = proc->init (0, 1, 1);
  else
    if (p = broken_sudoproc_broken (), p == NULL)
      return NULL;

  p.stdout.file = CW.buffers[CW.cur.frame].fname,
  p.stdout.wr_flags = ">>";
  p.stderr.file = CW.msgbuf;
  p.stderr.wr_flags = ">>";

  variable
    argv = [PROC_EXEC, sprintf ("%s/proc", path_dirname (__FILE__))],
    env = [
      sprintf ("VED_SOCKADDR=%s", sockaddr),
      sprintf ("IMPORT_PATH=%s", get_import_module_path ()),
      sprintf ("LOAD_PATH=%s", get_slang_load_path ()),
      sprintf ("TERM=%s", getenv ("TERM")),
      sprintf ("LANG=%s", getenv ("LANG")),
      sprintf ("STDNS=%s", STDNS),
      sprintf ("SRV_SOCKADDR=%s", SRV_SOCKADDR),
      sprintf ("SRV_FILENO=%d", _fileno (SRV_SOCKET)),
      sprintf ("DISPLAY=%S", getenv ("DISPLAY")),
      sprintf ("PATH=%s", getenv ("PATH")),
      ];

  if (NULL == p.execve (argv, env, 1))
    return NULL;

  return p;
}

private define is_file (fn)
{
  ifnot (stat_is ("reg", stat_file (fn).st_mode))
    {
    srv->send_msg_and_refresh (sprintf ("%s: is not a regular file", fn), -1);
    return -1;
    }

  return 0;
}

private define is_file_readable (fn, issudo)
{
  if (-1 == access (fn, R_OK) && 0 == issudo)
    {
    srv->send_msg_and_refresh (sprintf ("%s: is not readable", fn), -1);
    return -1;
    }

  return 0;
}

private define parse_args ()
{
  variable
    ftypes = ["txt", "list"];

  ifnot (_NARGS)
    FILE = CW.buffers[CW.cur.frame].fname;
  else
    FILE = ();

  ifnot (access (FILE, F_OK))
    {
    if (-1 == is_file (FILE))
      return -1;
 
    if (-1 == is_file_readable (FILE, ISSUDO))
      return -1;
    }

  COUNT = qualifier ("count");
  FUNC = qualifier ("func");
  DRAWONLY = qualifier_exists ("drawonly");
  FTYPE = qualifier ("ftype", substr (path_extname (FILE), 2, -1));

  ifnot (any (FTYPE == ftypes))
    FTYPE = "txt";

  return 0;
}

private define connect_to_child (p, sockaddr)
{
  VED_SOCKET = p.connect (sockaddr);

  if (NULL == VED_SOCKET)
    {
    p.atexit ();
    () = kill (p.pid, SIGKILL);
    return;
    }
  
  cb._state = cb._state | CONNECTED;

  variable retval;

  forever
    {
    retval = sock->get_int (VED_SOCKET);
 
    ifnot (Integer_Type == typeof (retval))
      break;

    if (retval == GOTO_EXIT)
      {
      cb._state = cb._state & ~CONNECTED;
      break;
      }
 
    (@funcs[string (retval)]) (VED_SOCKET);
    }
}

private define init_buf (p, sockaddr)
{
  B[FILE] = @Ved_Type;
  B[FILE]._addr = sockaddr;
  B[FILE]._ftype = FTYPE;
  B[FILE]._state = 0;
  B[FILE].p_ = p;
  cb = B[FILE];
}

private define init_sockaddr (fn)
{
  return sprintf ("%s/_ved/ved_%s_%d.sock", TEMPDIR,
    path_basename_sans_extname (fn), _time);
}

private define _ved_ ()
{
  variable args = __pop_list (_NARGS);

  if (-1 == parse_args (__push_list (args);;__qualifiers ()))
    return;

  variable
    retval,
    sockaddr = init_sockaddr (FILE),
    p = doproc (sockaddr, ISSUDO);

  if (NULL == p)
    return;
  
  init_buf (p, sockaddr);

  connect_to_child (p, sockaddr);

  buf_exit (FILE);
}

define ved ()
{
  variable args = __pop_list (_NARGS);
  _ved_ (__push_list (args);;__qualifiers ());

  if (qualifier_exists ("drawwind"))
    CW.drawwind ();

  ISSUDO = 0;
}

define vedsudo ()
{
  ISSUDO = 1;
  
  variable args = __pop_list (_NARGS);
  _ved_ (__push_list (args);;__qualifiers ());

  ISSUDO = 0;
}

funcs[string (JUST_DRAW)] = &just_draw;
funcs[string (SEND_CHAR)] = &send_chr;
funcs[string (SEND_EL_CHAR)] = &send_el_chr;
funcs[string (SEND_COLS)] = &send_cols;
funcs[string (SEND_FILE)] = &send_file;
funcs[string (SEND_ROWS)] = &send_rows;
funcs[string (SEND_FTYPE)] = &send_ftype;
funcs[string (SEND_INFOCLRBG)] = &send_infoclrbg;
funcs[string (SEND_INFOCLRFG)] = &send_infoclrfg;
funcs[string (SEND_PROMPTCOLOR)] = &send_promptcolor;
funcs[string (SEND_MSGROW)] = &send_msgrow;
funcs[string (SEND_FUNC)] = &send_func;
funcs[string (SEND_LINES)] = &send_lines;
