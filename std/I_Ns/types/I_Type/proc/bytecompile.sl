ineed ("fswalk");
ineed ("copyfile");

variable
  EXIT_CODE = 0,
  DONT_REMOVE_MODULES = any ("--remove_modules" == __argv) ? NULL : 1,
  EXCLUDEFILESFORDELETION = [
    "cache.txt", "intrinsic_cache.txt", "TODO", path_basename (__argv[1]),
     readfile (sprintf ("%s/data/bytecompile/excludefiles.txt", PERSNS))],
  EXCLUDEDIRSFORDELETION = [sprintf ("%s/tmp", BINDIR), sprintf ("%s/modules", STDNS)],
  EXCLUDEFILESBASENAME = ["TODO", "stackfile.sl", ".gitignore"],
  EXCLUDEFILESFULLPATH = [""],
  EXCLUDEDIRS = ["C", "InstallMe", ".git"];

EXCLUDEFILESFORDELETION = EXCLUDEFILESFORDELETION[wherenot (_isnull (EXCLUDEFILESFORDELETION))];

variable Accept_All_As_Yes = 0;
variable Accept_All_As_No = 0;

% lowercase to be used in functions, right now we are protected
variable retval;

define rm_dir (dir)
{
  if (Accept_All_As_No) return;

  ifnot (Accept_All_As_Yes) {
  % coding style violence
 
  retval = (@ask) ([dir, "remove extra directory?",
     "y[es]/Y[es to all]/n[no]/N[o to all] escape to abort (same as 'n')"],
    ['y',  'Y',  'n',  'N'];header = "QUESTION FROM THE BYTECOMPILE FUNCTION");
 
 
  if ('n' == retval || 'N' == retval || 033 == retval)
    {
    (@print_err) (sprintf (
      "extra directory %s hasn't been removed: Not confirmed", dir));

    Accept_All_As_No = 'N' == retval;
    return;
    }
 
  Accept_All_As_Yes = 'Y' == retval;

  }
 
  if (-1 == rmdir (dir))
    {
    (@print_err) (sprintf ("%s: extra directory hasn't been removed", dir));
    (@print_err) (sprintf ("Error: %s", errno_string (errno)));
    return;
    }

  (@print_out) (sprintf ("%s: extra directory has been removed", dir));
  return;
}

define rmfile (file)
{
  if (Accept_All_As_No)
    return;

  ifnot (Accept_All_As_Yes) {

  retval = (@ask) ([file, "remove extra compiled file?",
     "y[es]/Y[es to all]/n[no]/N[o to all] escape to abort (same as 'n')"],
    ['y',  'Y', 'n',  'N'];header = "QUESTION FROM THE BYTECOMPILE FUNCTION");

  if ('n' == retval || 'N' == retval || 033 == retval)
    {
    (@print_err) (sprintf (
      "extra file %s hasn't been removed: Not confirmed", file));

    Accept_All_As_No = 'N' == retval;
    return;
    }

  Accept_All_As_Yes = 'Y' == retval;

  }

  if (-1 == remove (file))
    {
    (@print_err) (sprintf ("%s: extra file hasn't been removed", file));
    (@print_err) (sprintf ("Error: %s", errno_string (errno)));
    return;
    }

  (@print_out) (sprintf ("%s: extra file has been removed", file));
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
      (@print_err) (sprintf ("%s: failed  to copy", file));
      return -1;
      }

    return 1;
    }

  try
    byte_compile_file (sprintf ("%s/%s", SOURCEDIR, file), 0);
  catch AnyError:
    {
    view_exception ([sprintf ("%s: failed to compile", file), exception_to_array ()]);
    array_map (Void_Type, print_err, exception_to_array ());
    array_map (Void_Type, print_out, exception_to_array ());
    EXIT_CODE = 1;
    return -1;
    }

  % do not use rename because of cross-device, distribution could be in tmpfs
  copyfile (sprintf ("%s/%sc", SOURCEDIR, file), sprintf ("%sc", newfile));

  if (-1 == remove (sprintf ("%s/%sc", SOURCEDIR, file)))
    {
    (@print_err) (sprintf ("%sc: failed to move", file));
    (@print_out) (sprintf ("%sc: failed to move", file));
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
    (@print_err) (sprintf ("%s: mkdir failed: ERRNO: %s", newdir, errno_string (errno)));
    return -1;
    }

  return 1;
}

define main ()
{
  if (-1 == chdir (SOURCEDIR))
    {
    (@print_err)  (sprintf ("%s: cannot change to sources directory ERRNO: %s",
      SOURCEDIR, errno_string (errno)));
    return 1;
    }

  variable
    fs = fswalk_new (&dir_callback, &file_callback);

  srv->send_msg_and_refresh ("Bytecompiling ...", 1);

  () = file_callback ("i.sl", NULL);

  fs.walk ("std");
  fs.walk ("usr");
  fs.walk ("local");
  fs.walk ("dev");
 
  if (EXIT_CODE)
    {
    srv->send_msg_and_refresh ("Bytecompiling ... failed", -1);
    return EXIT_CODE;
    }

  srv->send_msg_and_refresh ("Bytecompiling ... done", 0);
 
  variable dirs = {};
  fs = fswalk_new (&dir_callback_a, &file_callback_a;dargs = {dirs});
  fs.walk (BINDIR);
 
  if (length (dirs))
    {
    dirs = list_to_array (dirs);
    dirs = dirs [array_sort (dirs;dir = -1)];
    array_map (Void_Type, &rm_dir, dirs);
    }

  return EXIT_CODE;
}
