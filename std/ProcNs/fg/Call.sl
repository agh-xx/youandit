sigprocmask (SIG_BLOCK, [SIGINT]);

__set_argc_argv (__argv[[1:]]);

private variable myns = sprintf ("%s/..", path_dirname (__FILE__));

variable
  ask,
  getch,
  highlight,
  print_err,
  print_out,
  getchar_lang,
  print_in_new_wind,
  STDERRFP = NULL,
  STDOUTFP = NULL,
  ALARM = NULL,
  EVAL_ERR = 0,
  EXIT_CODE = 0,
  CLEAR = getenv ("CLEAR"),
  CHDIR = getenv ("CHDIR"),
  INFODIR = getenv ("INFODIR"),
  EXECDIR = getenv ("EXECDIR"),
  STDERR = getenv ("STDERR"),
  STDOUT = getenv ("STDOUT"),
  ROOTDIR = getenv ("ROOTDIR"),
  BINDIR = getenv ("BINDIR"),
  TEMPDIR = getenv ("TEMPDIR"),
  DATADIR = getenv ("DATADIR"),
  DATASHAREDIR = getenv ("DATASHAREDIR"),
  DEBUG = atoi (getenv ("DEBUG")),
  LINES = atoi (getenv ("LINES")),
  FIFO_ROOT = getenv ("FIFO_ROOT"),
  LOAD_PATH = getenv ("LOAD_PATH"),
  NOWRITECL = getenv ("NOWRITECL"),
  COLUMNS = atoi (getenv ("COLUMNS")),
  IMPORT_PATH = getenv ("IMPORT_PATH"),
  ROOT_PID = atoi (getenv ("ROOT_PID")),
  SRV_SOCKADDR = getenv ("SRV_SOCKADDR"),
  SRV_SOCKET = @FD_Type (atoi (getenv ("SRV_FILENO"))),
  INTERACTIVE = (INTERACTIVE = getenv ("INTERACTIVE"), NULL == INTERACTIVE
    ? 0
    : atoi (INTERACTIVE)),
  TTY_INITED = 0,
  DONTRECONNECT = 1,
  MSGROW = LINES - 1,
  PROMPTROW = LINES - 2,
  PRINT_IN_NEW_WINDOW = 0,
  FDFIFO = open (FIFO_ROOT, O_RDWR),
  HEADER = sprintf ("Interactive Session for %s", __argv[0]);

set_slang_load_path (LOAD_PATH);

set_import_module_path (IMPORT_PATH);

putenv (sprintf ("PATH=%s", getenv ("PATH")));

() = evalfile (sprintf ("%s/lib/dirs", myns));

import ("socket");
import ("getkey");
import ("fork");

define open_file (fname)
{
  return fopen (fname, qualifier ("mode", "a+"));
}

% This should not fail, if yes then no error will be visible
STDERRFP = open_file (STDERR);
if (NULL == STDERRFP)
  exit (1);

