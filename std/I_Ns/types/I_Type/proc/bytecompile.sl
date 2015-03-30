set_slang_load_path (getenv ("LOAD_PATH"));
set_import_module_path (getenv ("IMPORT_PATH"));

import ("getkey");

variable
  SRV_SOCKADDR = getenv ("SRV_SOCKADDR"),
  SRV_SOCKET = @FD_Type (atoi (getenv ("SRV_FILENO"))),
  BINDIR = getenv ("BINDIR"),
  SOURCEDIR = getenv ("SOURCEDIR"),
  PERSNS = getenv ("PERSNS"),
  STDNS = getenv ("STDNS"),
  COLUMNS = atoi (getenv ("COLUMNS")),
  PROMPTROW = atoi (getenv ("PROMPTROW")),
  getch,
  getchar_lang,
  TTY_INITED = 0;

() = evalfile (sprintf ("%s/InputNs/input", STDNS), "input");
() = evalfile (sprintf ("%s/I_Ns/lib/except_to_arr", STDNS));
() = evalfile (sprintf ("%s/I_Ns/lib/std", STDNS));
() = evalfile (sprintf ("%s/SockNs/sock_funcs", STDNS), "sock");
() = evalfile (sprintf ("%s/I_Ns/lib/need", STDNS), "i");

getch = &input->getchar;
getchar_lang = &input->en_getch;
init_tty (-1, 0, 0);

define ineed (lib)
{
  try
    i->need (lib);
  catch ParseError:
    {
    () = array_map (Integer_Type, &fprintf, stderr, "%s\n", exception_to_array ());
    exit (1);
    }
}

define print_err (str)
{
  () = fprintf (stderr, "%s\n", str);
}

ineed ("fswalk");
ineed ("copyfile");

variable
  EXIT_CODE = 0,
  DONT_REMOVE_MODULES = any ("--remove_modules" == __argv) ? NULL : 1,
  EXCLUDEFILESFORDELETION = [
    "cache.txt", "intrinsic_cache.txt", "TODO", path_basename (__argv[0]),
     readfile (sprintf ("%s/data/bytecompile/excludefiles.txt", PERSNS))],
  EXCLUDEDIRSFORDELETION = [sprintf ("%s/tmp", BINDIR), sprintf ("%s/modules", STDNS)],
  EXCLUDEFILESBASENAME = ["TODO", "stackfile.sl", ".gitignore"],
  EXCLUDEFILESFULLPATH = [""],
  EXCLUDEDIRS = ["C", "InstallMe", ".git"];

EXCLUDEFILESFORDELETION = EXCLUDEFILESFORDELETION[wherenot (_isnull (EXCLUDEFILESFORDELETION))];

variable Accept_All_As_Yes = 0;
variable Accept_All_As_No = 0;

define write_nstring_dr (str, len, color, pos)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  str = str == NULL || 0 == strlen (str) ? " " : str;

  () = sock->get_bit_send_str (SRV_SOCKET, str);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [len, color, pos]);
  () = sock->get_bit (SRV_SOCKET);
}

define ask (str, ar)
{
  variable
    retval;

  write_nstring_dr (str, COLUMNS, 0, [PROMPTROW, 0, PROMPTROW, strlen (str)]);
  
  retval = (@getch);

  while (NULL == wherefirst_eq (ar, retval) && 033 != retval)
    retval = (@getch);

  write_nstring_dr (" ", COLUMNS, 0, [PROMPTROW, 0, PROMPTROW, 0]);
  return retval;
}

% lowercase to be used in functions, right now we are protected
variable retval;

define rm_dir (dir)
{
  if (Accept_All_As_No) return;

  ifnot (Accept_All_As_Yes) {
  % coding style violence
 
  retval = ask (sprintf ("%s remove directory? y[es]/Y[es to all]/n[no]/N[o to all]", dir), 
    ['y',  'Y',  'n',  'N']);
 
 
  if ('n' == retval || 'N' == retval || 033 == retval)
    {
    () = fprintf (stderr, "extra directory %s hasn't been removed: Not confirmed\n", dir);

    Accept_All_As_No = 'N' == retval;
    return;
    }
 
  Accept_All_As_Yes = 'Y' == retval;

  }
 
  if (-1 == rmdir (dir))
    {
    () = fprintf (stderr, "%s: extra directory hasn't been removed\n", dir);
    () = fprintf (stderr, "Error: %s\n", errno_string (errno));
    return;
    }

  () = fprintf (stdout, "%s: extra directory has been removed\n", dir);
  return;
}

