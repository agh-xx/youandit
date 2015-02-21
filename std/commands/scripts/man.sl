import ("pcre");

ineed ("fswalk");
ineed ("copyfile");
ineed ("strtoint");

private variable
  MANDIR = "/usr/share/man/",
  MYMANDIR = sprintf ("%s/man", TEMPDIR),
  DATA_DIR = sprintf ("%s/man", DATADIR);

define getpage (page)
{
  variable
    i,
    fp,
    ar,
    st,
    pid,
    match,
    matchfd,
    status,
    in_fd = dup_fd (fileno (stdin)),
    out_fd = dup_fd (fileno (stdout)),
    err_fd = dup_fd (fileno (stderr)),
    outfn = sprintf ("%s/Man_Page_Out.txt", MYMANDIR),
    fname = sprintf ("%s/Man_Page_Fname.txt", MYMANDIR),
    errfn = sprintf ("%s/Man_Page_Fname_ERRORS.txt", MYMANDIR),
    colfn = sprintf ("%s/Man_Page_Fname_col.txt", MYMANDIR),
    outfd = open (outfn, O_WRONLY|O_CREAT|O_TRUNC, S_IRWXU),
    fnfd,
    colfd,
    errfd = open (errfn, O_RDWR|O_CREAT|O_TRUNC, S_IRWXU),
    gzip = which ("gzip"),
    groff = which ("groff"),
    col = which ("col"),
    manpages = String_Type[0],
    matches = String_Type[0];
 
  if (".gz" == path_extname (page))
    {
    fnfd = open (fname, O_RDWR|O_CREAT|O_TRUNC, S_IRWXU);
    () = dup2_fd (fnfd, 1);
 
    pid = fork ();

    if ((0 == pid) && -1 == execv (gzip, [gzip, "-dc", page]))
      {
      () = _close (_fileno (fnfd));
      () = dup2_fd (out_fd, 1);
      return ["Failed To Fork gzip"], 1;
      }
 
    status = waitpid (pid, 0);

    () = _close (_fileno (fnfd));
 
    () = dup2_fd (outfd, 1);
    () = dup2_fd (errfd, 2);

    pid = fork ();

    if ((0 == pid) && -1 == execv (groff, [groff, "-Tutf8", "-m", "man", fname]))
      {
      () = _close (_fileno (outfd));
      () = _close (_fileno (errfd));
      () = dup2_fd (out_fd, 1);
      () = dup2_fd (err_fd, 2);
      return ["Failed To Fork groff"], 1;
      }
    }
  else
    {
    fname = page;
    () = dup2_fd (outfd, 1);
    () = dup2_fd (errfd, 2);

    pid = fork ();

    if ((0 == pid) && -1 == execv (groff, [groff, "-Tutf8", "-m", "man", page]))
      {
      () = _close (_fileno (outfd));
      () = _close (_fileno (errfd));
      () = dup2_fd (out_fd, 1);
      () = dup2_fd (err_fd, 2);
      return ["Failed To Fork groff"], 1;
      }
    }

  status = waitpid (pid, 0);
 
  () = _close (_fileno (errfd));

  errfd = fileno (STDERRFP);
  () = dup2_fd (errfd, 2);

  ar = readfile (errfn);
  if (length (ar))
    {
    for (i=0; i < length (ar); i++)
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
        matchfd = open (sprintf ("%s/%s", MYMANDIR, match),
          O_RDWR|O_CREAT|O_TRUNC, S_IRWXU);

        () = dup2_fd (matchfd, 1);

        pid = fork ();

        if ((0 == pid) && -1 == execv (gzip, [gzip, "-dc", page]))
          {
          () = _close (_fileno (matchfd));
          () = _close (_fileno (errfd));
          () = dup2_fd (out_fd, 1);
          () = dup2_fd (err_fd, 2);
          return ["Failed To Fork gzip"], 1;
          }

        status = waitpid (pid, 0);

        _close (_fileno (matchfd));
        }
      else
        copyfile (page, sprintf ("%s/%s", MYMANDIR, match));
      }
 
    outfd = open (outfn, O_WRONLY|O_CREAT|O_TRUNC, S_IRWXU);
 
    () = dup2_fd (outfd, 1);
 
    pid = fork ();

    if ((0 == pid) && -1 == execv (groff, [groff, "-Tutf8", "-m", "man", "-I", MYMANDIR,
         fname]))
      {
      () = _close (_fileno (outfd));
      () = _close (_fileno (errfd));
      () = dup2_fd (out_fd, 1);
      () = dup2_fd (err_fd, 2);
      return ["Failed To Fork groff"], 1;
      }

    status = waitpid (pid, 0);

    _for i (0, length (manpages) - 1)
      {
      page = manpages[i];
      match = matches[i];
      () = remove (sprintf ("%s/%s", MYMANDIR, match));
      }
    }

  colfd = open (colfn, O_WRONLY|O_CREAT|O_TRUNC, S_IRWXU);

  outfd = open (outfn, O_RDONLY);
  () = dup2_fd (outfd, 0);
  () = dup2_fd (colfd, 1);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (col, [col, "-b"]))
    {
    () = _close (_fileno (colfd));
    () = _close (_fileno (outfd));
    () = dup2_fd (in_fd, 0);
    () = dup2_fd (out_fd, 1);
    () = dup2_fd (err_fd, 2);
    return ["Failed To Fork col"], 1;
    }

  status = waitpid (pid, 0);
 
  () = _close (_fileno (colfd));
  () = _close (_fileno (outfd));
  () = dup2_fd (in_fd, 0);
  () = dup2_fd (out_fd, 1);
  () = dup2_fd (err_fd, 2);

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
      list = {};

    fs = fswalk_new (NULL, &file_callback;fargs = {list});

    fs.walk (MANDIR);
 
    list = list_to_array (list, String_Type);

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
    (@print_out) ("Cache file was written");
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

    retval --;

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
