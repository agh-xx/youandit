ineed ("copy");
ineed ("pcre");
ineed ("fswalk");
ineed ("makedir");

private define dir_callback (dir, st, source, dest, opts, exit_code)
{
  ifnot (NULL == opts.ignoredir)
    {
    variable ldir = strtok (dir, "/");
    if (any (ldir[-1] == opts.ignoredir))
      {
      (@print_norm) (sprintf ("ignored dir: %s", dir));
      return 0;
      }
    }

  (dest, ) = strreplace (dir, source, dest, 1);

  if (NULL == stat_file (dest))
    if (-1 == makedir (dest, NULL))
      {
      @exit_code = -1;
      return -1;
      }

  return 1;
}

private define file_callback (file, st_source, source, dest, opts, exit_code)
{
  if (NULL == opts.copy_hidden)
    if ('.' == path_basename (file)[0])
      {
      (@print_norm) (sprintf ("omitting hidden file `%s'", file));
      return 1;
      }
 
  ifnot (NULL == opts.matchpat)
    ifnot (pcre_exec (opts.matchpat, file))
      {
      (@print_norm) (sprintf ("ignore file: %s", file));
      return 1;
      }

  ifnot (NULL == opts.ignorepat)
    if (pcre_exec (opts.ignorepat, file))
      {
      (@print_norm) (sprintf ("ignore file: %s", file));
      return 1;
      }

  (dest,) = strreplace (file, source, dest, 1);

  if (-1 == copy (file, dest, st_source, stat_file (dest), opts))
    {
    @exit_code = -1;
    return -1;
    }

  return 1;
}

define cprecursive (source, dest, opts)
{
  variable
    exit_code = 0,
    fswalk = fswalk_new (&dir_callback, &file_callback;
    dargs = {source, dest, opts, &exit_code},
    fargs = {source, dest, opts, &exit_code},
    maxdepth = opts.maxdepth);

  fswalk.walk (source);

  return exit_code;
}