define rmfile (file)
{
  if (Accept_All_As_No)
    return;

  ifnot (Accept_All_As_Yes) {

  retval = ask (sprintf ("%s remove compiled file? y[es]/Y[es to all]/n[no]/N[o to all]", file), 
    ['y',  'Y',  'n',  'N']);

  if ('n' == retval || 'N' == retval || 033 == retval)
    {
    () = fprintf (stderr, "extra file %s hasn't been removed: Not confirmed\n", file);

    Accept_All_As_No = 'N' == retval;
    return;
    }

  Accept_All_As_Yes = 'Y' == retval;
  }

  if (-1 == remove (file))
    {
    () = fprintf (stderr, "%s: extra file hasn't been removed\n", file);
    () = fprintf (stderr, "Error: %s\n", errno_string (errno));
    return;
    }

  () = fprintf (stdout, "%s: extra file has been removed\n", file);
}

define file_callback_a (file, st)
{
  if (any (EXCLUDEFILESFORDELETION == path_basename (file)))
    return 1;
 
  if (".so" == path_extname (file))
    if (DONT_REMOVE_MODULES)
      return 1;

  variable newfile = strreplace (file, BINDIR, SOURCEDIR);

  if (".slc" == path_extname (newfile))
    newfile = substr (newfile, 1, strlen (newfile) - 1);

  ifnot (access (newfile, F_OK))
    return 1;

  rmfile (file);
  return 1;
}

define dir_callback_a (dir, st, dirs)
{
  if (any (dir == EXCLUDEDIRSFORDELETION))
    return 0;

  variable newdir = strreplace (dir, BINDIR, SOURCEDIR);

  ifnot (access (newdir, F_OK))
    return 1;

  list_append (dirs, dir);

  return 1;
}

define file_callback (file, st)
{
  if (any (path_basename (file) == EXCLUDEFILESBASENAME))
    return 1;

  if (any (file == EXCLUDEFILESFULLPATH))
    return 1;

  variable
    ref,
    newfile = sprintf ("%s/%s", BINDIR, file),
    ext = path_extname (file);

  if (0 == strlen (ext) || ".sl" != ext)
    {
    if (-1 == copyfile (file, newfile))
      {
      () = fprintf (stderr, "%s: failed  to copy\n", file);
      return -1;
      }

    return 1;
    }

  try
    byte_compile_file (sprintf ("%s/%s", SOURCEDIR, file), 0);
  catch AnyError:
    {
    () = array_map (Integer_Type, &fprintf, stderr, "%s\n", exception_to_array ());
    EXIT_CODE = 1;
    return -1;
    }

  % do not use rename because of cross-device, distribution could be in tmpfs
  copyfile (sprintf ("%s/%sc", SOURCEDIR, file), sprintf ("%sc", newfile));

  if (-1 == remove (sprintf ("%s/%sc", SOURCEDIR, file)))
    {
    () = fprintf (stderr, "%sc: failed to move\n", file);
    EXIT_CODE = 1;
    return -1;
    }

  return 1;
}

define dir_callback (dir, st)
{
  if (any (path_basename (dir) == EXCLUDEDIRS))
    return 0;

  variable newdir = sprintf ("%s/%s", BINDIR, dir);

  ifnot (access (newdir, F_OK))
    return 1;
 
  if (-1 == mkdir (newdir))
    {
    () = fprintf (stderr, "%s: mkdir failed: ERRNO: %s\n", newdir, errno_string (errno));
    return -1;
    }

  return 1;
}

define main ()
{
  if (-1 == chdir (SOURCEDIR))
    {
    () = fprintf (stderr, "%s: cannot change to sources directory ERRNO: %s\n",
      SOURCEDIR, errno_string (errno));
    exit (1);
    }

  variable
    fs = fswalk_new (&dir_callback, &file_callback);

  () = file_callback ("i.sl", NULL);

  fs.walk ("std");
  fs.walk ("usr");
  fs.walk ("local");
  fs.walk ("dev");
 
  if (EXIT_CODE)
    {
    () = fprintf (stderr, "Bytecompiling ... failed\nEXIT_CODE: %d\n%s\n",
      EXIT_CODE, repeat ("_", COLUMNS));
    exit (EXIT_CODE);
    }

  () = fprintf (stdout, "Bytecompiling ... done\n");
 
  variable dirs = {};
  fs = fswalk_new (&dir_callback_a, &file_callback_a;dargs = {dirs});
  fs.walk (BINDIR);
 
  if (length (dirs))
    {
    dirs = list_to_array (dirs);
    dirs = dirs [array_sort (dirs;dir = -1)];
    array_map (Void_Type, &rm_dir, dirs);
    }
  
  () = fprintf (EXIT_CODE ? stderr : stdout, "EXIT_CODE: %d\n%s\n",
    EXIT_CODE, repeat ("_", COLUMNS));

  exit (EXIT_CODE);
}

main ();
