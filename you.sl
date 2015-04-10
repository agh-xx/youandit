#!/usr/bin/env slsh
if (length (where ("--help" == __argv)))
  {
  () = array_map (Integer_Type, &fprintf, stdout, "%s\n",
    [path_basename (__argv[0]) + " [Option]", "",
    "Options:",
    "--debug  debug this program",
    "--dev  turn on development features",
    "--install  install this program",
    "--no-modules  don't build modules when use --install",
    "--app=appname:Some_Type  start program with `app'"]);
  exit (0);
  }

ifnot (getuid ())
  {
  () = fputs ("You can't run this script as root\n", stderr);
  exit (1);
  }

if (NULL == getenv ("TERM"))
  {
  () = fputs ("TERM environment variable isn't set\n", stderr);
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
  () = fprintf (stderr, ("locale %s: isn't UTF-8 (Unicode)\n", getenv ("LANG")));
  exit (1);
  }

if ("dvtm-256color" == getenv ("TERM"))
  () = fputs ("\n", stdout);

$5 = fopen ("/etc/passwd", "r");

if (NULL == $5)
  {
  () = fputs ("/etc/passwd is not readable, this shouldn't be happen\n", stderr);
  exit (1);
  }

$6 = NULL;

while (-1 != fgets (&$7, $5))
  {
  $8 = strchop ($7, ':', 0);
  if (string (getuid ()) == $8[2])
    {
    $6 = $8[0];
    break;
    }
  }

if (NULL == $6)
  {
  () = fprintf (stderr, "cannot find your UID %d in /etc/passwd, who are you?\n",
    getuid ());
  exit (1);
  }

% those should be constant
variable
  ROOT_PID = getpid (),
  WHOAMI = $6,
  ROOTDIR = (ROOTDIR = path_concat (getcwd (), path_dirname (__FILE__)),
    ROOTDIR[[-2:]] == "/." ? substr (ROOTDIR, 1, strlen (ROOTDIR) - 2)
      : ROOTDIR),
  BINDIR = sprintf ("%s/bin", ROOTDIR),
  DATADIR = sprintf ("%s/data/%s", ROOTDIR, WHOAMI),
  DATASHAREDIR = sprintf ("%s/data/share", ROOTDIR),
  MODULEDIR = sprintf ("%s/modules", ROOTDIR),
  SOURCEDIR = sprintf ("%s/dist", ROOTDIR),
  STDNS =  sprintf ("%s/std", BINDIR),
  USRNS = sprintf ("%s/usr", BINDIR),
  PERSNS = sprintf ("%s/local", BINDIR),
  STDLIBDIR = sprintf ("%s/lib", STDNS),
  USRLIBDIR = sprintf ("%s/lib", USRNS),
  PERSLIBDIR = sprintf ("%s/lib", PERSNS),
  STDTYPESDIR = sprintf ("%s/types", STDNS),
  USRTYPESDIR = sprintf ("%s/types", USRNS),
  PERSTYPESDIR = sprintf ("%s/types/", PERSNS),
  COREDIR = sprintf ("%s/commands/scripts", STDNS),
  USRCOMMANDSDIR = sprintf ("%s/commands/usr/scripts", USRNS),
  PERSCOMMANDSDIR = sprintf ("%s/commands/scripts", PERSNS),
  TEMPDIR = sprintf ("%s/tmp/%s/%d", ROOTDIR, WHOAMI, ROOT_PID),
  BGDIR = sprintf ("%s/_pids/bg", TEMPDIR, BGDIR);

variable
  DEV = 1 < __argc && length (where ("--dev" == __argv)) ? 1 : 0,
  DEBUG = 1 < __argc && length (where ("--debug" == __argv)) ? 1 : 0;

if (-1 == access (BINDIR, F_OK))
  {
  if (-1 == mkdir (BINDIR))
    {
    () = fprintf (stderr, "%s: cannot create directory\n:ERRNO: %s\n",
      BINDIR, errno_string (errno));
    exit (1);
    }

  $8 = chmod (BINDIR, 0770);

  if (-1 == $8)
    {
    () = fprintf (stderr, "%s: cannot change mode\n", BINDIR);
    exit (1);
    }
  }
else if (-1 == access (BINDIR, R_OK|W_OK))
  {
  () = fprintf (stderr, "%s: IS NOT WRITABLE|READABLE\n:ERRNO: %s\n",
    BINDIR, errno_string (errno));
  exit (1);
  }

if (-1 == access (MODULEDIR, F_OK))
  {
  if (-1 == mkdir (MODULEDIR))
    {
    () = fprintf (stderr, "%s: cannot create directory\n:ERRNO: %s\n",
      MODULEDIR, errno_string (errno));
    exit (1);
    }
  }
else if (-1 == access (MODULEDIR, R_OK|W_OK))
  {
  () = fprintf (stderr, "%s: IS NOT WRITABLE|READABLE\n:ERRNO: %s\n",
    MODULEDIR, errno_string (errno));
  exit (1);
  }

