private variable
  ISSUDO = 0,
  FILE,
  FUNC,
  FTYPE,
  COUNT,
  DRAWONLY,
  PG_SOCKET;

private define send_lines ()
{
  sock->send_int (PG_SOCKET, LINES);
}

private define send_func ()
{
  sock->send_int (PG_SOCKET, NULL == FUNC ? 0 : FUNC);
  ifnot (NULL == FUNC)
    {
    () = sock->get_int (PG_SOCKET);
    sock->send_int (PG_SOCKET, NULL == COUNT ? 0 : 1);

    ifnot (NULL == COUNT)
      {
      () = sock->get_int (PG_SOCKET);
      sock->send_int (PG_SOCKET, COUNT);
      }
    }
}

private define just_draw ()
{
  sock->send_int (PG_SOCKET, DRAWONLY);
}

private define chng_lang ()
{
  root.func.call ("change_getch");
  sock->send_int (PG_SOCKET, 0);
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
  sock->send_str (PG_SOCKET, FILE);
}

private define send_el_chr ()
{
  getchar_lang = &input->el_getch;
  sock->send_int (PG_SOCKET, (@getch));
  getchar_lang = &input->en_getch;
}

private define send_chr ()
{
  sock->send_int (PG_SOCKET, (@getch));
}

private define send_cols ()
{
  sock->send_int (PG_SOCKET, COLUMNS);
}

private define send_msgrow ()
{
  sock->send_int (PG_SOCKET, MSGROW);
}

private define send_ftype ()
{
  sock->send_str (PG_SOCKET, FTYPE);
}

private define send_infoclrfg ()
{
  sock->send_int (PG_SOCKET, COLOR.activeframe);
}

private define send_infoclrbg ()
{
  sock->send_int (PG_SOCKET, COLOR.info);
}

private define send_promptcolor ()
{
  sock->send_int (PG_SOCKET, COLOR.prompt);
}

private define doproc ()
{
  variable p;

  if (ISSUDO)
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

    p = @proc->init (1, 1, 1);

    p.stdin.in = passwd;
    }
  else
    p = @proc->init (0, 1, 1);

  p.stdout.file = CW.buffers[CW.cur.frame].fname,
  p.stdout.wr_flags = ">>";
  p.stderr.file = CW.msgbuf;
  p.stderr.wr_flags = ">>";

  return p;
}

private define _ved_ ()
{
  variable
    ftypes = ["txt", "list"];

  ifnot (_NARGS)
    FILE = CW.buffers[CW.cur.frame].fname;
  else
    FILE = ();

  ifnot (access (FILE, F_OK))
    {
    ifnot (stat_is ("reg", stat_file (FILE).st_mode))
      {
      srv->send_msg_and_refresh (sprintf ("%s: is not a regular file", FILE), -1);
      return;
      }
 
    if (-1 == access (FILE, R_OK) && 0 == ISSUDO)
      {
      srv->send_msg_and_refresh (sprintf ("%s: is not readable", FILE), -1);
      return;
      }
    }

  COUNT = qualifier ("count");
  FUNC = qualifier ("func");
  DRAWONLY = qualifier_exists ("drawonly");
  FTYPE = qualifier ("ftype", substr (path_extname (FILE), 2, -1));

  ifnot (any (FTYPE == ftypes))
    FTYPE = "txt";

  variable
    retval,
    JUST_DRAW = 0x064,
    GOTO_EXIT = 0x0C8,
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
    SEND_LINES = 0x0514,
    PG_SOCKADDR = sprintf ("%s/_pipes/pg.sock", TEMPDIR),
    argv = [PROC_EXEC, sprintf ("%s/proc", path_dirname (__FILE__))],
    env = [
      sprintf ("PG_SOCKADDR=%s", PG_SOCKADDR),
      sprintf ("IMPORT_PATH=%s", get_import_module_path ()),
      sprintf ("LOAD_PATH=%s", get_slang_load_path ()),
      sprintf ("TERM=%s", getenv ("TERM")),
      sprintf ("LANG=%s", getenv ("LANG")),
      sprintf ("STDNS=%s", STDNS),
      sprintf ("SRV_SOCKADDR=%s", SRV_SOCKADDR),
      sprintf ("SRV_FILENO=%d", _fileno (SRV_SOCKET)),
      sprintf ("DISPLAY=%S", getenv ("DISPLAY")),
      sprintf ("PATH=%s", getenv ("PATH")),
      ],
    funcs = Assoc_Type[Ref_Type],
    p = doproc ();

  if (NULL == p)
    return;
  
%  if (ISSUDO)
%    argv = [SUDO_EXEC, "-S", "-E", argv];
%    %argv = [SUDO_EXEC, "-S", "-E", "-C", "140", argv];
%    %argv = [SUDO_EXEC, "-S", "-E", "-C", sprintf ("%d", _fileno (SRV_SOCKET) + 1), argv];

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
 
  if (-1 == p.execve (argv, env, 1))
    return;
 
  PG_SOCKET = p.connect (PG_SOCKADDR);

  if (NULL == PG_SOCKET)
    {
    p.atexit ();
    () = kill (p.pid, SIGKILL);
    return;
    }

  forever
    {
    retval = sock->get_int (PG_SOCKET);
 
    ifnot (Integer_Type == typeof (retval))
      break;

    if (retval == GOTO_EXIT)
      break;
 
    (@funcs[string (retval)]) (PG_SOCKET);
    }

  variable status = waitpid (p.pid, 0);
  p.atexit ();
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
