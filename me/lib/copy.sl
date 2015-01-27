ineed ("copyfile");
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

define copy (source, dest, st_source, st_dest, opts)
{
  variable
    msg,
    link,
    mode,
    retval,
    force = NULL,
    backuptext = "",
    backup = NULL;

  ifnot (NULL == st_dest)
    {
    if (opts.noclobber)
      {
      (@print_warn) (sprintf
        ("%s: Cannot overwrite existing file; noclobber option is given", dest));
      return 0;
      }

    if (opts.update && st_source.st_mtime <= st_dest.st_mtime)
      {
      (@print_warn) (sprintf ("`%s' is newer than `%s', aborting ...", dest, source));
      return 0;
      }
    
    % TODO QUIT
    if (opts.interactive)
      {
      retval = (@ask)
        ([sprintf ("overwrite `%s'", dest), "y[es]/n[o]/q[uit] or escape to abort"],
        ['y', 'n', 'q']);
      if (any (['n', 033, 'q'] == retval))
        {
        (@print_norm) (sprintf ("%s aborting ...", source));
        return 0;
        }
      }

    if (opts.backup)
      ifnot (any ([isfifo (source;st = st_source), issock (source;st = st_source),
          ischr (source;st = st_source), isblock (source;st = st_source)]))
        {
        backup = sprintf ("%s%s", dest, opts.suffix);

        if (-1 == copyfile (dest, backup))
          {
          (@print_err) (sprintf ("cannot backup, %s", dest));
          return -1;
          }

        ifnot (access (dest, X_OK))
          () = chmod (backup, 0755);

        backuptext = sprintf ("(backup: `%s')", backup);
        }

    ifnot (st_dest.st_mode & S_IWUSR)
      if (NULL == opts.force)
        {
        (@print_err) (sprintf ("%s: is not writable, try --force", dest));
        return 0;
        }
      else
        ifnot (any ([isfifo (source;st = st_source), issock (source;st = st_source),
          ischr (source;st = st_source), isblock (source;st = st_source)]))
          {
          if (NULL == opts.backup)
            {
            backup = sprintf ("%s%s", dest, opts.suffix);

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
    }

  if (stat_is ("lnk", st_source.st_mode))
    {
    link = readlink (source);
    if (NULL == stat_file (source))
      {
      (@print_err) (sprintf
        ("source `%s' points to the non existing file `%s', aborting ...", source, link));
      
      clean (force, opts.backup, backup, dest);
      
      return -1;
      }
    else if (NULL == opts.nodereference)
      if (-1 == symlink (link, dest))
        {
        clean (force, opts.backup, backup, dest);

        return -1;
        }
    }
  else if (any ([isfifo (source;st = st_source), issock (source;st = st_source),
        ischr (source;st = st_source), isblock (source;st = st_source)]))
    {
    (@print_norm) (sprintf
      ("cannot copy special file `%s': Operation not permitted", source));

    clean (force, opts.backup, backup, dest);
    
    return 0;
    }
  else
    {
    if (-1 == copyfile (source, dest))
      {
      clean (force, opts.backup, backup, dest);

      return -1;
      }
    }

  if (force && NULL != opts.backup)
    () = remove (backup);

  ifnot (NULL == opts.permissions)
    () = lchown (dest, st_source.st_uid, st_source.st_gid);

  mode = modetoint (st_source.st_mode);

  () = chmod (dest, mode);

  (@print_norm) (sprintf ("`%s' -> `%s' %s", source, dest, backuptext));

  return 0;
}
