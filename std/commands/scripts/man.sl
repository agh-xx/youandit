import ("pcre");

ineed ("fswalk");
ineed ("copyfile");
ineed ("strtoint");

private variable
  MANDIR = "/usr/share/man/",
  LOCALMANDIR = "/usr/local/share/man/",
  MYMANDIR = sprintf ("%s/man", TEMPDIR),
  DATA_DIR = sprintf ("%s/man", DATADIR);

define getpage (page)
{
  variable
    i,
    p,
    ar,
    st,
    pid,
    match,
    matchfn,
    status,
    outfn = sprintf ("%s/Man_Page_Out.txt", MYMANDIR),
    fname = sprintf ("%s/Man_Page_Fname.txt", MYMANDIR),
    errfn = sprintf ("%s/Man_Page_Fname_ERRORS.txt", MYMANDIR),
    colfn = sprintf ("%s/Man_Page_Fname_col.txt", MYMANDIR),
    gzip = which ("gzip"),
    groff = which ("groff"),
    col = which ("col"),
    manpages = String_Type[0],
    matches = String_Type[0];
 
  if (".gz" == path_extname (page))
    {
    p = proc->init (0, 1, 0);
    p.stdout.file = fname;
 
    status = p.execv ([gzip, "-dc", page], NULL);
 
    p = proc->init (0, 1, 1);
    p.stdout.file = outfn;
    p.stderr.file = errfn;
 
    status = p.execv ([groff, "-Tutf8", "-m", "man", fname], NULL);
    }
  else
    {
    fname = page;
    p = proc->init (0, 1, 1);
    p.stdout.file = outfn;
    p.stderr.file = errfn;
 
    status = p.execv ([groff, "-Tutf8", "-m", "man", fname], NULL);
    }

  ar = readfile (errfn);
 
  errfn = STDERR;

  if (length (ar))
    {
    for (i = 0; i < length (ar); i++)
      {
      match = string_matches (ar[i], "`.*'", 1)[0];
      if (NULL == match)
        continue;

      match = match[[1:strlen (match) - 2]];
      page = sprintf ("%s/%s", MANDIR, match);
      st = stat_file (page);
      if (NULL == st)
        page = sprintf ("%s.gz", page);
 
      st = stat_file (page);
      if (NULL == st)
        continue;
      matches = [matches, match];
      manpages = [manpages, page];
      }

    _for i (0, length (manpages) - 1)
      {
      page = manpages[i];
      match = matches[i];

      if (".gz" == path_extname (page))
        {
        matchfn = sprintf ("%s/%s", MYMANDIR, match);
        p = proc->init (0, 1, 1);
        p.stdout.file = matchfn;
        p.stderr.file = errfn;
 
        status = p.execv ([gzip, "-dc", page], NULL);
        }
      else
        copyfile (page, sprintf ("%s/%s", MYMANDIR, match));
      }

    p = proc->init (0, 1, 1);
    p.stdout.file = outfn;
    p.stderr.file = errfn;
 
    status = p.execv ([groff, "-Tutf8", "-m", "man", "-I", MYMANDIR, fname], NULL);
    _for i (0, length (manpages) - 1)
      {
      page = manpages[i];
      match = matches[i];
      () = remove (sprintf ("%s/%s", MYMANDIR, match));
      }
    }
 
  p = proc->init (1, 1, 1);
  p.stderr.file = errfn;
  p.stdout.file = colfn;
  p.stdin.file = outfn;
 
  status = p.execv ([col, "-b"], NULL);

  return readfile (colfn), status.exit_status;
}

define file_callback (file, st, filelist)
{
  list_append (filelist, file);

  return 1;
}