if (stat_file (MODULEDIR).st_uid == getuid ())
  {
  $8 = chmod (MODULEDIR, 0770);

  if (-1 == $8)
    {
    () = fprintf (stderr, "%s: cannot change mode\n", MODULEDIR);
    exit (1);
    }
  }

% will redefined later on
define isdirectory (file)
{
  variable st = stat_file (file);
  return NULL != st && stat_is ("dir", st.st_mode);
}

ifnot (isdirectory (sprintf ("%s/tmp", ROOTDIR)))
  if (-1 == mkdir (sprintf ("%s/tmp", ROOTDIR)))
    {
    () = fprintf (stderr, "cannot create %s/tmp directory, ERRNO: %s\n",
      ROOTDIR, errno_string (errno));
    exit (1);
    }
  else
    {
    $8 = chmod (sprintf ("%s/tmp", ROOTDIR), 0755);

    if (-1 == $8)
      {
      () = fprintf (stderr, "%s/tmp: cannot change mode, ERRNO: %s\n", ROOTDIR,
        errno_string (errno));
      exit (1);
      }
    }

$5 = sprintf ("%s/tmp/%s", ROOTDIR, WHOAMI);

ifnot (isdirectory ($5))
  if (-1 == mkdir ($5))
    {
    () = fprintf (stderr, "Cannot create directory %s, ERRNO: %s\n",
      $5, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod ($5, 0700);
else
  $8 = chmod ($5, 0700);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s: cannot change mode, ERRNO: %s\n",
    $5, errno_string (errno));
  exit (1);
  }

ifnot (isdirectory (TEMPDIR))
  if (-1 == mkdir (TEMPDIR))
    {
    () = fprintf (stderr, "Cannot create directory %s, ERRNO: %s\n",
      TEMPDIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (TEMPDIR, 0700);
else
  $8 = chmod (TEMPDIR, 0700);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s: cannot change mode, ERRNO: %s\n",
    TEMPDIR, errno_string (errno));
  exit (1);
  }

ifnot (isdirectory (sprintf ("%s/_pids", TEMPDIR)))
  if (-1 == mkdir (sprintf ("%s/_pids", TEMPDIR)))
    {
    () = fprintf (stderr, "Cannot create directory %s/_pids, ERRNO: %s\n",
      TEMPDIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (sprintf ("%s/_pids", TEMPDIR), 0700);
else
  $8 = chmod (sprintf ("%s/_pids", TEMPDIR), 0700);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s/_pids: cannot change mode, ERRNO: %s\n",
    TEMPDIR, errno_string (errno));
  exit (1);
  }

ifnot (isdirectory (BGDIR))
  if (-1 == mkdir (BGDIR))
    {
    () = fprintf (stderr, "Cannot create directory %s, ERRNO: %s\n",
      BGDIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (BGDIR, 0700);
else
  $8 = chmod (BGDIR, 0700);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s: cannot change mode, ERRNO: %s\n",
    BGDIR, errno_string (errno));
  exit (1);
  }

ifnot (isdirectory (sprintf ("%s/_pipes", TEMPDIR)))
  if (-1 == mkdir (sprintf ("%s/_pipes", TEMPDIR)))
    {
    () = fprintf (stderr, "Cannot create directory %s/_pipes, ERRNO: %s\n",
      TEMPDIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (sprintf ("%s/_pipes", TEMPDIR), 0700);
else
  $8 = chmod (sprintf ("%s/_pipes", TEMPDIR), 0700);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s/_pipes: cannot change mode, ERRNO: %s\n",
    TEMPDIR, errno_string (errno));
  exit (1);
  }

ifnot (isdirectory (sprintf ("%s/_scratch", TEMPDIR)))
  if (-1 == mkdir (sprintf ("%s/_scratch", TEMPDIR)))
    {
    () = fprintf (stderr, "Cannot create directory %s/_scratch, ERRNO: %s\n",
      TEMPDIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (sprintf ("%s/_scratch", TEMPDIR), 0700);
else
  $8 = chmod (sprintf ("%s/_scratch", TEMPDIR), 0700);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s/_scratch: cannot change mode, ERRNO: %s\n",
    TEMPDIR, errno_string (errno));
  exit (1);
  }

ifnot (isdirectory (sprintf ("%s/_edVi", TEMPDIR)))
  if (-1 == mkdir (sprintf ("%s/_edVi", TEMPDIR)))
    {
    () = fprintf (stderr, "Cannot create directory %s/_edVi, ERRNO: %s\n",
      TEMPDIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (sprintf ("%s/_edVi", TEMPDIR), 0700);
else
  $8 = chmod (sprintf ("%s/_edVi", TEMPDIR), 0700);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s/_edVi: cannot change mode, ERRNO: %s\n",
    TEMPDIR, errno_string (errno));
  exit (1);
  }

