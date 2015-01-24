() = evalfile ("fswalk");

define file_callback (file, st, errlist)
{
  if (-1 == remove (file))
    list_append (errlist, sprintf ("%s: failed to remove", file));

  return 1;
}

define dir_callback (dir, st, list)
{
  list_append (list, dir);
  return 1;
}

define rm_tmpdir ()
{

  variable
    retval,
    errlist = {},
    dirlist = {},
    fs = fswalk_new (&dir_callback, &file_callback; dargs = {dirlist}, fargs = {errlist});

  fs.walk (TMPDIR);

  if (length (errlist))
    () = array_map (Integer_Type, &fprintf, stderr, "%s\n", list_to_array (errlist));

  dirlist = list_to_array (dirlist);
  dirlist = dirlist[array_sort (dirlist;dir = -1)];
  errlist = array_map (Integer_Type, &rmdir, dirlist);
  errlist = dirlist[where (-1 == errlist)];

  if (length (errlist))
    () = array_map (Integer_Type, &fprintf, stderr, "%s: failed to remove directory\n", errlist);
}