define main ()
{
  variable
    i,
    ar,
    pos,
    pat,
    page,
    retval,
    man_page,
    search = NULL,
    options = 0,
    cache = NULL,
    cachefile = sprintf ("%s/cache.txt", DATA_DIR),
    c = cmdopt_new (&_usage);

  if (-1 == access (DATA_DIR, F_OK))
    {
    if (-1 == mkdir (DATA_DIR))
      {
      (@print_err) (sprintf ("cannot create %s", DATA_DIR));
      return 1;
      }

    }
  if (-1 == access (MYMANDIR, F_OK))
    {
    if (-1 == mkdir (MYMANDIR))
      {
      (@print_err) (sprintf ("cannot create %s", MYMANDIR));
      return 1;
      }

    () = array_map (Integer_Type, &mkdir, array_map (String_Type, &sprintf,
      "%s/man%d", MYMANDIR, [0:8]));
    }

  c.add ("search", &search;type="string");
  c.add ("caseless", &options;bor = PCRE_CASELESS);
  c.add ("buildcache", &cache);
  c.add ("help", &_usage);
  c.add ("info", &info);

  i = c.process (__argv, 1);

  ifnot (NULL == cache)
    {
    variable
      fs,
      lu = strlen (MANDIR),
      ll = strlen (LOCALMANDIR),
      ulist = {},
      llist = {};

    fs = fswalk_new (NULL, &file_callback;fargs = {llist});
    fs.walk (LOCALMANDIR);
    llist = list_to_array (llist, String_Type);
    llist = llist[where ("man" == array_map (String_Type,  &substr, llist, ll + 1, 3))];

    fs = fswalk_new (NULL, &file_callback;fargs = {ulist});
    fs.walk (MANDIR);
    ulist = list_to_array (ulist, String_Type);
    ulist = ulist[where ("man" == array_map (String_Type,  &substr, ulist, lu + 1, 3))];
 
    variable list = [llist, ulist];

    _for i (0, length (list) - 1)
      {
      variable st = stat_file (list[i]);
      if (NULL == st || stat_is ("dir", st.st_mode))
        list[i] = NULL;
      }

    list = list[wherenot (_isnull (list))];
    ifnot (length (list))
      {
      (@print_err) ("no man page found"; print_in_msg_line);
      return 1;
      }

    writefile (list, cachefile);
    return 0;
    }

  ifnot (NULL == search)
    {
    if (-1 == access (cachefile, F_OK))
      {
      (@print_err) (sprintf ("%s: cache file not found, run again with --buildcache",
        cachefile); print_in_msg_line);
      return 1;
      }

    cache = readfile (cachefile);
    pat = pcre_compile (search, options);
    pos = strlen (MANDIR) + 4;
    man_page = String_Type[0];

    _for i (0, length (cache) - 1)
      if (pcre_exec (pat, cache[i], pos))
        man_page = [man_page, cache[i]];

    ifnot (length (man_page))
      {
      (@print_err) (sprintf ("%s: no man page matches the regexp", search); print_in_msg_line);
      return 1;
      }

    if (1 == length (man_page))
      {
      (ar, retval) = getpage (man_page[0]);
      array_map (Void_Type, print_out, ar);
      return retval;
      }
 
    ar = array_map (String_Type, &path_basename, man_page);
    _for i (0, length (ar) - 1)
      ar[i] = strchop (ar[i], '.', 0)[1];
 
    variable sorted = array_sort (ar);
    ar = ar[sorted];
    man_page = man_page[sorted];

    ar = array_map (String_Type, &sprintf, "%s (%s)",
      array_map (String_Type, &path_basename_sans_extname, man_page), ar);

    retval = (@ask) ([
      sprintf ("There %d man pages that match", length (man_page)),
      " ",
      array_map (String_Type, &sprintf, "%d: %s", [1:length (man_page)], ar),
      "escape, quit question and abort the operation"
      ], NULL;get_ascii_input, prompt = "Which page? (integer) ");

    if (NULL == retval || 0 == strlen (retval))
      {
      (@print_err) ("man: Aborting ..."; print_in_msg_line);
      return 1;
      }

    retval = strtoint (retval);
    if (NULL == retval)
      {
      (@print_err) ("man: Selection is not an integer, Aborting ..."; print_in_msg_line);
      return 1;
      }

    retval--;

    man_page = man_page[retval];

    (ar, retval) = getpage (man_page);
    array_map (Void_Type, print_out, ar);
    return retval;
    }

  if (i == __argc)
    {
    (@print_err) ("man: argument is required"; print_in_msg_line);
    return 1;
    }

  page = __argv[i];

  ifnot (access (page, F_OK))
    {
    (ar, retval) = getpage (page);
    array_map (Void_Type, print_out, ar);
    return retval;
    }
  else
    {
    if (-1 == access (cachefile, F_OK))
      {
      (@print_err) (sprintf (
        "%s: cache file not found, run again with --buildcache", cachefile); print_in_msg_line);
      return 1;
      }

    cache = readfile (cachefile);
    pat = pcre_compile (sprintf ("/%s\\056[0-9]", page), options);
    pos = strlen (MANDIR) + 4;
    man_page = NULL;

    _for i (0, length (cache) - 1)
      if (pcre_exec (pat, cache[i], pos))
        {
        man_page = cache[i];
        break;
        }

    if (NULL == man_page)
      {
      (@print_err) (sprintf ("%s: man page haven't been found", page); print_in_msg_line);
      return 1;
      }

    (ar, retval) = getpage (man_page);
    array_map (Void_Type, print_out, ar);
    return retval;
    }
}