% This should not fail, but if so,
% then (at least) the error will be visible throw messages function
try
  {
  () = evalfile (sprintf ("%s/SockNs/sock_funcs", STDNS), "sock");
  () = evalfile (sprintf ("%s/SrvNs/Client", STDNS), "srv");
  () = evalfile (sprintf ("%s/InputNs/input", STDNS), "input");
  () = evalfile (sprintf ("%s/conf/KeysNs/Init", STDNS), "keys");
  () = evalfile (sprintf ("%s/I_Ns/lib/except_to_arr", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/lib/std", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/lib/need", STDNS), "i");
  () = evalfile (sprintf ("%s/I_Ns/init/typedefs", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/init/sysproc", STDNS));
  () = evalfile ("cmdopt");

  if (DEBUG)
    () = evalfile (sprintf ("%s/SrvNs/SlsmgMsgProc_dbg", STDNS), "srv");
  }
catch AnyError:
  {
  () = fprintf (STDERRFP, "\n__\nERROR during evaluation of std libs\n");

  () = array_map (Integer_Type, &fprintf, STDERRFP, "%s\n",
      strchop (sprintf ("Caught an exception:%s\n\
        Message:     %s\n\
        Object:      %S\n\
        Function:    %s\n\
        Line:        %d\n\
        File:        %s\n\
        Description: %s\n\
        Error:       %d\n",
        _push_struct_field_values (__get_exception_info)), '\n', 0));

  () = fclose (STDERRFP);
  exit (1);
  }

STDOUTFP = open_file (STDOUT; mode = NULL == CLEAR ? "a+" : "w");
if (NULL == STDOUTFP)
  {
  srv->send_msg (sprintf ("%s: couldn't open file, ERRNO: %s", STDOUT,
        errno_string (errno)), -1);
  exit (1);
  }

define exit_me ()
{
  sigprocmask (SIG_BLOCK, [SIGINT]);

  if (PRINT_IN_NEW_WINDOW)
    {
    srv->write_str_at ("Hit Any Key To Exit ", 0, PROMPTROW, 0);
    srv->refresh ();
    () = (@getch);
    }
 
  ifnot (NULL == ALARM)
    () = write (FDFIFO, "ok");
 
  ifnot (NULL == STDOUTFP)
    () = fclose (STDOUTFP);

  ifnot (NULL == STDERRFP)
    () = fclose (STDERRFP);

  exit (EXIT_CODE);
}

define ineed (lib)
{
  try
    i->need (lib);
  catch ParseError:
    {
    () = array_map (Integer_Type, &fprintf, STDERRFP, "%s\n", exception_to_array ());

    EXIT_CODE = 1;
    exit_me ();
    }
}

try
  {
  () = kill (ROOT_PID, SIGALRM);
  ALARM = 1;
 
  () = evalfile (sprintf ("%s/share/print", myns));

  () = array_map (Integer_Type, &evalfile,
    array_map (String_Type, &sprintf, "%s/fg/%s", myns,
      ["help", "viewexception", "ask", "printrefs"]));

  if (INTERACTIVE)
    {
    () = evalfile (sprintf ("%s/fg/header", myns));
    srv->refresh ();
    PRINT_IN_NEW_WINDOW = 1;
    }

  }
catch ParseError:
  {
  EXIT_CODE = 1;
  () = array_map (Integer_Type, &fprintf, STDERRFP, "%s\n",
    exception_to_array ());

  srv->send_msg (sprintf ("%s: Evaluation Error", __argv[0]), -1);

  exit_me ();
  }

define eval_script ()
{
  try
    {
    () = evalfile (sprintf ("%s/%s.slc", EXECDIR, __argv[0]), __argv[0]);
    }
  catch ParseError:
    {
    () = array_map (Integer_Type, &fprintf, STDERRFP, "%s\n",
      exception_to_array ());
 
    view_exception (["EVALUATION ERROR", exception_to_array ()]);
 
    (@print_err) (sprintf ("%s: Evaluation Error", __argv[0]));
 
    return NULL;
    }

  variable ref = __get_reference (sprintf ("%s->main", __argv[0]));
  if (NULL == ref)
    {
    srv->send_msg (sprintf ("%s: no main () function found", __argv[0]), -1);
    return NULL;
    }

  return ref;
}

define sigint_handler (sig)
{
  () = array_map (Integer_Type, &fprintf, [STDERRFP, STDOUTFP],
  "%s: proccess interrupted by the user\n", __argv[0]);
  exit_me ();
}

signal (SIGINT, &sigint_handler);

define exec_ref (ref)
{
  try
    return (@ref);
  catch AnyError:
    {
    () = array_map (Integer_Type, &fprintf, STDERRFP, "%s\n",
      exception_to_array ());
 
    view_exception (["RUNTIME ERROR", exception_to_array ()]);
 
    return NULL;
    }
}

define proc_main ()
{
  variable
    i,
    ref,
    index,
    write_cl,
    execdirs = [PERSCOMMANDSDIR, USRCOMMANDSDIR, COREDIR];
 
  ifnot (NULL == CHDIR)
    {
    if (-1 == chdir (CHDIR))
      {
      srv->send_msg (sprintf ("couldn't change dir to : %s", CHDIR), -1);

      () = fprintf (STDERRFP, "%s: couldn't change dir to : %s", __argv[0], CHDIR);
      EXIT_CODE = 1;
      exit_me ();
      }
    }

  getch = &input->getchar;
  getchar_lang = &input->en_getch;
  init_tty (-1, 0, 0);

  ask = &f_ask;
  if (NULL == EXECDIR)
    _for i (0, 2)
      ifnot (access (sprintf ("%s/%s.slc", execdirs[i], __argv[0]), F_OK))
        {
        EXECDIR = execdirs[i];
        break;
        }
 
  if (NULL == EXECDIR)
    {
    (@print_err) (sprintf ("%s: No such application", __argv[0]));
    EXIT_CODE = 1;
    exit_me ();
    }

  if (NULL == INFODIR)
    INFODIR = sprintf ("%s/../info/%s", EXECDIR, __argv[0]);;

  ref = eval_script ();
  if (NULL == ref)
    {
    EXIT_CODE = 1;
    exit_me ();
    }

  if (NULL == NOWRITECL)
    () = fprintf (STDOUTFP, "%s\n[%s]$%s\n", repeat ("_", COLUMNS), getcwd (),
      strjoin (__argv, " "));
 
  sigprocmask (SIG_UNBLOCK, [SIGINT]);
  EXIT_CODE = exec_ref (ref);
  sigprocmask (SIG_BLOCK, [SIGINT]);

  if (NULL == EXIT_CODE || -1 == EXIT_CODE)
    EXIT_CODE = 1;

  exit_me ();
}

proc_main ();
