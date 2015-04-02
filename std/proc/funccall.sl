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
set_slang_load_path (sprintf ("%s:%c%s/I_Ns/lib:%c:%s/proc",
  __argv[6], path_get_delimiter (),
  STDNS, path_get_delimiter (),
  STDNS));

private variable func = __argv[7];

sigprocmask (SIG_BLOCK, [SIGINT]);

define ar_to_fp (ar, fmt, fp)
{
  variable
    bts = int (sum (array_map (Integer_Type, &fprintf, fp, fmt, ar)));
 
  () = fflush (fp);

  return bts;
}

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
    () = ar_to_fp (exception_to_array (), "%s\n", stdout);
    exit (1);
    }
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

