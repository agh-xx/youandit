new_exception ("Return", RunTimeError, "Return value");
new_exception ("Break", RunTimeError, "Break script and return");
new_exception ("GotoPrompt", RunTimeError, "Break script and go to prompt");

$9 = NULL;

variable
  CW,
  root,
  PROC_SOCKET,
  PROC_PID = NULL,
  PROC_SOCKADDR = sprintf ("%s/_pipes/proc.sock", TMPDIR),
  SRV_SOCKET,
  SRV_PID = NULL,
  SRV_SOCKADDR = sprintf ("%s/_pipes/srv.sock", TMPDIR),
  LINES = (LINES = getenv ("LINES"), NULL == LINES ? 3 : atoi (LINES)),
  COLUMNS = (COLUMNS = getenv ("COLUMNS"), NULL == COLUMNS ? 3 : atoi (COLUMNS)),
  AVAILABLE_LINES = NULL != LINES ? LINES - 3 : 0,
  PROMPTROW = NULL != LINES ? LINES - 2 : 0,
  MSGROW = NULL != LINES  ? LINES - 1 : 0,
  TOPROW = 0,
  CORECOMS,
  USRCOMS,
  PERSCOMS,
  COMMANDS,
  SCRATCHBUF = sprintf ("%s/_scratch/scratchbuf.txt", TMPDIR),
  FIFO_ROOT = sprintf ("%s/_pipes/root.fifo", TMPDIR),
  FD_FIFO_ROOT,
  TTY_INITED = 0,
  REGS = Assoc_Type[Array_Type],
  SLSH_EXEC,
  SUDO_EXEC,
  getchar_lang,
  getch;

try
  {
  () = evalfile (sprintf ("%s/I_Ns/lib/exit", STDNS), "root");
  }
catch ParseError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
    ["PARSE ERROR", exception_to_array ()]);
  exit (1);
  }

SLSH_EXEC = which ("slsh");
SUDO_EXEC = which ("sudo");

ifnot (isdirectory (sprintf ("%s/tmp", ROOTDIR)))
  if (-1 == mkdir (sprintf ("%s/tmp", ROOTDIR)))
    root->exit_me (1, sprintf ("Cannot create tmp directory %s/tmp, ERRNO: %s",
      ROOTDIR, errno_string (errno)));

if (-1 == mkdir (TMPDIR))
  root->exit_me (1, sprintf ("Cannot create directory %s, ERRNO: %s",
      TMPDIR, errno_string (errno)));

if (-1 == mkdir (sprintf ("%s/_pids", TMPDIR)))
  root->exit_me (1, sprintf ("Cannot create directory %s, ERRNO: %s",
    sprintf ("%s/_pids", TMPDIR), errno_string (errno)));

if (-1 == mkdir (BGDIR))
  root->exit_me (1, sprintf ("Cannot create directory %s, ERRNO: %s",
      BGDIR, errno_string (errno)));

if (-1 == mkdir (sprintf ("%s/_pipes", TMPDIR)))
  root->exit_me (1, sprintf ("Cannot create directory %s, ERRNO: %s",
    sprintf ("%s/_pipes", TMPDIR), errno_string (errno)));

if (-1 == mkdir (sprintf ("%s/_scratch", TMPDIR)))
  root->exit_me (1, sprintf ("Cannot create pager directory %s, ERRNO: %s",
    sprintf ("%s/_scratch", TMPDIR), errno_string (errno)));

if (DEBUG)
  if (-1 == mkdir (sprintf ("%s/_profile", TMPDIR)))
    root->exit_me (1, sprintf ("Cannot create profile directory %s, ERRNO: %s",
      sprintf ("%s/_profile", TMPDIR), errno_string (errno)));

define dev_on ()
{
  () = evalfile (sprintf ("%s/I_Ns/dev/dev_on", STDNS));
}

