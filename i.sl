$9 = NULL;

variable
  CW,
  root,
  PROC_SOCKET,
  PROC_PID = NULL,
  PROC_SOCKADDR = sprintf ("%s/_pipes/proc.sock", TEMPDIR),
  SRV_SOCKET,
  SRV_PID = NULL,
  SRV_SOCKADDR = sprintf ("%s/_pipes/srv.sock", TEMPDIR),
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
  SCRATCHBUF = sprintf ("%s/_scratch/scratchbuf.txt", TEMPDIR),
  FIFO_ROOT = sprintf ("%s/_pipes/root.fifo", TEMPDIR),
  FD_FIFO_ROOT,
  TTY_INITED = 0,
  REGS = Assoc_Type[Array_Type],
  SLSH_EXEC,
  SUDO_EXEC,
  getchar_lang,
  getch,
  mytypename = "i",
  maintypename = "main";

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

define dev_on ()
{
  () = evalfile (sprintf ("%s/I_Ns/dev/dev_on", STDNS));
}

try
  {
  import ("getkey");

  () = evalfile (sprintf ("%s/I_Ns/init/typedefs", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/init/exceptions", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/init/sysproc", STDNS), "i");
  () = evalfile (sprintf ("%s/I_Ns/init/colors_var", STDNS));
  () = evalfile (sprintf ("%s/conf/etc/env", STDNS));
  () = evalfile (sprintf ("%s/InputNs/input", STDNS), "input");
  () = evalfile (sprintf ("%s/conf/KeysNs/Init", STDNS), "keys");
  () = evalfile (sprintf ("%s/RootNs/loaded/load", STDNS));
  () = evalfile (sprintf ("%s/SockNs/sock_funcs", STDNS), "sock");
  () = evalfile (sprintf ("%s/SrvNs/Init", STDNS));
  () = evalfile (sprintf ("%s/SrvNs/Client", STDNS), "srv");
  () = evalfile (sprintf ("%s/ProcNs/Init", STDNS));
  () = evalfile (sprintf ("%s/ProcNs/Client", STDNS));
  () = evalfile (sprintf ("%s/ProcNs/lib/get", STDNS), "proc");
  () = evalfile (sprintf ("%s/ProcNs/lib/call", STDNS), "proc");
  () = evalfile (sprintf ("%s/ProcNs/lib/edVi", STDNS), "proc");
  () = evalfile (sprintf ("%s/RootNs/Init", STDNS), "root");
  () = evalfile (sprintf ("%s/I_Ns/ftypes/Init", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/init/sigalarm_handler", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/init/sigwinch_handler", STDNS));
  () = evalfile (sprintf ("%s/I_Ns/nss/Init", STDNS), "i");
  () = evalfile (sprintf ("%s/I_Ns/lib/need", STDNS), "i");

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

() = evalfile (sprintf ("%s/I_Ns/init/colors", STDNS));

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

if (92 > COLUMNS)
  root->exit_me (1, "I DONT REALLY WANT TO CONTINUE WITH LESS THAN 92 COLUMNS");

if (NULL == root.addwind (mytypename, sprintf ("%s_Type", strup (mytypename));
    typedir = sprintf ("%s/I_Ns/types/", STDNS), msgarray = "Distribution Managment Buffer",
    dont_draw))
  root->exit_me (1, NULL);

define ineed ()
{
  variable args = __pop_list (_NARGS);
  try
    i->need (__push_list (args));
  catch ParseError:
    {
    writefile (exception_to_array (), root.windows[mytypename].msg;mode = "a");
    throw ParseError, __get_exception_info.message;
    }
}

if (NULL == root.addwind (maintypename, "Shell_Type";dont_draw))
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

array_map (Void_Type, &__uninitialize, [&$1, &$2, &$3, &$4, &$8, &$9]);

root.user.call ("intro"; drawwind, send_break);
