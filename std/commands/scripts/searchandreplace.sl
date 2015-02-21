import ("pcre");

() = evalfile ("fswalk");

variable
  MAXDEPTH = 1,
  HIDDENDIRS = 0,
  HIDDENFILES = 0,
  SUBSTITUTEARRAY = Any_Type[0],
  WHENSUBST = NULL,
  WHENWRITE = NULL,
  BACKUP = NULL,
  SUFFIX = "~",
  GLOBAL = NULL,
  SUBSTITUTE = NULL,
  PAT = NULL,
  NEWLINES = 0,
  INPLACE = NULL,
  NUMCHANGES,
  DIFFEXEC = which ("diff"),
  RECURSIVE = NULL,
  EXIT_CODE = 0;

define assign_func (func)
{
  switch (func)

    {
    case "rmspacesfromtheend":
      PAT = "(.)\\s+$";
      SUBSTITUTE = "\\1";
      WHENSUBST = 1;
      WHENWRITE = 1;
      INPLACE = 1;
      GLOBAL = 1;
    }
}

define assign_substitute ()
{
  variable
    sub,
    i = 1,
    len = strlen (SUBSTITUTE);

  while (i <= len)
    {
    sub = substr (SUBSTITUTE, i, 1);

    if (sub == "\\")
      {
      sub = substr (SUBSTITUTE, i + 1, 1);
      i += 2;

      if (__is_datatype_numeric (_slang_guess_type (sub)))
        {
        SUBSTITUTEARRAY = [SUBSTITUTEARRAY, integer (sub)];
        continue;
        }

      switch (sub)
        {
        case "\\" : SUBSTITUTEARRAY = [SUBSTITUTEARRAY, "\\"];
        continue;
        }

        {
        case "n" : SUBSTITUTEARRAY = [SUBSTITUTEARRAY, "\n"];
        continue;
        }

        {
        case "t" : SUBSTITUTEARRAY = [SUBSTITUTEARRAY, "\t"];
        continue;
        }
 
        {
        case "s" : SUBSTITUTEARRAY = [SUBSTITUTEARRAY, " "];
        continue;
        }

        {
        EXIT_CODE = 1;
        }
      }

    SUBSTITUTEARRAY = [SUBSTITUTEARRAY, sub];
    i++;
    }
}

define unified_diff (file, ar)
{
  variable
    pid,
    status,
    stdinr,
    stdinw,
    stdoutr,
    stdoutw,
    diff = "",
    in_fd = dup_fd (fileno (stdin)),
    out_fd = dup_fd (fileno (stdout));

  (stdoutr, stdoutw) = pipe ();
  (stdinr, stdinw) = pipe ();
 
  () = write (stdinw, strjoin (ar, "\n") + "\n");
  () = close (stdinw);

  pid = fork ();

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stdinr, 0);

  if ((0 == pid) && -1 == execv (DIFFEXEC, [DIFFEXEC, "-u", file, "-"]))
    {
    (@print_err) ("couldn't create diff process");
    return NULL;
    }

  status = waitpid (pid, 0);
 
  () = dup2_fd (in_fd, 0);
  () = dup2_fd (out_fd, 1);
  () = _close (_fileno (stdoutw));
  () = _close (_fileno (stdinw));

  diff = read_fd (stdoutr);

  return strtok (diff, "\n");
}

