private variable
  fnames = Assoc_Type[Frame_Type],
  frame = 1,
  prev_fn = NULL,
  defrows = {[1:LINES - 9], [LINES - 8:LINES - 3]};

private define myquit ()
{
  variable
    fn,
    chr,
    fns = assoc_get_keys (fnames);

  _for fn (0, length (fns) - 1)
    {
    cf_ = fnames[fns[fn]];
    if (cf_._flags & RDONLY || 0 == cf_._flags & MODIFIED ||
        (0 == qualifier_exists ("force") && "q!" == rl_.argv[0]))
      continue;

    send_msg_dr (sprintf ("%s: save changes? y[es]|n[o]", cf_._fname), 0, NULL, NULL);

    chr = get_char ();
    while (0 == any (chr == ['y', 'n']))
      chr = get_char ();
 
    if ('n' == chr)
      continue;

    ifnot (0 == s_.writefile (cf_._fname))
      {
      send_msg_dr (sprintf ("%s, press q to quit without saving", errno_string (errno)),
        1, NULL, NULL);

      if ('q' == get_char ())
        return;
      }
    }
 
  send_msg (" ", 0);
  exit_me (0);
}

private define add (s, rows)
{
  if (assoc_key_exists (fnames, s.fname))
    return;

  fnames[s.fname] = @Frame_Type;

  variable
    c = fnames[s.fname],
    len = length (rows);
 
  c.rows = rows;
  c._indent = qualifier ("indent", 0);
  c.ptr = Integer_Type[2];
  c.cols = Integer_Type[len];
  c.cols[*] = 0;
  c.clrs = Integer_Type[len];
  c.clrs[*] = 0;
  c._avlins = len - 1;
  c._maxlen = COLUMNS;
  c._flags = 0;
  c.lines = readfile (s.fname);
  if (NULL == c.lines)
    c.lines = [sprintf ("%s\000", repeat (" ", c._indent))];
  c._len = length (c.lines) - 1;
  c._fname = s.fname;
  c._i = c._len >= s.lnr - 1 ? s.lnr - 1 : 0;
  c.ptr[0] = qualifier ("row", 1);
  c.ptr[1] = qualifier ("col", s.col - 1);
  c._findex = 0;
  c._index = c.ptr[1];

  c.st_ = stat_file (c._fname);
  if (NULL == c.st_)
    c.st_ = struct
      {
      st_atime,
      st_mtime,
      st_uid = getuid (),
      st_gid = getgid (),
      st_size = 0
      };
}

private define togglecur ()
{
  cf_.clrs[-1] = INFOCLRBG;
  srv->set_color_in_region (INFOCLRBG, cf_.rows[-1], 0, 1, COLUMNS);
  IMG[cf_.rows[-1]][1] = INFOCLRBG;
  frame = frame ? 0 : 1;
  prev_fn = cf_._fname;
}

private define set_cf (fname)
{
  cf_ = fnames[fname];
  cf_.clrs[-1] = INFOCLRFG;
  IMG[cf_.rows[-1]][1] = INFOCLRFG;
  srv->set_color_in_region (INFOCLRFG, cf_.rows[-1], 0, 1, COLUMNS);
}

private define getitem ()
{
  variable
    line = v_lin ('.'),
    tok = strchop (line, '|', 0),
    col = atoi (strtok (tok[1])[2]),
    lnr = atoi (strtok (tok[1])[0]),
    fname;
 
  ifnot (path_is_absolute (tok[0]))
    fname = path_concat (getcwd (), tok[0]);
  else
    fname = tok[0];

  if (-1 == access (fname, F_OK))
    {
    () = fprintf (stderr, "%s: No such filename", fname);
    return NULL;
    }

  return struct {lnr = lnr, col = col, fname = fname};
}

private define drawfile ()
{
  ifnot (frame)
    return;
 
  variable l = getitem ();

  if (NULL == l)
    return;

  togglecur ();
 
  add (l, defrows[0]);
  set_cf (l.fname);
 
  s_.draw ();
}

private define chframe ()
{
  if (1 == length (fnames))
    return;
  variable fn = prev_fn;
  togglecur ();
  set_cf (fn);

  srv->gotorc_draw (cf_.ptr[0], cf_.ptr[1]);
}

pagerf[string ('\r')] = &drawfile;
pagerf[string (keys->CTRL_w)] = &chframe;

pagerc = array_map (Integer_Type, &integer, assoc_get_keys (pagerf));

define ved ()
{
  s_.quit = &myquit;

  clinef["q"] = &myquit;
  clinef["q!"] = &myquit;

  variable s = struct
    {
    fname = get_file (),
    lnr = 1,
    col = 0,
    };

  add (s, defrows[1];row = defrows[1][0], col = 0);

  set_cf (s.fname);
  prev_fn = s.fname;

  clear (1, LINES);

  srv->set_color_in_region (INFOCLRBG, cf_.rows[0] - 1, 0, 1, COLUMNS);
 
  s_.draw ();

  variable func = get_func ();
  if (func)
    {
    count = get_count ();
    if (any (pagerc == func))
      (@pagerf[string (func)]);
    }

  if (DRAWONLY)
    return;

  topline_dr (" (ved)  -- PAGER --");

  forever
    {
    count = -1;
    cf_._chr = get_char ();
 
    if ('0' <= cf_._chr <= '9')
      {
      count = "";
 
      while ('0' <= cf_._chr <= '9')
        {
        count += char (cf_._chr);
        cf_._chr = get_char ();
        }

      count = integer (count);
      }

    if (any (pagerc == cf_._chr))
      (@pagerf[string (cf_._chr)]);
 
    if (':' == cf_._chr)
      rlf_.read ();

    if (cf_._chr == 'q')
      (@clinef["q"]) (;force);
    }
}
