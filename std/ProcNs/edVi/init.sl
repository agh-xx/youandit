sigprocmask (SIG_BLOCK, [SIGINT]);

private variable
  MYPATH = path_dirname (__FILE__);

public variable
  EXIT_CODE = 0,
  WHOAMI = 0 == getuid () ? "root" : NULL;

define exit_me (msg, retval)
{
  () = fprintf (NULL == retval ? stderr : stdout, "%s\n", msg);
  exit (NULL == retval ? 1 : 0);
}

private define getpwuid (uid, err_func)
{
  $5 = fopen ("/etc/passwd", "r");

  if (NULL == $5)
    return (@err_func) ("/etc/passwd is not readable, this shouldn't be happen", NULL);
  
  while (-1 != fgets (&$6, $5))
    {
    $7 = strchop ($6, ':', 0);
    if (string (uid) == $7[2])
      return $7[0];
    }

  array_map (Void_Type, &__uninitialize, [&$5, &$6, &$7]);

  return (@err_func) (sprintf ("cannot find your UID %d in /etc/passwd, who are you?", uid),
    NULL);
}

if (NULL == WHOAMI)
  WHOAMI = getpwuid (getuid (), &exit_me);

private define getgrgid (gid, err_func)
{
  $5 = fopen ("/etc/group", "r");

  if (NULL == $5)
    return (@err_func) ("/etc/group is not readable, this shouldn't be happen", NULL);
  
  while (-1 != fgets (&$6, $5))
    {
    $7 = strchop ($6, ':', 0);
    if (string (gid) == $7[2])
      return $7[0];
    }

  array_map (Void_Type, &__uninitialize, [&$5, &$6, &$7]);

  return (@err_func) (sprintf ("cannot find gid %d in /etc/group?", gid), NULL);
}

variable TEMPDIR = getenv ("TEMPDIR");

private variable
  ROOTDIR = getenv ("ROOTDIR"),
  STDNS = getenv ("STDNS"),
  EDVIDIR = sprintf ("%s/_edVi", TEMPDIR),
  EDVI_SOCKADDR = sprintf ("%s/_pipes/edVi.sock", TEMPDIR),
  EDVI_SOCKET,
  SAVEJS;

variable
  COLUMNS = atoi (getenv ("COLUMNS")),
  LINES = atoi (getenv ("LINES")),
  SRV_SOCKADDR = getenv ("SRV_SOCKADDR"),
  SRV_SOCKET = @FD_Type (atoi (getenv ("SRV_FILENO"))),
  TTY_INITED = 0;

set_import_module_path (getenv ("IMPORT_PATH"));
set_slang_load_path (sprintf ("%s/lib%c%s/I_Ns/ftypes/share",
  STDNS, path_get_delimiter (),
  STDNS));

import ("socket");
import ("getkey");

variable getch, getchar_lang;

variable s_ = @Struct_Type ("");

try
  {
  () = evalfile (sprintf ("%s/SockNs/sock_funcs", STDNS), "sock");
  () = evalfile (sprintf ("%s/client", MYPATH), "srv");
  () = evalfile (sprintf ("%s/InputNs/input", STDNS), "input");
  () = evalfile (sprintf ("%s/keys", MYPATH), "keys");
  () = evalfile (sprintf ("%s/I_Ns/lib/except_to_arr", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/lib/std", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/lib/need", STDNS), "i");
  () = evalfile (sprintf ("%s/I_Ns/ftypes/Init", STDNS));
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

  exit (1);
  }

getch = &input->getchar;
getchar_lang = &input->en_getch;

init_tty (-1, 0, 0);

private define savestate ();

define exit_me ()
{
  ifnot (SAVEJS)
    {
    ifnot (NULL == struct_field_exists (s_, "_jsfn"))
      ifnot (access (s_._jsfn, F_OK|W_OK))
        () = remove (s_._jsfn);
    }
  else if (0 == qualifier_exists ("dontsave"))
    savestate ();
  
  if (length (s_._err))
    () = array_map (Integer_Type, &fprintf, stderr, "%s\n", list_to_array (s_._err));

  sock->send_int (EDVI_SOCKET, 111);
  sigprocmask (SIG_BLOCK, [SIGINT]);
  exit (EXIT_CODE);
}