define search_and_replace (file)
{
  variable
    ia,
    tok,
    chr,
    str,
    type,
    match,
    fpart,
    lpart,
    retval,
    context,
    replace,
    finished,
    i = 0,
    found = 0,
    matches = 0,
    ar = readfile (file);

  NUMCHANGES = 0;

  while (i < length (ar))
    {
    if (i + NEWLINES > length (ar) - 1)
      break;

    str = strjoin (ar[[i:i+NEWLINES]], NEWLINES ? "\n" : "");
 
    found = pcre_exec (PAT, str, 0);

    if (found)
      {
      matches++;
      finished = "";
      do
        {
        % CHECK IF PCRE return chars or bytes
        match = pcre_nth_match (PAT, 0);
        fpart = substr (str, 1, match[0]);
        context = substr (str, match[0] + 1, match[1] - match[0]);
        lpart = substr (str, match[1] + 1, -1);
 
        replace = "";

        _for ia (0, length (SUBSTITUTEARRAY) - 1)
          {
          chr = @SUBSTITUTEARRAY[ia];
          type = typeof (chr);

          switch (type)
            {
            case Integer_Type :
              if (found - 1 < chr)
                return "Captured substrings are less than the requested", NULL;
              else
                replace += pcre_nth_substr (PAT, str, chr);
            }

            {
            case String_Type :
              if (chr == "&")
                replace += context;
              else
                replace += chr;
            }
          }

        if (NULL == WHENSUBST)
          {
          variable
            lfpart = strreplace (fpart, "\n", "\\n"),
            lcontext = strreplace (context, "\n", "\\n"),
            llpart = strreplace (lpart, "\n", "\\n"),
            lreplace = strreplace (replace, "\n", "\\n");

          retval = (@ask) (
            [repeat ("_", COLUMNS),
             sprintf ("file: %s, line number: %d", file, i+1),
             "Do you want to replace the highlighted in red text?",
             repeat ("_", COLUMNS),
             sprintf ("%s%s%s", lfpart, lcontext, llpart),
             repeat ("_", COLUMNS),
             "with the highlighted in green text?",
             repeat ("_", COLUMNS),
             sprintf ("%s%s%s", lfpart, lreplace, llpart),
             repeat ("_", COLUMNS),
             "y[es replace]",
             "n[o  dont replace]",
             "q[uit all the replacements]",
             "a[ll replace all, dont ask again for this file]",
             "escape , same as no"],
             ['y', 'n', 'q', 'a']; hl = [
               struct {color = 1, row = 5, col = strlen (lfpart), dr = 1, dc = strlen (lcontext)},
               struct {color = 2, row = 9, col = strlen (lfpart), dr = 1, dc = strlen (lreplace)}]);

           switch (retval)

             {
             case 'n' || case 033: break;
             }

             {
             case 'a': WHENSUBST = 1;
             }

             {
             case 'q':
               if (NUMCHANGES)
                 return ar, 0;
               else
                 return 1;
             }
          }

        finished += sprintf ("%s%s", fpart, replace);
        str = lpart;
        NUMCHANGES ++;
        }
      while (found = pcre_exec (PAT, str, 0), found && NULL != GLOBAL);

      tok = strtok (sprintf ("%s%s", finished, str), "\n");

      if (i)
        ar = [ar[[:i-1]], tok, ar[[i+1+NEWLINES:]]];
      else
        ar = [tok, ar[[i+1+NEWLINES:]]];

      if (NULL == GLOBAL)
        return ar, 0;

      i += length (tok);
      continue;
      }

    i++;
    }

  ifnot (NUMCHANGES)
    return 1;

  return ar, 0;
}

private define sed (file)
{
  variable
    ar,
    err,
    undiff,
    retval,
    st = qualifier ("st", stat_file (file));
 
  ifnot (stat_is ("reg", st.st_mode))
    {
    (@print_err) (sprintf
      ("cannot operate on special file `%s': Operation not permitted", file));
    return;
    }
 
  retval = search_and_replace (file);

  if (NULL == retval)
    {
    err = ();
    (@print_err) (err);
    EXIT_CODE = 1;
    }
  else if (0 == retval)
    ifnot (NULL == INPLACE)
      {
      ar = ();

      if (NULL == WHENWRITE)
        {
        undiff = unified_diff (file, ar);
        retval = (@ask) ([
          sprintf ("write changes to `%s' ?", file),
          "y[es]",
          "n[o]",
          NULL == undiff ? "No diff available"
                         : ["    UNIFIED DIFF", repeat ("_", COLUMNS), undiff]
          ], ['y', 'n']);
 
        if ('n' == retval)
          return;
          }
 
      try
        {
        writefile (ar, file);
        (@print_out) (sprintf ("%s: was written, with %d changes", file, NUMCHANGES));
        }
      catch AnyError:
        {
        view_exception (["WRITTING ERROR", exception_to_array ()]);
        }
      }
}

