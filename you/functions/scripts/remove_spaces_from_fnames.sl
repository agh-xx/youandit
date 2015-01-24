() = evalfile ("fswalk");

private define my_usage ()
{
  variable args = __pop_list (_NARGS);
  _usage (__push_list (args);helpfile = sprintf (
    "%s/../info/rm_spaces_from_fnames/help.txt", path_dirname (__FILE__)));
}

private define my_info ()
{
  info (;infofile = sprintf (
    "%s/../info/rm_spaces_from_fnames/desc.txt", path_dirname (__FILE__)));
}

private define file_callback (file, st, list)
{
  if (1 < length (strtok (path_basename (file))))
    list_append (list, file);
  return 1;
}

private define dir_callback (dir, st, list)
{
  if (1 < length (strtok (path_basename (dir))))
    list_append (list, dir);
  return 1;
}

define main ()
{
  variable
    i,
    fs,
    files,
    source,
    destname,
    sub = "_",
    list = {},
    recursive = NULL,
    exit_code = 0,
    c = cmdopt_new (&my_usage);

  c.add ("recursive", &recursive);
  c.add ("sub", &sub;type = "string");
  c.add ("help", &my_usage);
  c.add ("info", &my_info);

  i = c.process (__argv, 1);

  if (i == __argc)
    {
    (@print_err) ("Argument (filename) is required", -1);
    return 1;
    }
 
  ifnot (length (strtok (sub)))
    {
    (@print_err) ("substitution string is|are space[s], doesn't make sense", -1);
    return 1;
    }
 
  sub = strjoin (strtok (sub));

  files = __argv[[i:__argc - 1]];
  files = files[where (strncmp (files, "--", 2))];

  _for i (0,length (files) - 1)
    {
    if (-1 == access (files[i], F_OK))
      {
      (@print_err) (sprintf ("%s: doesn't exists in filesystem", files[i]));
      continue;
      }
 
    if (-1 == access (files[i], W_OK))
      {
      (@print_err) (sprintf ("%s: Is not writable", files[i]));
      continue;
      }

    if (isdirectory (files[i]))
      {
      if (NULL == recursive)
        {
        (@print_warn) (sprintf ("%s: is a directory and recursive is NULL", files[i]));
        continue;
        }

      fs = fswalk_new (&dir_callback, &file_callback;dargs = {list}, fargs = {list});
      fs.walk (files[i]);
      }
 
    list_append (list, files[i]);
    }
 
  ifnot (length (list))
   return 0;

  list = list_to_array (list);
  list = list[array_sort (list;dir=-1)];

  _for i (0, length (list) - 1)
    {
    source = strtrim_end (list[i], "/"),
    destname = path_basename (source);
 
    ifnot (strlen (destname))
     continue;
 
    destname = strchop (destname, ' ', 0);
    if (1 == length (destname))
      continue;
 
    destname = strjoin (destname, sub);
 
    if (-1 == rename (source, path_concat (path_dirname (source), destname)))
      {
      exit_code = 1;
      (@print_err) (sprintf ("%s: failed to rename to `%s', ERRNO: %s", source, destname,
        errno_string (errno)));
      }
    else
      (@print_norm) (sprintf ("%s: renamed to `%s'", source, destname));
    }

  return exit_code;
}
