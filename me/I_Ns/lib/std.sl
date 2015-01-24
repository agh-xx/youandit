define print_ar_to_fp (ar, fmt, fp)
{
  variable
    bts = int (sum (array_map (Integer_Type, &fprintf, fp, fmt, ar)));
 
  () = fflush (fp);

  return bts;
}

define isdirectory (file)
{
  variable st = qualifier ("st", stat_file (file));
  return NULL != st && stat_is ("dir", st.st_mode);
}

define which (executable)
{
  variable
    ar,
    path;

  path = getenv ("PATH");
  if (NULL == path)
    return NULL;

  path = strchop (path, path_get_delimiter (), 0);
  path = array_map (String_Type, &path_concat, path, executable);
  path = path [wherenot (array_map (Integer_Type, &isdirectory, path))];

  ar = wherenot (array_map (Integer_Type, &access, path, X_OK));

  if (length (ar))
    return path[ar][0];
  else
    return NULL;
}

define readfile (file)
{
  variable
    end = qualifier ("end", NULL),
    fp = fopen (file, "r");

  if (NULL == fp)
    return NULL;

  ifnot (NULL == end)
    return array_map (String_Type, &strtrim_end, fgetslines (fp, end), "\n");

  return array_map (String_Type, &strtrim_end, fgetslines (fp), "\n");
}

define writefile (buf, fname)
{
  variable
    mode = qualifier ("mode", "w"),
    fmt = qualifier ("fmt", "%s\n"),
    fp = fopen (fname, mode);

  if (NULL == fp)
    throw OpenError, "Error while opening $fname"$;

  if (any (-1 == array_map (Integer_Type, &fprintf, fp, fmt, buf)))
    throw WriteError, "Error while writting $fname"$;

  if (-1 == fclose (fp))
    throw IOError, errno_string(errno);
}

define repeat (chr, count)
{
  ifnot (0 < count)
    return "";

  variable ar = String_Type[count];
  ar[*] = chr;
  return strjoin (ar);
}

define struct_field_exists (s, field)
{
  return wherefirst (get_struct_field_names (s) == field);
}

define eval_dir (dir)
{
  if ('~' == dir[0])
    (dir,) = strreplace (dir, "~", getenv ("HOME"), 1);
  else if (0 == path_is_absolute (dir)
          && '$' != dir[0]
          && 0 == qualifier_exists ("dont_change"))
    dir = path_concat (getcwd (), dir);
  else
    dir = eval ("\"" + dir + "\"$");

  return dir;
}

define assoc_add_key (map, key, val)
{
  map[key] = val;
}

define read_fd (fd)
{
  variable
    buf,
    str = "";

  while (read (fd, &buf, 1024) > 0)
    str = sprintf ("%s%s", str, buf);

  return strlen (str) ? str : NULL;
}

define are_same_files (fnamea, fnameb)
{
  variable
    sta = qualifier ("fnamea_st", stat_file (fnamea)),
    stb = qualifier ("fnameb_st", stat_file (fnameb));

  if (any ((sta == NULL) or (stb == NULL)))
    return 0;

  if (sta.st_ino == stb.st_ino && sta.st_dev == stb.st_dev)
    return 1;

  return 0;
}

define pid_status (pid)
{
  variable
    buf,
    fp = popen (sprintf ("ps --no-headers --pid %d", pid), "r");
 
  if (-1 == fgets (&buf, fp))
    return 0;

  if ("<defunct>" == strtok (strtrim_end (buf))[-1])
    return -1;

  return 1;
}
