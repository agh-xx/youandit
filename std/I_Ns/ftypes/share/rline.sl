typedef struct
  {
  _row,
  _col,
  _chr,
  _lin,
  _ind,
  lnrs,
  argv,
  cmp_lnrs,
  com,
  } Rline_Type;

rl_ = struct
  {
  c_,
  init,
  read,
  rout,
  clear,
  prompt,
  hlitem,
  formar,
  restore,
  getline,
  printout,
  fnamecmp,
  execline,
  delete_at,
  insert_at,
  parse_args,
  w_comp_rout,
  appendslash,
  listdirectory,
  firstindices,
  };

ineed ("f_compl");
ineed ("com_rout");
ineed ("getline"); 

private define init (s)
{
  s.c_ = @Rline_Type;
  s.c_._col = 1;
  s.c_._lin = ":";
  s.c_._row = LINES - 2;
  s.c_._ind = 0;
  s.c_.lnrs = [s.c_._row];
  s.c_.argv = [""];
  s.c_.com = @com;
}

rl_.init = &init;

private define parse_args (s)
{
  variable
    i,
    found = NULL;

  (s.c_._lin, s.c_._ind) = ":", NULL;

  _for i (0, length (s.c_.argv) - 1)
    ifnot (NULL == s.c_.argv[i])
      ifnot (strlen (s.c_.argv[i]))
        if (i)
          if (NULL == found)
            found = 1;
          else
            {
            found = NULL;
            s.c_.argv[i] = NULL;
            s.c_._col--;
            }

  s.c_.argv = s.c_.argv[wherenot (_isnull (s.c_.argv))];
 
  _for i (0, length (s.c_.argv) - 1)
    {
    s.c_._lin = sprintf ("%s%s%s", s.c_._lin, 1 < strlen (s.c_._lin) ? " " : "", s.c_.argv[i]);
 
    if (NULL == s.c_._ind)
      if (s.c_._col <= strlen (s.c_._lin))
        s.c_._ind = i - (s.c_._col == strlen (s.c_._lin) - strlen (s.c_.argv[i]) - 1);
    }
 
  ifnot (strlen (s.c_._lin))
    (s.c_.argv, s.c_._ind) = [""], 0;

  if (NULL == s.c_._ind)
    s.c_._ind = length (s.c_.argv) - 1;

  if (s.c_._col == strlen (s.c_._lin) && 2 == length (s.c_.argv) - s.c_._ind)
    s.c_.argv = s.c_.argv[[:-2]];

  if (s.c_._col > strlen (s.c_._lin) + 1)
    s.c_._col = strlen (s.c_._lin) + 1;
}

rl_.parse_args = &parse_args;

private define printout (s, ar, col, len)
{
  ifnot (length (ar))
    {
    @len = 0;
    return @Array_Type[0];
    }

  variable
    i,
    l,
    lar,
    rows,
    origlen = @len,
    hlreg = qualifier ("hl_region"),
    lines = qualifier ("lines", LINES),
    nar = @len < lines ? @ar : ar[[:lines]];
  
  s.w_comp_rout (nar;;__qualifiers ());

  ifnot (NULL == hlreg)
    srv->set_color_in_region (hlreg[0], hlreg[1], hlreg[2], hlreg[3], hlreg[4];redraw);

  @len = @len >= lines;

  return ar[[origlen >= lines ? lines : origlen:]];
}

rl_.printout = &printout;

private define write_completion_routine (s, ar)
{
  variable
    bar,
    format = qualifier ("format");

  if (NULL == format || 0 == format)
    bar = ar;
  else
    {
    variable
      i,
      items,
      max_len = max (strlen (ar)) + 1,
      fmt = sprintf ("%%-%ds", max_len);

    if (max_len < COLUMNS)
      items = COLUMNS / max_len;
    else
      items = 1;

    if (max_len < COLUMNS)
      if ((items - 1) + (max_len * items) > COLUMNS)
        items--;

    s.formar (items, fmt, ar, &bar);
    }
  
  variable
    len = length (bar),
    clrs = Integer_Type[len],
    cols = Integer_Type[len];

  s.c_.cmp_lnrs = Integer_Type[len];

  clrs[*] = 5;
  cols[*] = 0;

  len = LINES - 4 - (strlen (s.c_._lin) / COLUMNS) - len + 1;
  _for i (0, length (bar) - 1)
    s.c_.cmp_lnrs[i] = len + i;
  
  if (qualifier_exists ("redraw"))
    srv->write_ar_nstr_dr (bar, clrs, s.c_.cmp_lnrs, cols, [s.c_._row, s.c_._col], COLUMNS);
  else
    srv->write_ar_nstr_at (bar, clrs, s.c_.cmp_lnrs, cols, COLUMNS);
}

