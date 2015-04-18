variable
  ROOTDIR = __argv[1],
  BINDIR = __argv[2],
  TEMPDIR = __argv[3],
  DATADIR = __argv[4],
  STDNS = sprintf ("%s/std", BINDIR),
  USRNS = sprintf ("%s/usr", BINDIR),
  PERSNS = sprintf ("%s/local", BINDIR),
  DEVNS = sprintf ("%s/dev", BINDIR),
  SOURCEDIR = sprintf ("%s/dist", ROOTDIR);

set_import_module_path (__argv[5]);
set_slang_load_path (sprintf ("%s/proc/lib:%c%s:%c%s/I_Ns/lib",
    STDNS, path_get_delimiter (),
  __argv[6], path_get_delimiter (),
  STDNS));

private variable func = __argv[7];

__set_argc_argv (__argv[[7:]]);

() = evalfile (sprintf ("%s/I_Ns/lib/need", STDNS), "i");
() = evalfile (sprintf ("%s/I_Ns/lib/except_to_arr", STDNS));

define ineed ()
{
  variable args = __pop_list (_NARGS);
  try
    i->need (__push_list (args));
  catch ParseError:
    {
    () = array_map (Integer_Type, &fprintf, stdout, "%s\n", exception_to_array ());
    exit (1);
    }
}

ineed ("std");

define _usage ()
{
  variable
    if_opt_err = _NARGS ? () : " ",
    infodir = path_dirname (__argv[0]) + "/../info/" + path_basename (__argv[0]),
    helpfile = qualifier ("helpfile", sprintf ("%s/help.txt", infodir)),
    ar = _NARGS ? [if_opt_err] : String_Type[0];

  if (NULL == helpfile)
    {
    () = fprintf (stderr, "No Help file available for %s\n", path_basename (__argv[0]));
    exit (1);
    }

  ifnot (access (helpfile, F_OK))
    ar = [ar, readfile (helpfile)];

  ifnot (length (ar))
    {
    () = fprintf (stderr, "No Help file available for %s\n", path_basename (__argv[0]));
    exit (1);
    }

  () = ar_to_fp ([sprintf ("Help for %s", path_basename (__argv[0])), ar], "%s\n", stdout);

  exit (_NARGS);
}

define info ()
{
  variable
    infodir = path_dirname (__argv[0]) + "/../info/" + path_basename (__argv[0]),
    infofile = qualifier ("helpfile", sprintf ("%s/desc.txt", infodir)),
    ar;

  if (NULL == infofile || -1 == access (infofile, F_OK))
    {
    () = fprintf (stderr, "No Info file available for %s\n", path_basename (__argv[0]));
    exit (1);
    }

  ifnot (access (infofile, F_OK))
    ar = readfile (infofile);

  if (0 == length (ar) || NULL == ar)
    {
    () = fprintf (stderr, "No Info file available for %s\n", path_basename (__argv[0]));
    exit (1);
    }

  () = ar_to_fp ([sprintf ("Info for %s", path_basename (__argv[0])), ar], "%s\n", stdout);

  exit (0);
}

try
  {
  () = evalfile (func);
  }
catch AnyError:
  {
  () = ar_to_fp (exception_to_array (), "%s\n", stdout);
  exit (1);
  }

