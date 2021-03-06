() = evalfile ("fswalk");

variable
  CHANGEREF = NULL,
  EXIT_CODE = 0;

define getcuruser (uid)
{
  variable
    line,
    rec,
    lines = readfile ("/etc/passwd");
 
  uid = string (uid);

  foreach line (lines)
    {
    rec = strchop (line, ':', 0);
    if (rec[2] == uid)
      return rec[0];
    }

  return "NONE";
}

define getcurgroup (gid)
{
  variable
    line,
    rec,
    lines = readfile ("/etc/group");
 
  gid = string (gid);

  foreach line (lines)
    {
    rec = strchop (line, ':', 0);
    if (rec[2] == gid)
      return rec[0];
    }

  return "NONE";
}

define change_ref (file, uid, gid, user, group)
{
  variable
    st = stat_file (file),
    cur_uid = st.st_uid,
    cur_gid = st.st_gid,
    cur_user,
    cur_group;

  cur_user = getcuruser (cur_uid);

  if (NULL == gid)
    {
    gid = cur_gid;
    group = getcurgroup (gid);
    cur_group = group;
    }
  else
    cur_group = getcurgroup (cur_gid);

  if (-1 == chown (file, uid, gid))
    {
    (@print_err) (sprintf (
      "%s: could not change ownership, ERRNO: %s", file, errno_string (errno)));
    EXIT_CODE = 1;
    }
  else
    {
    if (uid == cur_uid && gid == cur_gid)
      (@print_out) (sprintf ("ownership of `%s' retained as %s:%s", file, user, group));
    else
      (@print_out) (sprintf ("changed ownership of `%s' from %s:%s to %s:%s",
        file, cur_user, cur_group, user, group));
    }
}

define chown_it (file, uid, gid, user, group)
{
  variable
    st = qualifier ("st", lstat_file (file)),
    cur_uid = st.st_uid,
    cur_gid = st.st_gid,
    cur_user,
    cur_group,
    islink = stat_is ("lnk", st.st_mode),
    whatchown = islink ? &lchown : &chown;

  cur_user = getcuruser (cur_uid);

  if (NULL == gid)
    {
    gid = cur_gid;
    group = getcurgroup (gid);
    cur_group = group;
    }
  else
    cur_group = getcurgroup (cur_gid);
 
  if (-1 == (@whatchown) (file, uid, gid))
    {
    (@print_err) (sprintf (
      "%s: could not change ownership, ERRNO: %s", file, errno_string (errno)));
    EXIT_CODE = 1;
    }
  else
    {
    if (uid == cur_uid && gid == cur_gid)
      (@print_out) (sprintf ("ownership of `%s' retained as %s:%s", file, user, group));
    else
      (@print_out) (sprintf ("changed ownership of `%s' from %s:%s to %s:%s",
        file, cur_user, cur_group, user, group));
    }
 
  if (islink)
    ifnot (NULL == CHANGEREF)
      change_ref (file, uid, gid, user, group);
}

define dir_callback (dir, st, uid, gid, user, group)
{
  chown_it (dir, uid, gid, user, group;st = st);
  return 1;
}

define file_callback (file, st, uid, gid, user, group)
{
  chown_it (file, uid, gid, user, group;st = st);
  return 1;
}

define _getuid (user)
{
  variable
    rec,
    lines = readfile ("/etc/passwd");
 
  rec = wherenot (strncmp (lines, sprintf ("%s:", user), strlen (user) + 1));
 
  ifnot (length (rec))
    return NULL;

  rec = strchop (lines[rec[0]], ':', 0);
  if (7 != length (rec))
    return NULL;

  return atoi (rec[2]);
}

define _getgid (group)
{
  variable
    rec,
    lines = readfile ("/etc/group");

  rec = wherenot (strncmp (lines, sprintf ("%s:", group), strlen (group) + 1));

  ifnot (length (rec))
    return NULL;

  rec = strchop (lines[rec[0]], ':', 0);

  if (4 != length (rec))
    return NULL;

  return atoi (rec[2]);
}

define main ()
{
  variable
    i,
    fs,
    uid,
    gid,
    files,
    group = NULL,
    user = NULL,
    recursive = NULL,
    c = cmdopt_new (&_usage);

  c.add ("group", &group;type = "string");
  c.add ("user", &user;type = "string");
  c.add ("changeref", &CHANGEREF);
  c.add ("recursive", &recursive);
  c.add ("help", &_usage);
  c.add ("info", &info);

  i = c.process (__argv, 1);
 
  if (i == __argc)
    {
    (@print_err) (sprintf ("%s: it requires a filename", __argv[0];print_in_msg_line));
    return 1;
    }
 
  files = __argv[[i:]];
  files = files[where (strncmp (files, "--", 2))];

  if (NULL == user)
    {
    (@print_err) ("--user option wasn't given");
    return 1;
    }

  uid = _getuid (user);

  if (NULL == uid)
    {
    (@print_err) (sprintf ("%s: No such user, aborting ...", user));
    return 1;
    }
 
  ifnot (NULL == group)
    {
    gid = _getgid (group);
    if (NULL == gid)
      {
      (@print_err) (sprintf ("%s: No such group, aborting ...", group));
      return 1;
      }
    }
  else
    gid = NULL;
 
  _for i (0, length (files) - 1)
    {
    if (-1 == access (files[i], F_OK))
      {
      (@print_err) (sprintf ("%s: No such file", files[i]));
      continue;
      }

    if (isdirectory (files[i]))
      {
      ifnot (NULL == recursive)
        {
        fs = fswalk_new (&dir_callback, &file_callback;uselstat,
            dargs = {uid, gid, user, group}, fargs = {uid, gid, user, group});

        fs.walk (files[i]);
        }
      else
        chown_it (files[i], uid, gid, user, group);

      continue;
      }

    chown_it (files[i], uid, gid, user, group);
    }

  return EXIT_CODE;
}