rl_.w_comp_rout = &write_completion_routine;

private define write_routine (s)
{
  f_.writeline (s.c_._lin, 0, [s.c_._row, 0], [s.c_._row, s.c_._col]);
}

rl_.prompt = &write_routine;

private define restore (s, pos)
{
  variable
    ar = String_Type[0],
    rows = Integer_Type[0],
    clrs = Integer_Type[0],
    cols = Integer_Type[0],
    i;
  
  if (length (s.c_.cmp_lnrs) == length (w_.state))
    _for i (0, length (w_.state) - 1)
      {
      ar = [ar, w_.state[i][0]];
      clrs = [clrs, w_.state[i][1]];
      rows = [rows, w_.state[i][2]];
      cols = [cols, w_.state[i][3]];
      }
  else if (length (s.c_.cmp_lnrs) > length (w_.state))
      {
      _for i (0, length (w_.state) - 1)
        {
        ar = [ar, w_.state[i][0]];
        clrs = [clrs, w_.state[i][1]];
        rows = [rows, w_.state[i][2]];
        cols = [cols, w_.state[i][3]];
        }
      _for i (i+1, length (s.c_.cmp_lnrs) - 1)
        {
        ar = [ar, repeat (" ", COLUMNS)];
        clrs = [clrs, 0];
        rows = [rows, rows[-1] + 1];
        cols = [cols, 0];
        }
      }
  else
    _for i (length (w_.state) - length (s.c_.cmp_lnrs), length (w_.state) - 1)
      {
      ar = [ar, w_.state[i][0]];
      clrs = [clrs, w_.state[i][1]];
      rows = [rows, w_.state[i][2]];
      cols = [cols, w_.state[i][3]];
      }

  srv->write_ar_nstr_dr (ar, clrs, rows, cols, pos, COLUMNS);
}

rl_.restore = &restore;

private define clear (s, pos)
{
  variable
    ar = String_Type[length (s.c_.lnrs)],
    clrs = Integer_Type[length (ar)],
    cols = Integer_Type[length (ar)];

  ar[*] = repeat (" ", COLUMNS);
  clrs[*] = 0;
  cols[*] = 0;
  
  ifnot (qualifier_exists ("dont_redraw"))
    srv->write_ar_dr (ar, clrs, s.c_.lnrs, cols, pos);
  else
    srv->write_ar_at (ar, clrs, s.c_.lnrs, cols);

}

rl_.clear = &clear;

private define exec_line (s)
{
  variable list = {};

  array_map (Void_Type, &list_append, list, s.c_.argv[[1:]]);
  s.clear (w_.ptr;dont_redraw);

  if (any (s.c_.argv[0] == s.c_.com))
    (@cf[s.c_.argv[0]]) (__push_list (list));

  s.restore (w_.ptr);
}

rl_.execline = &exec_line;

private define readline (s)
{
  s.init ();

 % s.w_comp_rout (s.c_.com);
  s.prompt ();

  send_ans (RLINE_GETCH);

  forever
    {
    s.c_._chr = get_ans ();

    if (033 == s.c_._chr)
      {
      s.clear (w_.ptr;dont_redraw);
      s.restore (w_.ptr);
      break;
      }

    if ('\r' == s.c_._chr)
      {
      s.execline ();
      return;
      }

    if ('\t' == s.c_._chr)
      if (s.c_._ind && length (s.c_.argv))
        {
        variable start = 0 == strlen (s.c_.argv[s.c_._ind]) ? " " : s.c_.argv[s.c_._ind];
        if (s.fnamecmp (start) == 1)
          {
          s.execline ();
          return;
          }

        s.prompt ();
        send_ans (RLINE_GETCH);
        continue;
        }

    s.rout ();

    s.parse_args ();
    s.prompt ();
    
    send_ans (RLINE_GETCH);
    }
}

rl_.read = &readline;
