if (length (where ("--help" == __argv)))
  {
  () = array_map (Integer_Type, &fprintf, stdout, "%s\n",
    [path_basename (__argv[0]) + " [Option]", "",
    "Options:", "--debug  Debug this program",
    "--install install this program",
    "--no-modules don't build modules when use --install",
    "--app=appname:Some_Type start programm with `app'"]);
  exit (0);
  }

if (NULL == getenv ("TERM"))
  {
  () = fputs ("TERM ENVIRONMENT VARIABLE isn't set\n", stderr);
  exit (1);
  }

ifnot (getuid ())
  {
  () = fputs ("You can't run this script as root\n", stderr);
  exit (1);
  }

if (NULL == getenv ("HOME"))
  {
  () = fputs ("HOME environment variable isn't set\n", stderr);
  exit (1);
  }

if (NULL == getenv ("LANG"))
  {
  () = fputs ("LANG environment variable isn't set\n", stderr);
  exit (1);
  }

ifnot (any (array_map (Integer_Type, &string_match,
      getenv ("LANG"), ["UTF8", "utf8", "utf-8", "UTF-8"])))
  {
  () = fprintf (stderr, ("locale %s: isn't UTF-8 (Unicode)", getenv ("LANG")));
  exit (1);
  }

if ("dvtm-256color" == getenv ("TERM"))
  () = fputs ("\n", stdout);

% those should be constant
variable
  ROOT_PID = getpid (),
  ROOTDIR = (ROOTDIR = path_concat (getcwd (), path_dirname (__FILE__)),
    sprintf ("%s/root", ROOTDIR[[-2:]] == "/."
      ? substr (ROOTDIR, 1, strlen (ROOTDIR) - 2)
      : ROOTDIR)),
  SOURCEDIR = sprintf ("%s/../sources", ROOTDIR),
  STDNS =  sprintf ("%s/me", ROOTDIR),
  USRNS = sprintf ("%s/you", ROOTDIR),
  PERSNS = sprintf ("%s/she", ROOTDIR),
  STDLIBDIR = sprintf ("%s/lib", STDNS),
  USRLIBDIR = sprintf ("%s/lib", USRNS),
  PERSLIBDIR = sprintf ("%s/lib", PERSNS),
  STDTYPESDIR = sprintf ("%s/types", STDNS),
  USRTYPESDIR = sprintf ("%s/types", USRNS),
  PERSTYPESDIR = sprintf ("%s/types/", PERSNS),
  COREDIR = sprintf ("%s/commands/scripts", STDNS),
  USRCOMMANDSDIR = sprintf ("%s/commands/usr/scripts", USRNS),
  PERSCOMMANDSDIR = sprintf ("%s/commands/scripts", PERSNS),
  TMPDIR = sprintf ("%s/tmp/%d", ROOTDIR, ROOT_PID),
  BGDIR = sprintf ("%s/_pids/bg", TMPDIR);

variable
  DEV = 1 < __argc && length (where ("--dev" == __argv)) ? 1 : 0,
  DEBUG = 1 < __argc && length (where ("--debug" == __argv)) ? 1 : 0;

if (-1 == access (ROOTDIR, F_OK))
  {
  if (-1 == mkdir (ROOTDIR))
    {
    () = fprintf (stderr, "%s: cannot create directory\n:ERRNO: %s\n",
      ROOTDIR, errno_string (errno));
    exit (1);
    }
  }
else if (-1 == access (ROOTDIR, R_OK|W_OK))
  {
  () = fprintf (stderr, "%s: IS NOT WRITABLE|READABLE\n:ERRNO: %s\n",
    ROOTDIR, errno_string (errno));
  exit (1);
  }

if (any (-1 == array_map (Integer_Type, &access, [ROOTDIR, STDNS, USRNS, PERSNS], F_OK))
  || (1 < __argc && length (where ("--install" == __argv))))
    {
    $1 = length (where ("--no-modules" == __argv));
    () = evalfile (sprintf ("%s/InstallMe/install_me", SOURCEDIR), "inst");
    }

set_slang_load_path (sprintf ("%s%c%s%c%s",
  STDLIBDIR, path_get_delimiter (),
  USRLIBDIR, path_get_delimiter (),
  PERSLIBDIR));

set_import_module_path (sprintf (
  "%s/modules%c%s/modules%c%s/modules",
  STDNS, path_get_delimiter (),
  USRNS, path_get_delimiter (),
  PERSNS));

define exception_to_array ()
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

try
  {
  array_map (Void_Type, &import, ["fork", "socket"]);
  () = evalfile (sprintf ("%s/I_Ns/lib/std", STDNS));
  }
catch ImportError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
    ["IMPORT ERROR", exception_to_array]);
  exit (1);
  }

if (NULL == which ("stty"))
  {
  () = fputs ("stty executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

if (NULL == which ("ps"))
  {
  () = fputs ("ps executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

if (NULL == which ("sudo"))
  {
  () = fputs ("sudo executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

() = evalfile (sprintf ("%s/I_Ns/i", STDNS));