try
  {
  import ("getkey");

  () = evalfile (sprintf ("%s/init/typedefs", path_dirname (__FILE__)));
  () = evalfile (sprintf ("%s/init/sysproc", path_dirname (__FILE__)), "i");
  () = evalfile (sprintf ("%s/init/colors_var", path_dirname (__FILE__)));
  () = evalfile (sprintf ("%s/conf/etc/env", STDNS));
  () = evalfile (sprintf ("%s/InputNs/input", STDNS), "input");
  () = evalfile (sprintf ("%s/conf/KeysNs/Init", STDNS), "keys");
  () = evalfile (sprintf ("%s/RootNs/loaded/load", STDNS));
  () = evalfile (sprintf ("%s/SockNs/sock_funcs", STDNS), "sock");
  () = evalfile (sprintf ("%s/SrvNs/Init", STDNS));
  () = evalfile (sprintf ("%s/SrvNs/Client", STDNS), "srv");
  () = evalfile (sprintf ("%s/ProcNs/Init", STDNS));
  () = evalfile (sprintf ("%s/ProcNs/Client", STDNS));
  () = evalfile (sprintf ("%s/ProcNs/lib/call", STDNS), "proc");
  () = evalfile (sprintf ("%s/ProcNs/lib/get", STDNS), "proc");
  () = evalfile (sprintf ("%s/RootNs/Init", STDNS), "root");
  () = evalfile (sprintf ("%s/I_Ns/init/sigalarm_handler", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/init/sigwinch_handler", STDNS));

  if (DEV)
    dev_on ();

  }
catch RunTimeError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
    ["RUNTIME ERROR", exception_to_array ()]);

  root->exit_me (1, NULL);
  }
catch ParseError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
    ["PARSE ERROR", exception_to_array ()]);
 
  root->exit_me (1, NULL);
  }
catch ImportError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
    ["IMPORT ERROR", exception_to_array ()]);
 
  root->exit_me (1, NULL);
  }

srv->init ();
() = evalfile (sprintf ("%s/init/colors", path_dirname (__FILE__)));

(TTY_INITED, getchar_lang, getch) = (@(__get_reference ("input->TTY_Inited")),
  &input->en_getch, &input->getchar);

init_tty (-1, 0, 0);

$9 = 1;

() = mkfifo (FIFO_ROOT, S_IWUSR|S_IRUSR);

FD_FIFO_ROOT = open (FIFO_ROOT, O_RDWR);

sigprocmask (SIG_SETMASK, [SIGINT]);

srv->refresh ();

try
  {
  root = root->init ();
  root.func.call ("rehash"; dont_goto_prompt);
  }
catch AnyError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n", exception_to_array ());
  root->exit_me (1, NULL);
  }

if (24 > AVAILABLE_LINES)
  root->exit_me (1, "I DONT REALLY WANT TO CONTINUE WITH LESS THAN 24 LINES");

if (82 > COLUMNS)
  root->exit_me (1, "I DONT REALLY WANT TO CONTINUE WITH LESS THAN 82 COLUMNS");

if (NULL == root.addwind ("root", "Root_Type";
    typedir = sprintf ("%s/I_Ns/types/", STDNS), msgarray = "Root Window Buffer",
    dont_draw))
  root->exit_me (1, NULL);

if (NULL == root.addwind ("main", "Shell_Type";dont_draw))
  root->exit_me (1, NULL);

$9 = wherenot (strncmp (__argv, "--app=", 6));
if (length ($9))
  {
  $9 = strchop (substr (__argv[$9[0]], 7,  -1),  ':', 0);

  if (NULL == root.addwind ($9[0], $9[1]; dont_draw))
    root->exit_me (1, NULL);
 
  CW = root.windows[$9[0]];
  }
else
  CW = root.windows["main"];

__uninitialize (&$9);

%root.user.call ("intro", "--pager");
%root.user.call ("intro", "--pager";drawwind);
root.user.call ("intro"; drawwind, send_break);
