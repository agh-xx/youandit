variable
  Id_Group = 0,
  Id_Groups = 0,
  Id_Name = 0,
  Id_Real = 0,
  Id_User = 0;

define get_name ()
{
  variable
    id = _NARGS ? () : string (getuid ()),
    line,
    rec,
    index = _NARGS ? 0 : 2,
    passwd = struct {pw_name, pw_pass, pw_uid, pw_gid, pw_gecos, pw_dir, pw_shell},
    ar = readfile ("/etc/passwd");

  if (NULL == ar)
    return "cannot read /etc/passwd", NULL;

  foreach line (ar)
    {
    rec = strchop (line, ':', 0);
    if (rec[index] == id)
      {
      if (7 != length (rec))
        return sprintf ("fields in /etc/passwd are %s than seven",
            length (rec) > 7 ? "more" : "less"), NULL;

      set_struct_fields (passwd, rec[0], rec[1], rec[2], rec[3], rec[4], rec[5], rec[6]);
      return passwd;
      }
    }

  return sprintf ("%s: No such %s", id, _NARGS ? "name" : "uid"), NULL;
}

define getgrgid (gid)
{
  variable
    line,
    rec,
    ar = readfile ("/etc/group");

  if (NULL == ar)
    return NULL;
 
  gid = string (gid);

  foreach line (ar)
    {
    rec = strchop (strtrim_end (line), ':', 0);
    if (rec[2] == gid)
      {
      ifnot (4 == length (rec))
        return sprintf ("fields in /etc/group are %s than 4",
            length (rec) > 4 ? "more" : "less"), NULL;
      else
        return rec[0];
      }
    }

  return NULL;
}

define match_user (rec, name)
{
  variable a = strchop (rec, ',', 0);
  foreach (a)
    {
    variable u = ();
    if (name == u)
      return 1;
    }

  return 0;
}

define getgrouplist (name)
{
  variable
    groups = {name},
    line,
    rec,
    ar = readfile ("/etc/group");

  if (NULL == ar)
    return NULL;
 
  foreach line (ar)
    {
    rec = strchop (strtrim_end (line), ':', 0);
    if (match_user (rec[-1], name) && 0 == (rec[0] == name))
      list_append (groups, rec[0]);
    }
 
  return strjoin (list_to_array (groups), " ");
}

define id_name (s, str)
{
  if (Id_Group)
    {
    @str = getgrgid (s.pw_gid);
    if (NULL == @str)
      return -1;
    else
      return 0;
    }

  if (Id_Groups)
    {
    @str =  getgrouplist (s.pw_name);
    return 0;
    }

  if (Id_User)
    @str = s.pw_name;

  return 0;
}

define getgrouplistgid (name, gid)
{
  variable
    groups = {gid},
    line,
    rec,
    ar = readfile ("/etc/group");

  if (NULL == ar)
    return NULL;
 
  foreach line (ar)
    {
    rec = strchop (strtrim_end (line), ':', 0);
    if (match_user (rec[-1], name) && 0 == (rec[2] == gid))
      list_append (groups, string (rec[2]));
    }
 
  return strjoin (list_to_array (groups), " ");
}

define id_real (s, str)
{
  if (Id_Group)
    {
    @str = s.pw_gid;
    return 0;
    }

  if (Id_Groups)
    {
    @str =  getgrouplistgid (s.pw_name, s.pw_gid);
    return 0;
    }

  if (Id_User)
    @str = s.pw_uid;

  return 0;
}

define id_all (s)
{
  variable str, output = "uid=";

  Id_User = 1;
  if (-1 == id_real (s, &str))
    return -1;
  else
    output += __tmp (str);

  if (-1 == id_name (s, &str))
    return -1;
  else
    {
    Id_User = 0;
    output += sprintf ("(%s)", __tmp (str));
    }

  Id_Group = 1;
  if (-1 == id_real (s, &str))
    return -1;
  else
    output += sprintf (" gid=%s", __tmp (str));

  if (-1 == id_name (s, &str))
    return -1;
  else
    {
    Id_Group = 0;
    output += sprintf ("(%s) groups=", __tmp (str));
    }

  Id_Groups = 1;
  if (-1 == id_real (s, &str))
    return -1;

  variable gids = strtok (__tmp (str));

  if (-1 == id_name (s, &str))
    return -1;

  variable grnames = strtok (str);
 
  _for (0, length (gids) - 1, 1)
    {
    variable index = ();
    output += sprintf ("%s(%s),", gids[index], grnames[index]);
    }
 
  output = strtrim_end (output, ",");
 
  (@print_out) (output);

  return 0;
}

define id_main (s)
{
  variable str;
  if (Id_Name)
    if (-1 == id_name (s, &str))
      return -1;
    else
      {
      (@print_out) (str);
      return 0;
      }
 
  if (Id_Real)
    if (-1 == id_real (s, &str))
      return -1;
    else
      {
      (@print_out)  (str);
      return 0;
      }
 
  if (Id_User)
    if (-1 == id_real (s, &str))
      return -1;
    else
      {
      (@print_out) (str);
      return 0;
      }
 
  if (Id_Group)
    if (-1 == id_real (s, &str))
      return -1;
    else
      {
      (@print_out) (str);
      return 0;
      }
 
  if (Id_Groups)
    if (-1 == id_real (s, &str))
      return -1;
    else
      {
      (@print_out) (str);
      return 0;
      }
}

define main ()
{
  variable
    groups_mode,
    whoami_mode,
    name,
    t,
    err,
    i,
    s,
    c = cmdopt_new (&_usage);

  c.add("g|group", &Id_Group);
  c.add("G|groups", &Id_Groups);
  c.add("n|name", &Id_Name);
  c.add("r|real", &Id_Real);
  c.add("u|user", &Id_User);
  c.add("help", &_usage);
  c.add("info", &info);

  i = c.process (__argv, 1);

  if ("groups" == __argv[0])
    {
    groups_mode = 1;
    Id_Name = 1;
    Id_Groups = 1;
    }

  if ("whoami" == __argv[0])
    {
    whoami_mode = 1;
    Id_Name = 1;
    Id_User = 1;
    }

  t = Id_Group + Id_Groups + Id_User;
  if (t == 0 && (Id_Name || Id_Real))
    {
    (@print_err) (sprintf (
      "%s: cannot print only names or real IDs in default format", __argv[0]));
    return 1;
    }
  else if (t > 1)
    {
    (@print_err) (sprintf (
      "%s: cannot print \"only\" of more than one choice", __argv[0]));
    return 1;
    }

  if (i < __argc)
    if (2 == __argc - i)
      {
      (@print_err) (sprintf (
        "%s: extra operand `%s'", __argv[0], __argv[-1]));
      return 1;
      }
    else if (1 == __argc - i && __is_initialized (&whoami_mode))
      {
      (@print_err) (sprintf (
        "%s: extra operand `%s'", __argv[0], __argv[-1]));
      return 1;
      }
    else
      name = __argv[-1];

  ifnot (__is_initialized (&name))
    {
    s = get_name ();
 
    if (NULL == name)
      {
      err = ();
      (@print_err) (err);
      return 1;
      }

    name = s[0];
    }
  else
    {
    s = get_name (name);

    if (NULL == s)
      {
      err = ();
      (@print_err) (err);
      return 1;
      }
    }

  if ((__argc == 1 || 0 == t)
      && 0 == __is_initialized (&groups_mode)
      && 0 == __is_initialized (&whoami_mode))
    if (-1 == id_all (s))
      return 1;
    else
      return 0;
 
  if (-1 == id_main (s))
    return 1;
 
  return 0;
}
