ineed ("copyfile");
ineed ("fswalk");
ineed ("makedir");
ineed ("modetoint");
ineed ("fileis");

define clean (force, backup, backupfile, dest)
{
  if (force)
    {
    ifnot (NULL == backupfile)
      if (NULL == backup)
        () = rename (backupfile, dest);
      else
        () = copyfile (backupfile, dest);
    }
  else
    ifnot (NULL == backup)
      ifnot (NULL == backupfile)
        () = remove (backupfile);
}

private define older (st_source, st_dest)
{
  if (NULL == st_dest)
    return 1;

  st_source.st_mtime < st_dest.st_mtime;
}

private define newer (st_source, st_dest)
{
  if (NULL == st_dest)
    return 1;

  st_source.st_mtime > st_dest.st_mtime;
}

private define size (st_source, st_dest)
{
  if (NULL == st_dest)
    return 1;

  st_source.st_size != st_dest.st_size;
}

private define _copy (s, source, dest, st_source, st_dest)
{
  variable
    force = NULL,
    link,
    mode,
    retval,
    backup = NULL,
    backuptext = "";

  if (s.interactive)
    {
    retval = (@ask)
      ([sprintf ("update `%s'", dest), "y[es]/n[o]/q[uit] or escape to abort"],
      ['y', 'n', 'q']);

    if (any (['n', 033] == retval))
      {
      (@print_norm) (sprintf ("%s aborting ...", source));
      return 1;
      }

    if ('q' == retval)
      return -1;
    }

  if (s.backup)
      ifnot (any ([isfifo (source;st = st_source), issock (source;st = st_source),
          ischr (source;st = st_source), isblock (source;st = st_source)]))
      {
      backup = sprintf ("%s%s", dest, s.suffix);

      if (-1 == copyfile (dest, backup))
        {
        (@print_err) (sprintf ("cannot backup, %s", dest));
        return -1;
        }

      ifnot (access (dest, X_OK))
        () = chmod (backup, 0755);

      backuptext = sprintf ("(backup: `%s')", backup);
      }
  
  ifnot (NULL == st_dest)
    ifnot (st_dest.st_mode & S_IWUSR)
      if (NULL == s.force)
        {
        (@print_err) (sprintf ("%s: is not writable, try --force", dest));
        return -1;
        }
      else
        ifnot (any ([isfifo (source;st = st_source), issock (source;st = st_source),
            ischr (source;st = st_source), isblock (source;st = st_source)]))
          {
          if (NULL == s.backup)
            {
            backup = sprintf ("%s%s", dest, s.suffix);

            if (-1 == copyfile (dest, backup))
              {
              (@print_err) (sprintf ("cannot backup, %s", dest));
              return -1;
              }

            ifnot (access (dest, X_OK))
              () = chmod (backup, 0755);
            }

          if (-1 == remove (dest))
            {
            (@print_err) (sprintf ("%s: couldn't be removed", dest));
            return -1;
            }

          force = 1;
          }

  if (stat_is ("lnk", st_source.st_mode))
    {
    link = readlink (source);

    if (NULL == stat_file (source))
      {
      (@print_err) (sprintf
        ("source `%s' points to the non existing file `%s', aborting ...", source, link));
      
      clean (force, s.backup, backup, dest);

      return -1;
      }
    else
      if (-1 == symlink (link, dest))
        {
        clean (force, s.backup, backup, dest);

        return -1;
        }
      else
        return 1;
    }
  else if (any ([isfifo (source;st = st_source), issock (source;st = st_source),
        ischr (source;st = st_source), isblock (source;st = st_source)]))
    {
    (@print_norm) (sprintf
      ("cannot copy special file `%s': Operation not permitted", source));

    clean (force, s.backup, backup, dest);

    return 1;
    }
  else
    if (-1 == copyfile (source, dest))
      {
      clean (force, s.backup, backup, dest);

      return -1;
      }
  
  if (force && NULL == s.backup)
    () = remove (backup);

  () = lchown (dest, st_source.st_uid, st_source.st_gid);

  mode = modetoint (st_source.st_mode);

  if (-1 == chmod (dest, mode))
    {
    (@print_err) (sprintf ("%s: cannot change mode", dest));
    (@print_err) (sprintf ("ERRNO: %s", errno_string (errno)));
    return -1;
    }
  
  if (s.preserve_time)
    if (-1 == utime (dest, st_source.st_atime, st_source.st_mtime))
      {
      (@print_err) (sprintf ("%s: cannot change modification time", dest));
      (@print_err) (sprintf ("ERRNO: %s", errno_string (errno)));
      return -1;
      }

  (@print_norm) (sprintf ("`%s' -> `%s' %s",
    path_basename (source), path_basename (dest), backuptext));

  return 1;
}

private define file_callback (file, st, s, source, dest)
{
  (dest, ) = strreplace (file, source, dest, 1);
  
  variable
    i,
    st_dest = stat_file (dest);

  if (NULL == st_dest)
    return _copy (s, file, dest, st, st_dest);

  % FIXME: miiiight be not right (Its not right)
  if (islnk (file;st = st))
    if (islnk (dest))
      if (-1 == remove (dest))
        return -1;

  _for i (0, length (s.methods) - 1)
    if ((@s.methods[i]) (st, st_dest))
      return _copy (s, file, dest, st, st_dest);

  return 1;
}

private define dir_callback (dir, st, s, source, dest)
{
  ifnot (NULL == s.ignoredir)
    {
    variable ldir = strtok (dir, "/");
    if (any (ldir[-1] == s.ignoredir))
      {
      (@print_norm) (sprintf ("ignored dir: %s", dir));
      return 0;
      }
    }

  (dest, ) = strreplace (dir, source, dest, 1);

  if (NULL == stat_file (dest))
    if (-1 == makedir (dest, NULL))
      return -1;

  if (s.preserve_time)
    if (-1 == utime (dest, st.st_atime, st.st_mtime))
      {
      (@print_err) (sprintf ("%s: cannot change modification time", dest));
      (@print_err) (sprintf ("ERRNO: %s", errno_string (errno)));
      return -1;
      }

  return 1;
}

private define _sync (s, source, dest)
{
  ifnot (3 == _NARGS)
    {
    srv->send_msg ("sync: needs two arguments (directories)", -1);
    return -1;
    }

  ifnot (isdirectory (source))
    {
    srv->send_msg (sprintf ("sync: %s is not a directory", source), -1);
    return -1;
    }
  
  variable os = fswalk_new (&dir_callback, &file_callback;
    dargs = {s, source, dest}, fargs = {s, source, dest});

  os.walk (source);
  return 0;
}

define sync_new ()
{
  variable
    i,
    refs = Assoc_Type[Ref_Type],
    init = struct
      {
      run = &_sync,
      recursive = 1,
      backup,
      force = 1,
      suffix = "~",
      preserve_time = 1,
      interactive,
      ignoredir,
      methods
      },
    methods = qualifier ("methods", ["newer", "size"]);
  
  refs["newer"] = &newer;
  refs["older"] = &older;
  refs["size"] = &size;

  if (Array_Type != typeof (methods) || String_Type != _typeof (methods))
    {
    srv->send_msg ("sync: qualifier method should be of String_Type[]", -1);
    return NULL;
    }
 
  init.methods = Ref_Type[length (methods)];

  _for i (0, length (methods) - 1)
    ifnot (assoc_key_exists (refs, methods[i]))
      {
      srv->send_msg (sprintf ("%s: method is not valid", methods[i]), -1);
      return NULL;
      }
    else
      init.methods[i] = refs[methods[i]];

  return init;
}