ifnot (isdirectory (sprintf ("%s/_ved", TEMPDIR)))
  if (-1 == mkdir (sprintf ("%s/_ved", TEMPDIR)))
    {
    () = fprintf (stderr, "Cannot create directory %s/_ved, ERRNO: %s\n",
      TEMPDIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (sprintf ("%s/_ved", TEMPDIR), 0700);
else
  $8 = chmod (sprintf ("%s/_ved", TEMPDIR), 0700);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s/_ved: cannot change mode, ERRNO: %s\n",
    TEMPDIR, errno_string (errno));
  exit (1);
  }

ifnot (isdirectory (sprintf ("%s/_list", TEMPDIR)))
  if (-1 == mkdir (sprintf ("%s/_list", TEMPDIR)))
    {
    () = fprintf (stderr, "Cannot create directory %s/_list, ERRNO: %s\n",
      TEMPDIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (sprintf ("%s/_list", TEMPDIR), 0700);
else
  $8 = chmod (sprintf ("%s/_list", TEMPDIR), 0700);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s/_list: cannot change mode, ERRNO: %s\n",
    TEMPDIR, errno_string (errno));
  exit (1);
  }

ifnot (isdirectory (sprintf ("%s/data", ROOTDIR)))
  if (-1 == mkdir (sprintf ("%s/data", ROOTDIR)))
    {
    () = fprintf (stderr, "Cannot create directory %s/data, ERRNO: %s\n",
      ROOTDIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (sprintf ("%s/data", ROOTDIR), 0770);

if (-1 == $8)
  {
  () = fprintf (stderr, "%s/data: cannot change mode, ERRNO: %s\n",
    ROOTDIR, errno_string (errno));
  exit (1);
  }

if (-1 == access (sprintf ("%s/data/share", ROOTDIR), F_OK))
  if (-1 == chdir (sprintf ("%s/data", ROOTDIR)))
    {
    () = fprintf (stderr, "%s/data: cannot change directory\n", ROOTDIR);
    exit (1);
    }
  else
    if (-1 == symlink ("../dist/data/share", "share"))
      {
      () = fprintf (stderr, "cannot make data/share symlink %s\n", errno_string (errno));
      exit (1);
      }

ifnot (isdirectory (DATADIR))
  if (-1 == mkdir (DATADIR))
    {
    () = fprintf (stderr, "Cannot create directory %s, ERRNO: %s\n",
      DATADIR, errno_string (errno));
    exit (1);
    }
  else
    $8 = chmod (DATADIR, 0700);
 
if (-1 == $8)
  {
  () = fprintf (stderr, "%s: cannot change mode, ERRNO: %s\n",
    DATADIR, errno_string (errno));
  exit (1);
  }

if (DEBUG)
  {
  ifnot (isdirectory (sprintf ("%s/_profile", TEMPDIR)))
    if (-1 == mkdir (sprintf ("%s/_profile", TEMPDIR)))
      {
      () = fprintf (stderr, "Cannot create profile directory %s/_profile, ERRNO: %s\n",
        TEMPDIR, errno_string (errno));
      exit (1);
      }
    else
      $8 = chmod (sprintf ("%s/_profile", TEMPDIR), 0700);
  else
    $8 = chmod (sprintf ("%s/_profile", TEMPDIR), 0700);

  if (-1 == $8)
    {
    () = fprintf (stderr, "%s/_profile: cannot change mode, ERRNO: %s\n",
      TEMPDIR, errno_string (errno));
    exit (1);
    }
  }

if (any (-1 == array_map (Integer_Type, &access, [STDNS, USRNS, PERSNS], F_OK))
  || (1 < __argc && length (where ("--install" == __argv))))
    {
    $1 = length (where ("--no-modules" == __argv));
    $1 = 0 == access (sprintf ("%s/std/getkey-module.so", MODULEDIR), F_OK);
    () = evalfile (sprintf ("%s/InstallMe/install_me", SOURCEDIR));
    }

set_slang_load_path (sprintf ("%s%c%s%c%s",
  STDLIBDIR, path_get_delimiter (),
  USRLIBDIR, path_get_delimiter (),
  PERSLIBDIR));

set_import_module_path (sprintf (
  "%s/std%c%s/usr%c%s/local",
  MODULEDIR, path_get_delimiter (),
  MODULEDIR, path_get_delimiter (),
  MODULEDIR));

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
catch ParseError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
    ["PARSE ERROR", exception_to_array]);
  exit (1);
  }

if (NULL == which ("stty"))
  {
  () = fputs ("stty executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

if (NULL == which ("diff"))
  {
  () = fputs ("diff executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

if (NULL == which ("patch"))
  {
  () = fputs ("patch executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

if (NULL == which ("ps"))
  {
  () = fputs ("ps executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

if (NULL == which ("git"))
  {
  () = fputs ("git executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

if (NULL == which ("sudo"))
  {
  () = fputs ("sudo executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

array_map (Void_Type, &__uninitialize, [&$5, &$6, &$7, &$8]);

() = evalfile (sprintf ("%s/i", BINDIR));