EDVI_SOCKET = socket (PF_UNIX, SOCK_STREAM, 0);

forever
  {
  try
    connect (EDVI_SOCKET, EDVI_SOCKADDR);
  catch AnyError:
    continue;

   break;
  }

SAVEJS = sock->get_bit (EDVI_SOCKET);

define send_ans (ans)
{
  sock->send_int (EDVI_SOCKET, ans);
}

define get_ans ()
{
  return sock->get_int (EDVI_SOCKET);
}

define ineed (lib)
{
  try
    i->need (lib);
  catch ParseError:
    {
    () = array_map (Integer_Type, &fprintf, stderr, "%s\n", exception_to_array ());

    EXIT_CODE = 1;
    exit_me ();
    }
}

if (1 == __argc)
  {
  EXIT_CODE = 1;
  () = fprintf (stderr, "Wrong number of args, a filename is needed\n");
  exit_me (;dontsave);
  }

ineed ("json");

private variable
  _buf_,
  _len_,
  js_;

_buf_ = substr (path_extname (__argv[1]), 2, -1);

if (any (_buf_ == assoc_get_keys (FTYPES)))
  s_ = FTYPES[_buf_].init ();
else
  s_ = FTYPES["txt"].init ();

private define encode (s)
{
  variable enc = struct
    {
    st_ = s_.st_,
    ptr = s_.ptr,
    _modified = s_._modified,
    jslinlen = s_.jslinlen,
    _states = s_._states + 1,
    _state = s_._state,
    _fname = s_._fname,
    _access = s_._access,
    _gown = s_._gown,
    _uown = s_._uown,
    _indent = s_._indent,
    @s_.js_
    };  

  try
    {
    () = fseek (s_._jsfp, 0, SEEK_END);
    _buf_ = json_encode (enc);
    _len_ = strlen (_buf_) + (length (s_.jslinlen) ? 1 : 0);
    _len_ += (length (s_.jslinlen) ? s_.jslinlen[0] : 0);
    _len_ += strlen (string (_len_)) + 1;
    list_insert (s_.jslinlen, _len_);
    _buf_ = json_encode (struct {@enc, jslinlen = s_.jslinlen}); 
    _len_ = fprintf (s_._jsfp, "%s\n", _buf_);
    s_._states++;

    () = fflush (s_._jsfp);
    }
  catch Json_Parse_Error:
    {
    () = fprintf (stderr, "Error encoding edVi struct\n");
    EXIT_CODE = 1;
    exit_me ();
    }
}

s_.encode = &encode;

private define getjsline ()
{
  if (s_._state + 1 >= s_._states || 1 == length (s_.jslinlen))
    _len_ = 0;
  else
    _len_ = s_.jslinlen[s_._state + 1];

  () = fseek (s_._jsfp, _len_, SEEK_SET);
  () = fgets (&_buf_, s_._jsfp);
}

private define getjs (s)
{
  getjsline ();
  return json_decode (_buf_);
}

s_.getjs = &getjs;

private define savestate ()
{
  variable enc = struct
    {
    st_ = s_.st_,
    ptr = s_.ptr,
    _modified = 0,
    _states = 1,
    _state = 0,
    _fname = s_._fname,
    _access = s_._access,
    _gown = s_._gown,
    _uown = s_._uown,
    _indent = s_._indent,
    @s_.js_,
    jslinlen = {},
    };  

  () = fclose (s_._jsfp);
  s_._jsfp = fopen (s_._jsfn, "w");

  _buf_ = json_encode (enc); 
  _len_ = strlen (_buf_);
  _len_ += strlen (string (_len_)) + 1;
  list_insert (enc.jslinlen, _len_);
  _buf_ = json_encode (enc);

  () = fprintf (s_._jsfp, "%s\n", _buf_);
  () = fclose (s_._jsfp);
}

private define parse_file ()
{
  if (NULL == s_.parsefile ())
    throw Json_Parse_Error;

  s_.encode ();
  return s_.getjs ();
}

