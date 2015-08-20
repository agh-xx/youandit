sigprocmask (SIG_BLOCK, [SIGINT]);

public variable
  VEDPROC = struct
    {
    _inited = 0,
    _fd,
    _state = 0,
    },
  FTYPES = Assoc_Type[Integer_Type],
  CONNECTED = 0x1,
  IDLED = 0x2,
  MODIFIED = 0x01,
  ONDISKMODIFIED = 0x02,
  RDONLY = 0x04,
%  GET_CHAR = 0x01F4,
%  GET_EL_CHAR = 0x012C,
%  GETCH_LANG,
  DISPLAY = getenv ("DISPLAY"),
  LINES,
  COLUMNS,
  DRAWONLY,
  MSGROW,
  PROMPTROW,
  PROMPTCLR,
  INFOCLRBG,
  INFOCLRFG,
  VED_SOCKET,
  SRV_SOCKADDR = getenv ("SRV_SOCKADDR"),
  SRV_SOCKET = @FD_Type (atoi (getenv ("SRV_FILENO")));

if ("NULL" == DISPLAY)
  DISPLAY = NULL;

private variable
  MYPATH = path_dirname (__FILE__),
  JUST_DRAW = 0x064,
  GOTO_EXIT = 0x0C8,
  GET_COLS = 0x0190,
  GET_FILE = 0x0258,
  GET_ROWS = 0x02BC,
  %0x0320,
  GET_INFOCLRFG = 0x0384,
  GET_INFOCLRBG = 0x0385,
  GET_PROMPTCOLOR = 0x03E8,
  GET_MSGROW = 0x044C,
  GET_FUNC = 0x04b0,
  GET_LINES = 0x0514,
  VED_SOCKADDR = getenv ("VED_SOCKADDR"),
  STDNS = getenv ("STDNS");

FTYPES["txt"] = 0;
FTYPES["sl"] = 0;
FTYPES["list"] = 0;

set_slang_load_path (sprintf (
  "%s/ftypes/share%c%s", MYPATH,
  path_get_delimiter (),
  getenv ("LOAD_PATH")));

set_import_module_path (getenv ("IMPORT_PATH"));

import ("socket");

ifnot (VEDPROC._inited)
  {
  $1 = socket (PF_UNIX, SOCK_STREAM, 0);
  bind ($1, VED_SOCKADDR);
  listen ($1, 1);
  VED_SOCKET = accept (__tmp ($1));
  VEDPROC._fd = VED_SOCKET;
  VEDPROC._state = VEDPROC._state | CONNECTED;
  }

private define exception_to_array ()
{
  return strchop (sprintf ("Caught an exception:%s\n\
Message:     %s\n\
Object:      %S\n\
Function:    %s\n\
Line:        %d\n\
File:        %s\n\
Description: %s\n\
Error:       %d\n",
    _push_struct_field_values (__get_exception_info ())), '\n', 0);
}

private variable LOADED = Assoc_Type[Integer_Type, 0];

define need ()
{
  variable
    file,
    ns = current_namespace ();

  if (1 == _NARGS)
    file = ();

  if (2 == _NARGS)
    (file, ns) = ();

  if (NULL == ns || "" == ns)
    ns = "Global";
 
  if (LOADED[sprintf ("%s.%s", ns, file)])
    return;

  try
    {
    () = evalfile (file, ns);
    }
  catch OpenError:
    throw ParseError, sprintf ("%s: couldn't be found", file);
  catch ParseError:
    throw ParseError, sprintf ("file %s: %s func: %s lnr: %d", path_basename (file),
      __get_exception_info.message, __get_exception_info.function,
      __get_exception_info.line);
 
  LOADED[sprintf ("%s.%s", ns, file)] = 1;
}

define ineed ()
{
  variable args = __pop_list (_NARGS);

  try
    need (__push_list (args));
  catch ParseError:
    {
    () = array_map (Integer_Type, &fprintf, stderr, "%s\n", exception_to_array ());

    write (VED_SOCKET, string (GOTO_EXIT));

    exit (1);
    }
}

define readfile (file)
{
  variable
    end = qualifier ("end", NULL),
    fp = fopen (file, "r");

  if (NULL == fp)
    return NULL;

  ifnot (NULL == end)
    return array_map (String_Type, &strtrim_end, fgetslines (fp, end), "\n");

  return array_map (String_Type, &strtrim_end, fgetslines (fp), "\n");
}

ineed  (sprintf ("%s/sock", MYPATH), "sock");
ineed  (sprintf ("%s/client", MYPATH), "srv");
ineed  (sprintf ("%s/keys", MYPATH), "keys");
ineed  (sprintf ("%s/ftypes/Init", MYPATH));

define send_int (i)
{
  sock->send_int (VED_SOCKET, i);
}

define get_int ()
{
  return sock->get_int (VED_SOCKET);
}

define get_int_ar ()
{
  return sock->get_int_ar (VED_SOCKET);
}

define get_str ()
{
  return sock->get_str (VED_SOCKET);
}

define get_cols ()
{
  send_int (GET_COLS);
  return get_int ();
}

define get_lines ()
{
  send_int (GET_LINES);
  return get_int ();
}

define get_msgrow ()
{
  send_int (GET_MSGROW);
  return get_int ();
}

define get_rows ()
{
  send_int (GET_ROWS);
  return get_int_ar ();
}

define get_file ()
{
  send_int (GET_FILE);
  return get_str ();
}

define get_ftype (fn)
{
  variable ftype = substr (path_extname (fn), 2, -1);
  ifnot (any (assoc_get_keys (FTYPES) == ftype))
    ftype = "txt";

  return ftype;
}

define get_infoclrfg ()
{
  send_int (GET_INFOCLRFG);
  return get_int ();
}

define get_infoclrbg ()
{
  send_int (GET_INFOCLRBG);
  return get_int ();
}

define get_promptcolor ()
{
  send_int (GET_PROMPTCOLOR);
  return get_int ();
}

define just_draw ()
{
  send_int (JUST_DRAW);
  return get_int ();
}

define get_func ()
{
  send_int (GET_FUNC);
  return get_int ();
}

define get_count ()
{
  send_int (0);
  ifnot (get_int ())
    return -1;

  send_int (0);
  return get_int ();
}

%CHANGE those calls to one
LINES = get_lines ();
COLUMNS = get_cols ();
MSGROW = get_msgrow ();
PROMPTROW = MSGROW - 1;
DRAWONLY = just_draw ();
INFOCLRFG = get_infoclrfg ();
INFOCLRBG = get_infoclrbg ();
PROMPTCLR = get_promptcolor ();

define exit_me (exit_code)
{
  variable
    tty_inited = __get_reference ("TTY_Inited"),
    reset = NULL != tty_inited ? __get_reference ("reset_tty") : NULL;

  if (@tty_inited)
    (@reset) ();

  send_int (GOTO_EXIT);
  exit (exit_code);
}

private variable s_ = init_ftype (get_ftype (__argv[-1]));

VEDPROC._inited = 1;

s_.ved (__argv[-1], get_rows ());

exit_me (0);
