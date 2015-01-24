sigprocmask (SIG_BLOCK, [SIGINT]);
sigprocmask (SIG_UNBLOCK, [SIGALRM]);

__set_argc_argv (__argv[[1:]]);

private variable myns = sprintf ("%s/..", path_dirname (__FILE__));

variable
  ask,
  getch,
  highlight,
  print_err,
  print_norm,
  print_warn,
  getchar_lang,
  STDERRFP = NULL,
  STDOUTFP = NULL,
  STDOUT,
  ALARM = NULL,
  EXIT_CODE = 0,
  EVAL_ERR = 0,
  CHDIR = getenv ("CHDIR"),
  INFODIR = getenv ("INFODIR"),
  EXECDIR = getenv ("EXECDIR"),
  STDERR = getenv ("STDERR"),
  ROOTDIR = getenv ("ROOTDIR"),
  DEBUG = atoi (getenv ("DEBUG")),
  LINES = atoi (getenv ("LINES")),
  ORIG_FNAME = getenv ("STDOUT"),
  FIFO_ROOT = getenv ("FIFO_ROOT"),
  LOAD_PATH = getenv ("LOAD_PATH"),
  NOWRITECL = getenv ("NOWRITECL"),
  COLUMNS = atoi (getenv ("COLUMNS")),
  IMPORT_PATH = getenv ("IMPORT_PATH"),
  ROOT_PID = atoi (getenv ("ROOT_PID")),
  SRV_SOCKADDR = getenv ("SRV_SOCKADDR"),
  SRV_SOCKET = @FD_Type (atoi (getenv ("SRV_FILENO"))),
  TTY_INITED = 0,
  DONTRECONNECT = 1,
  MSGROW = LINES - 1,
  PROMPTROW = LINES - 2,
  FDFIFO = open (FIFO_ROOT, O_RDWR);

define exit_me ()
{
  ifnot (EVAL_ERR)
    ifnot (NULL == STDOUTFP)
      () = fprintf (STDOUTFP, "EXIT_CODE FROM BACKGROUND JOB: %d\n", EXIT_CODE);
 
  ifnot (NULL == STDOUTFP)
    () = fclose (STDOUTFP);

  ifnot (NULL == STDERRFP)
    () = fclose (STDERRFP);

  forever
    sleep (100000);
}

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
  {
  (EXIT_CODE, EVAL_ERR) = 1, 1;
  exit_me ();
  }

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
  EVAL_ERR = 1;
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

  exit_me ();
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
  () = evalfile (sprintf ("%s/share/print", myns));

  () = array_map (Integer_Type, &evalfile,
    array_map (String_Type, &sprintf, "%s/bg/%s", myns, ["help", "ask", "printrefs"]));
  }
catch ParseError:
  {
  EVAL_ERR = 1;
  () = fprintf (STDERRFP, "\n%s\n%s: ERROR during evaluation of proc libs\n",
    repeat ("_", COLUMNS), __argv[0]);
  () = array_map (Integer_Type, &fprintf, STDERRFP, "%s\n",
    exception_to_array ());
  exit_me ();
  }

STDOUT = __argv [where (strncmp (__argv, "--constant", strlen ("--constant")))];
if (length (STDOUT) < __argc)
  {
  __set_argc_argv (STDOUT);
  STDOUT = ".CONSTANT";
  }
else
  STDOUT = ".START";

STDOUT = sprintf ("%s/%d%s", BGDIR, getpid (), STDOUT);
STDOUTFP = open_file (STDOUT; mode = "w");

if (NULL == STDOUTFP)
  {
  EVAL_ERR = 1;
  (@print_err) (sprintf ("\n%s\n%s: couldn't open file, ERRNO: %s", repeat ("_", COLUMNS),
     STDOUT, errno_string (errno)));
  srv->send_msg_and_refresh ("RUNTIME ERROR while executing background job", -1);
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
    EVAL_ERR = 1;
    (@print_err) (sprintf ("\n%s\n%s: ERROR during evaluation of %s/%s script\n",
     repeat ("_", COLUMNS), __argv[0], EXECDIR, __argv[0]));
    () = array_map (Integer_Type, &fprintf, STDERRFP, "%s\n", exception_to_array ());
    srv->send_msg_and_refresh ("RUNTIME ERROR while executing background job", -1);
    return NULL;
    }

  variable ref = __get_reference (sprintf ("%s->main", __argv[0]));
  if (NULL == ref)
    {
    EVAL_ERR = 1;
    (@print_err) (sprintf ("\n%s\n%s: no main () function found", repeat ("_", COLUMNS),
       __argv[0]));
     srv->send_msg_and_refresh ("RUNTIME ERROR while executing background job", -1);
    return NULL;
    }

  return ref;
}

define exec_ref (ref)
{
  try
    return (@ref);
  catch AnyError:
    {
    (@print_err) (sprintf ("\n%s\nRUNTIME ERROR while executing background job",
      repeat ("_", COLUMNS)));
    () = array_map (Integer_Type, &fprintf, STDERRFP, "%s\n",
      exception_to_array ());
    srv->send_msg_and_refresh ("RUNTIME ERROR while executing background job", -1);
    return NULL;
    }
}

define proc_main ()
{
  variable
    ref,
    index,
    write_cl;
 
  ifnot (NULL == CHDIR)
    {
    if (-1 == chdir (CHDIR))
      {
      EXIT_CODE = 1;
      (@print_err) (sprintf ("\n%s\n%s: couldn't change dir to : %s",
        repeat ("_", COLUMNS), __argv[0], CHDIR));
      srv->send_msg_and_refresh ("RUNTIME ERROR while executing background job", -1);
      exit_me ();
      }
    }

  getch = &input->getchar;
  getchar_lang = &input->en_getch;
  init_tty (-1, 0, 0);

  ask = &f_ask;

  if (NULL == EXECDIR)
    EXECDIR = COREDIR;

  if (NULL == INFODIR)
    INFODIR = sprintf ("%s/../info/%s", EXECDIR, __argv[0]);;

  if (-1 == access (sprintf ("%s/%s.slc", EXECDIR, __argv[0]), F_OK))
    {
    EXIT_CODE = 1;
    (@print_err) (sprintf ("\n%s\n%s: No such application", __argv[0],
     repeat ("_", COLUMNS)));
    srv->send_msg_and_refresh ("RUNTIME ERROR while executing background job", -1);
    exit_me ();
    }

  ref = eval_script ();
  if (NULL == ref)
    exit_me ();

  if (NULL == NOWRITECL)
    (@print_norm) (sprintf ("%s\n[%s]$%s\n", repeat ("_", COLUMNS), getcwd (),
      strjoin (__argv, " ")));
 
  EXIT_CODE = exec_ref (ref);
 
  if (".START" == path_extname (STDOUT))
    if (-1 == rename (STDOUT, substr (STDOUT, 1, strlen (STDOUT) - 6)))
      (@print_err) (sprintf ("Background Error while renaming %s", STDOUT));
    else
      STDOUT = substr (STDOUT, 1, strlen (STDOUT) - 6);

  if (NULL == EXIT_CODE)
    EXIT_CODE = 1;

  exit_me ();
}

define sigalarm_handler (sig)
{
  ifnot (access (STDOUT, F_OK))
    {
    variable
      ar = readfile (STDOUT);

    if (length (ar))
      writefile (ar, ORIG_FNAME;mode="a");

    () = remove (STDOUT);
    }

  exit (EXIT_CODE);
}

signal (SIGALRM, &sigalarm_handler);

proc_main ();
