sigprocmask (SIG_BLOCK, [SIGINT]);

public variable
  GETCH_LANG,
  MODIFIED = 0x01,
  ONDISKMODIFIED = 0x02,
  RDONLY = 0x04,
  GET_CHAR = 0x01F4,
  GET_EL_CHAR = 0x012C,
  DISPLAY = getenv ("DISPLAY"),
  LINES,
  COLUMNS,
  DRAWONLY,
  MSGROW,
  PROMPTROW,
  PROMPTCLR,
  INFOCLRBG,
  INFOCLRFG,
  SRV_SOCKADDR = getenv ("SRV_SOCKADDR"),
  SRV_SOCKET = @FD_Type (atoi (getenv ("SRV_FILENO")));

if ("NULL" == DISPLAY)
  DISPLAY = NULL;

private variable
  MYPATH = path_dirname (__FILE__),
  JUST_DRAW = 0x064,
  GOTO_EXIT = 0x0C8,
  OPENFILE = 0xd3,
  BUFFER = 0xde,
  BUFFERS = 0xe9,
  GET_COLS = 0x0190,
  GET_FILE = 0x0258,
  GET_ROWS = 0x02BC,
  GET_FTYPE = 0x0320,
  GET_INFOCLRFG = 0x0384,
  GET_INFOCLRBG = 0x0385,
  GET_PROMPTCOLOR = 0x03E8,
  GET_MSGROW = 0x044C,
  GET_FUNC = 0x04b0,
  GET_LINES = 0x0514,
  VED_SOCKADDR = getenv ("VED_SOCKADDR"),
  STDNS = getenv ("STDNS"),
  VED_SOCKET;

GETCH_LANG = GET_CHAR;

set_slang_load_path (sprintf ("%s/ftypes/share%c%s", MYPATH, path_get_delimiter (),
      getenv ("LOAD_PATH")));
set_import_module_path (getenv ("IMPORT_PATH"));

import ("socket");
import ("fork");
import ("pcre");

$1 = socket (PF_UNIX, SOCK_STREAM, 0);
bind ($1, VED_SOCKADDR);
listen ($1, 1);
VED_SOCKET = accept (__tmp ($1));
 
try
  {
  () = evalfile (sprintf ("%s/SockNs/sock_funcs", STDNS), "sock");
  () = evalfile (sprintf ("%s/client", MYPATH), "srv");
  () = evalfile (sprintf ("%s/keys", MYPATH), "keys");
  () = evalfile (sprintf ("%s/I_Ns/lib/except_to_arr", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/lib/std", STDNS));
  () = evalfile (sprintf ("%s/proc/Init", STDNS), "proc");
  () = evalfile (sprintf ("%s/I_Ns/lib/need", STDNS), "i");
  () = evalfile (sprintf ("%s/ftypes/Init", MYPATH), "ft");
  }
catch AnyError:
  {
  () = fprintf (stderr, "\n__\nERROR during evaluation of std libs\n");

  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
      strchop (sprintf ("Caught an exception:%s\n\
        Message:     %s\n\
        Object:      %S\n\
        Function:    %s\n\
        Line:        %d\n\
        File:        %s\n\
        Description: %s\n\
        Error:       %d\n",
        _push_struct_field_values (__get_exception_info)), '\n', 0));
 
  write (VED_SOCKET, string (GOTO_EXIT));
  exit (1);
  }

define send_int (i)
{
  sock->send_int (VED_SOCKET, i);
}

define ineed (lib)
{
  try
    i->need (lib);
  catch ParseError:
    {
    () = array_map (Integer_Type, &fprintf, stderr, "%s\n", exception_to_array ());

    send_int (GOTO_EXIT);
    exit (1);
    }
}

define get_int ()
{
  return sock->get_int (VED_SOCKET);
}

define get_int_ar ()
{
  return sock->get_int_ar (VED_SOCKET);
}

define get_char ()
{
  send_int (GETCH_LANG);
  return get_int ();
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

define get_ftype ()
{
  send_int (GET_FTYPE);
  return get_str ();
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

%CHANGE that calls to one
LINES = get_lines ();
COLUMNS = get_cols ();
MSGROW = get_msgrow ();
PROMPTROW = MSGROW - 1;
DRAWONLY = just_draw ();
INFOCLRFG = get_infoclrfg ();
INFOCLRBG = get_infoclrbg ();
PROMPTCLR = get_promptcolor ();

$1 = get_ftype ();

define exit_me (exit_code)
{
  send_int (GOTO_EXIT);
  exit (exit_code);
}

set_slang_load_path (sprintf ("%s/ftypes/%s%c%s", MYPATH, $1,
  path_get_delimiter (), get_slang_load_path ()));

public variable s_ = ft->init (__tmp ($1));

s_.ved ();

exit_me (0);