private define decode_js (s)
{
  try
    {
    if (0 == stat_file (s_._jsfn).st_size || qualifier_exists ("reparse"))
      {
      js_ = parse_file ();
      s_._states = js_._states;
      s_.jslinlen = js_.jslinlen;
      }
    else
      {
      js_ = s_.getjs ();
      
      s_.st_ = lstat_file (s_._fname); 

      if (js_.st_.st_size != s_.st_.st_size || js_.st_.st_mtime != s_.st_.st_mtime)
        {
        js_ =  parse_file ();
        s_._states = js_._states;
        s_.jslinlen = js_.jslinlen;
        }
      }

    s_.js_._lines = js_._lines;
    if (struct_field_exists (s_.js_, "_links"))
      s_.js_._links = js_._links;
    }
  catch Json_Parse_Error:
    {
    () = fprintf (stderr, "%s\n", strjoin (exception_to_array (), "\n"));
    () = fprintf (stderr, "Error Parsing json format\n");
    EXIT_CODE = 1;
    exit_me ();
    }
}

s_.decode = &decode_js;

private define app_err (msg)
{
  list_append (s_._err, msg);
}

private define gid_err (msg, retval)
{
  app_err (msg);
  return string (s_.st_.st_gid);
}

private define uid_err (msg, retval)
{
  app_err (msg);
  return string (s_.st_.st_uid);
}

private define getgrgid_ref (s, st)
{
  return getgrgid (st, &gid_err);
}

private define getpwuid_ref (s, st)
{
  return getpwuid (st, &uid_err);
}

s_.getgrgid = &getgrgid_ref;
s_.getpwuid = &getpwuid_ref,

s_._fname = __argv[1];
s_._jsfn = s_._fname + ".json";

s_._fname = -1 == access (s_._fname, F_OK) ? NULL : s_._fname;
s_._jsfn = -1 == access (s_._jsfn,  F_OK) ? NULL : s_._jsfn;

if (s_._jsfn == NULL == s_._fname)
  {
  () = fprintf (stderr, "%s: No such filename\n", s_._fname);
  EXIT_CODE = 1;
  exit_me (;dontsave);
  }

if (NULL == s_._fname)
  {
  s_._fname = sprintf ("%s/%s", path_dirname (s_._jsfn), path_sans_extname (s_._jsfn));
  s_._fnfp = fopen (s_._fname, "w+");
  }
else
  s_._fnfp = fopen (s_._fname, "r+");

if (NULL == s_._fnfp)
  {
  () = fprintf (stderr, "%s: cant open, ERRNO:\n", s_._fnfp);
  EXIT_CODE = 1;
  exit_me (;dontsave);
  }

if (NULL == s_._jsfn)
  {
  s_._jsfn = s_._fname + ".json";
  s_._jsfp = fopen (s_._jsfn, "w+");
  }
else
  s_._jsfp = fopen (s_._jsfn, "r+");

if (NULL == s_._jsfp)
  {
  () = fprintf (stderr, "%s: cant open, ERRNO:\n", s_._jsfp);
  EXIT_CODE = 1;
  exit_me (;dontsave);
  }

s_.st_ = lstat_file (s_._fname);
s_._access = sprintf ("(0%o/%s)", modetoint (s_.st_.st_mode), stat_mode_to_string (s_.st_.st_mode));
s_._gown = s_.getgrgid (s_.st_.st_gid);
s_._uown = s_.getpwuid (s_.st_.st_uid);

ifnot (stat_file (s_._jsfn).st_size)
  s_.decode ();
else
  {
  while (-1 != fgets (&_buf_, s_._jsfp))
    s_._states++;
    try
      {
      js_ = json_decode (_buf_);
      s_._state  = 0;
      s_.jslinlen = js_.jslinlen;

      if (js_.st_.st_size == s_.st_.st_size && js_.st_.st_mtime == s_.st_.st_mtime)
        {
        s_.js_._lines = js_._lines;
        if (struct_field_exists (s_.js_, "_links"))
          s_.js_._links = js_._links;
        }
      else
        s_.decode ();
      }
    catch Json_Parse_Error:
      {
      () = fprintf (stderr, "%s: Error Parsing json format\n", s_._jsfn);
      EXIT_CODE = 1;
      exit_me (;dontsave);
      }
  }

sigprocmask (SIG_UNBLOCK, [SIGINT]);

send_ans (0);

s_.edVi ();

sigprocmask (SIG_BLOCK, [SIGINT]);

exit_me ();
