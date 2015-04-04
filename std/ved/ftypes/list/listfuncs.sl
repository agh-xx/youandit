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
    cw_ = fnames[fns[fn]];
    if (cw_._flags & RDONLY || 0 == cw_._flags & MODIFIED ||
        (0 == qualifier_exists ("force") && "q!" == rl_.argv[0]))
      continue;

    send_msg_dr (sprintf ("%s: save changes? y[es]|n[o]", cw_._fname), 0, NULL, NULL);

    chr = get_char ();
    while (0 == any (chr == ['y', 'n']))
      chr = get_char ();
    
    if ('n' == chr)
      continue;

    ifnot (0 == s_.writefile (cw_._fname))
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
  c.ptr = Integer_Type[2];
  c.cols = Integer_Type[len];
  c.cols[*] = 0;
  c.clrs = Integer_Type[len];
  c.clrs[*] = 0;
  c._avlins = len - 1;
  c._maxlen = COLUMNS;
  c._flags = 0;
  c.lines = readfile (s.fname);
  c._len = length (c.lines) - 1;
  c._fname = s.fname;
  c.st_ = stat_file (c._fname);
  c._i = c._len >= s.lnr - 1 ? s.lnr - 1 : 0;
  c.ptr[0] = qualifier ("row", 1);
  c.ptr[1] = qualifier ("col", s.col - 1);
  c._indent = qualifier ("indent", 0);
}

private define togglecur ()
{
  cw_.clrs[-1] = INFOCLRBG;
  srv->set_color_in_region (INFOCLRBG, cw_.rows[-1], 0, 1, COLUMNS);
  IMG[cw_.rows[-1]][1] = INFOCLRBG;
  frame = frame ? 0 : 1;
  prev_fn = cw_._fname;
}

private define set_cw (fname)
{
  cw_ = fnames[fname];
  cw_.clrs[-1] = INFOCLRFG;
  IMG[cw_.rows[-1]][1] = INFOCLRFG;
  srv->set_color_in_region (INFOCLRFG, cw_.rows[-1], 0, 1, COLUMNS);
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
  set_cw (l.fname);
 
  s_.draw ();
}

private define chframe ()
{
  if (1 == length (fnames))
    return;
  variable fn = prev_fn;
  togglecur ();
  set_cw (fn);

  srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
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

  set_cw (s.fname);
  prev_fn = s.fname;

  clear (1, LINES);

  srv->set_color_in_region (INFOCLRBG, cw_.rows[0] - 1, 0, 1, COLUMNS);
  
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
    cw_._chr = get_char ();
 
    if ('0' <= cw_._chr <= '9')
      {
      count = "";
 
      while ('0' <= cw_._chr <= '9')
        {
        count += char (cw_._chr);
        cw_._chr = get_char ();
        }

      count = integer (count);
      }

    if (any (pagerc == cw_._chr))
      (@pagerf[string (cw_._chr)]);
 
    if (':' == cw_._chr)
      rlf_.read ();

    if (cw_._chr == 'q')
      (@clinef["q"]) (;force);
    }
}