private define file_callback (file, st)
{
  ifnot (HIDDENFILES)
    if ('.' == path_basename (file)[0])
      return 1;

  sed (file;st = st);

  return 1;
}

private define dir_callback (dir, st)
{
  ifnot (HIDDENDIRS)
    if ('.' == path_basename (dir)[0])
      return 0;

  if (length (strtok (dir, "/")) > MAXDEPTH)
    return 0;

  return 1;
}

define main ()
{
  variable
    i,
    fs,
    ia,
    err,
    files,
    maxdepth = 0,
    c = cmdopt_new (&_usage);

  c.add ("dont-ask-when-subst", &WHENSUBST);
  c.add ("dont-ask-when-write", &WHENWRITE);
  c.add ("hidden-dirs", &HIDDENDIRS);
  c.add ("hidden-files", &HIDDENFILES);
  c.add ("maxdepth", &maxdepth;type = "int");
  c.add ("rmspacesfromtheend", &assign_func, "rmspacesfromtheend");
  c.add ("pat", &PAT;type = "string");
  c.add ("sub", &SUBSTITUTE;type = "string");
  c.add ("in-place", &INPLACE);
  c.add ("recursive", &RECURSIVE);
  c.add ("backup", &BACKUP);
  c.add ("suffix", &SUFFIX;type = "string");
  c.add ("global", &GLOBAL);
  c.add ("help", &_usage);
  c.add ("info", &info);

  i = c.process (__argv, 1);

  if (i == __argc)
    {
    (@print_err) (sprintf ("%s: argument (filename) is required", __argv[0]));
    return 1;
    }
 
  if (NULL == PAT || NULL == SUBSTITUTE)
    {
    (@print_err) ("--pat and --sub can not be NULL";print_in_msg_line);
    return 1;
    }

  if (NULL == DIFFEXEC)
    if (NULL == WHENWRITE)
      (@print_err) ("diff executable couldn't be found, unified diff will be disabled");

  assign_substitute ();

  if (EXIT_CODE)
    {
    (@print_err) ("Waiting one of \"t,n,s,\\,integer\" after the backslash");
    return 1;
    }

  if (NULL == RECURSIVE)
    maxdepth = 1;
  else
    ifnot (maxdepth)
      maxdepth = 1000;
    else
      maxdepth++;

  _for ia (1, strlen (PAT) - 1)
    if ('n' == PAT[ia] && '\\' == PAT[ia - 1])
      NEWLINES++;

  try (err)
    {
    PAT = pcre_compile (PAT, 0);
    }
  catch ParseError:
    {
    (@print_err) (err.descr);
    return 1;
    }

  files = __argv[[i:]];
  files = files[where (strncmp (files, "--", 2))];

  _for i (0, length (files) - 1)
    {
    if (-1 == access (files[i], F_OK))
      {
      (@print_err) (sprintf ("%s: No such file", files[i]));
      continue;
      }

    if (-1 == access (files[i], R_OK))
      {
      (@print_err) (sprintf ("%s: Is not readable", files[i]));
      continue;
      }

    if (INPLACE)
      if (-1 == access (files[i], W_OK))
        {
        (@print_err) (sprintf ("%s: Is not writable", files[i]));
        continue;
        }

    if (isdirectory (files[i]))
      {
      fs = fswalk_new (&dir_callback, &file_callback);
      MAXDEPTH = length (strtok (files[i], "/")) + maxdepth;
      fs.walk (files[i]);

      continue;
      }

    sed (files[i]);
    }

  return EXIT_CODE;
}
