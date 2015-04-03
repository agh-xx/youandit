private variable
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

private define send_chr ()
{
  variable chr = (@getch);
  sock->send_int (PG_SOCKET, chr);
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
  variable p = @proc->init (0, 1, 1);

  p.stdout.file = CW.buffers[CW.cur.frame].fname,
  p.stdout.wr_flags = ">>";
  p.stderr.file = CW.msgbuf;
  p.stderr.wr_flags = ">>";

  return p;
}

define ved ()
{
  variable
    ftypes = ["txt", "list"];

  ifnot (_NARGS)
    FILE = CW.buffers[CW.cur.frame].fname;
  else  
    FILE = ();
  
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
    CHNG_LANG = 0x012C,
    SEND_COLS = 0x0190,
    SEND_CHAR = 0x01F4,
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
      sprintf ("SRV_FILENO=%d", _fileno (SRV_SOCKET))],
    p = doproc (),
    funcs = Assoc_Type[Ref_Type];
  
  funcs[string (JUST_DRAW)] = &just_draw;
  funcs[string (CHNG_LANG)] = &chng_lang;
  funcs[string (SEND_CHAR)] = &send_chr;
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
