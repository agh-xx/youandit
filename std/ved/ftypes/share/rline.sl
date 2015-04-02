rlf_ = struct
  {
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

private define quit ()
{
  if (cw_._flags & RDONLY || 0 == cw_._flags & MODIFIED ||
      (0 == qualifier_exists ("force") && "q!" == rl_.argv[0]))
    s_.quit (0);
  
  send_msg_dr ("file is modified, save changes? y[es]|n[o]", 0, NULL, NULL);

  variable chr = get_char ();
  while (0 == any (chr == ['y', 'n']))
    chr = get_char ();

  s_.quit (chr == 'y');
}

private define write_file ()
{
  variable
    file,
    args = __pop_list (_NARGS);
  
  ifnot (length (args))
    {
    if (cw_._flags & RDONLY)
      {
      send_msg_dr ("file is read only", 1, cw_.ptr[0], cw_.ptr[1]);
      return;
      }

    file = cw_._fname;
    }
  else
    {
    file = args[0];
    ifnot (access (file, F_OK))
      {
      if ("w" == rl_.argv[0])
        {
        send_msg_dr ("file exists, w! to overwrite, press any key to continue", 1,
          NULL, NULL);
        () = get_char ();
        send_msg_dr (" ", 0, cw_.ptr[0], cw_.ptr[1]);
        return;
        }

      if (-1 == access (file, W_OK))
        {
        send_msg_dr ("file is not writable, press any key to continue", 1,
          NULL, NULL);
        () = get_char ();
        send_msg_dr (" ", 0, cw_.ptr[0], cw_.ptr[1]);
        return;
        }
      }
    }

  ifnot (0 == s_.writefile (file))
    {
    send_msg_dr (sprintf ("%s, press any key to continue", errno_string (errno)), 1,
      NULL, NULL);
    () = get_char ();
    send_msg_dr (" ", 0, cw_.ptr[0], cw_.ptr[1]);
    return;
    }
  
  if (file == cw_._fname)
    cw_._flags = cw_._flags & ~MODIFIED;
}

private define write_quit ()
{
  variable args = __pop_list (_NARGS);
  s_.quit (1, __push_list (args));
}

clinef["w"] = &write_file;
clinef["w!"] = &write_file;
clinef["q"] = &quit;
clinef["q!"] = &quit;
clinef["wq"] = &write_quit;

clinec = assoc_get_keys (clinef);

private define init ()
{
  rl_ = @Rline_Type;
  rl_._col = 1;
  rl_._lin = ":";
  rl_._row = PROMPTROW;
  rl_._ind = 0;
  rl_.lnrs = [rl_._row];
  rl_.argv = [""];
  rl_.com = @clinec;
}

rlf_.init = &init;

private define delete_at (s)
{
  variable
    i,
    arglen,
    len = 0;

  ifnot (qualifier_exists ("is_delete"))
    rl_._col--;
 
  _for i (0, rl_._ind)
    {
    arglen = strlen (rl_.argv[i]);
    len += arglen + 1;
    }
 
  len = rl_._col - (len - arglen);

  if (0 > len)
    {
    if (arglen)
      rl_.argv[i-1] += rl_.argv[i];
 
    rl_.argv[i] = NULL;
    rl_.argv = rl_.argv[wherenot (_isnull (rl_.argv))];
    }
  else
    ifnot (len)
      rl_.argv[i] = substr (rl_.argv[i], 2, -1);
    else
      if (len + 1 == arglen)
        rl_.argv[i] = substr (rl_.argv[i], 1, len);
      else
        rl_.argv[i] = substr (rl_.argv[i], 1, len) +
          substr (rl_.argv[i], len + 2, -1);
}

rlf_.delete_at = &delete_at;

private define routine (s)
{
  if (any (keys->rmap.backspace == rl_._chr))
    {
    if (rl_._col > 1)
      rlf_.delete_at ();
    
    return; 
    }

  if (any (keys->rmap.left == rl_._chr))
    {
    if (rl_._col > 1)
      {
      rl_._col--;
      srv->gotorc_draw (rl_._row, rl_._col);
      }

    return;
    }

  if (any (keys->rmap.right == rl_._chr))
    {
    if (rl_._col < strlen (rl_._lin))
      {
      rl_._col++;
      srv->gotorc_draw (rl_._row, rl_._col);
      }

    return;
    }

  if (any (keys->rmap.home == rl_._chr))
    {
    rl_._col = 1;
    srv->gotorc_draw (rl_._row, rl_._col);

    return;
    }

  if (any (keys->rmap.end == rl_._chr))
    {
    rl_._col = strlen (rl_._lin);
    srv->gotorc_draw (rl_._row, rl_._col);

    return;
    }

  if (any (keys->rmap.delete == rl_._chr))
    {
    if (rl_._col <= strlen (rl_._lin))
      ifnot (rl_._col == strlen (strjoin (rl_.argv[[:rl_._ind]], " ")) + 1)
        rlf_.delete_at (;is_delete);
      else
        if (rl_._ind < length (rl_.argv) - 1)
          {
          rl_.argv[rl_._ind] += rl_.argv[rl_._ind+1];
          rl_.argv[rl_._ind+1] = NULL;
          rl_.argv = rl_.argv[wherenot (_isnull (rl_.argv))];
          }

    return;
    }

  if (' ' == rl_._chr)
    {
    if (qualifier_exists ("insert_ws"))
      {
      rlf_.insert_at ();
      return;
      }

    ifnot (rl_._ind)
      {
      if (1 == rl_._col)
        if (qualifier_exists ("accept_ws"))
          {
          rlf_.insert_at ();
          return;
          }
        else
          return;
 
      ifnot (length (rl_.argv) - 1)
        rl_.argv = [
          substr (rl_.argv[0], 1, rl_._col - 1),
          substr (rl_.argv[0], rl_._col, -1)];
      else
        rl_.argv = [
          substr (rl_.argv[0], 1, rl_._col - 1),
          substr (rl_.argv[0], rl_._col, -1),
          rl_.argv[[1:]]];

      rl_._col++;
      return;
      }

    if (' ' == srv->char_at ())
      {
      if (rl_._ind == length (rl_.argv) - 1)
        (rl_.argv = [rl_.argv, ""], rl_._col++);
      else if (strlen (strjoin (rl_.argv[[:rl_._ind]], " ")) == rl_._col - 1)
        (rl_.argv = [rl_.argv[[:rl_._ind]], "", rl_.argv[[rl_._ind + 1:]]],
        rl_._col++);
      else
        rlf_.insert_at ();

      return;
      }
    }

  if (' ' < rl_._chr <= 126 || 902 <= rl_._chr <= 974)
    rlf_.insert_at ();
}

rlf_.rout = &routine;

private define insert_at (s)
{
  variable
    i,
    arglen,
    len = 0,
    chr = char (qualifier ("chr", rl_._chr));

  rl_._col++;

  _for i (0, rl_._ind)
    {
    arglen = strlen (rl_.argv[i]);
    len += arglen + 1;
    }

  len = rl_._col - (len - arglen);

  if (rl_._col == len)
    rl_.argv[i] += chr;
  else
    ifnot (len)
      if (i > 0)
        rl_.argv[i-1] += chr;
      else
        rl_.argv[i] = chr + rl_.argv[i];
    else
      rl_.argv[i] = sprintf ("%s%s%s", substr (rl_.argv[i], 1, len - 1), chr,
        substr (rl_.argv[i], len, -1));
}

rlf_.insert_at = &insert_at;

private define parse_args ()
{
  variable
    i,
    found = NULL;

  (rl_._lin, rl_._ind) = ":", NULL;

  _for i (0, length (rl_.argv) - 1)
    ifnot (NULL == rl_.argv[i])
      ifnot (strlen (rl_.argv[i]))
        if (i)
          if (NULL == found)
            found = 1;
          else
            {
            found = NULL;
            rl_.argv[i] = NULL;
            rl_._col--;
            }

  rl_.argv = rl_.argv[wherenot (_isnull (rl_.argv))];
 
  _for i (0, length (rl_.argv) - 1)
    {
    rl_._lin = sprintf ("%s%s%s", rl_._lin, 1 < strlen (rl_._lin) ? " " : "", rl_.argv[i]);
 
    if (NULL == rl_._ind)
      if (rl_._col <= strlen (rl_._lin))
        rl_._ind = i - (rl_._col == strlen (rl_._lin) - strlen (rl_.argv[i]) - 1);
    }
 
  ifnot (strlen (rl_._lin))
    (rl_.argv, rl_._ind) = [""], 0;

  if (NULL == rl_._ind)
    rl_._ind = length (rl_.argv) - 1;

  if (rl_._col == strlen (rl_._lin) && 2 == length (rl_.argv) - rl_._ind)
    rl_.argv = rl_.argv[[:-2]];

  if (rl_._col > strlen (rl_._lin) + 1)
    rl_._col = strlen (rl_._lin) + 1;
}

rlf_.parse_args = &parse_args;

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
    nar = @len < lines ? @ar : ar[[:lines - 1]];
  
  rlf_.w_comp_rout (nar);

  ifnot (NULL == hlreg)
    srv->set_color_in_region (hlreg[0], hlreg[1], hlreg[2], hlreg[3], hlreg[4]);
  
  @len = @len >= lines;
  
  srv->gotorc_draw (rl_._row, rl_._col);

  return ar[[origlen >= lines ? lines - 1 : origlen:]];
}

rlf_.printout = &printout;

private define write_completion_routine (s, ar)
{
  variable
    i,
    len = length (ar),
    clrs = Integer_Type[len],
    cols = Integer_Type[len];

  rl_.cmp_lnrs = Integer_Type[len];

  clrs[*] = 5;
  cols[*] = 0;

  len = PROMPTROW - 1 - (strlen (rl_._lin) / COLUMNS) - len + 1;

  _for i (0, length (ar) - 1)
    rl_.cmp_lnrs[i] = len + i;
  
  srv->write_ar_nstr_at (ar, clrs, rl_.cmp_lnrs, cols, COLUMNS);
}

rlf_.w_comp_rout = &write_completion_routine;

private define write_rline (line, clr, dim, pos)
{
  srv->write_nstring_dr (line, COLUMNS, clr, [dim, pos]);
}

private define write_routine (s)
{
  write_rline (rl_._lin, PROMPTCLR, [rl_._row, 0], [rl_._row, rl_._col]);
}

rlf_.prompt = &write_routine;

private define restore (s, pos)
{
  variable
    i,
    ar = String_Type[0],
    rows = Integer_Type[0],
    clrs = Integer_Type[0],
    cols = Integer_Type[0];

  if (length (rl_.cmp_lnrs) == length (IMG))
    _for i (0, length (IMG) - 1)
      {
      ar = [ar, IMG[i][0]];
      clrs = [clrs, IMG[i][1]];
      rows = [rows, IMG[i][2]];
      cols = [cols, IMG[i][3]];
      }
  else if (length (rl_.cmp_lnrs) > length (IMG))
      {
      _for i (0, length (IMG) - 1)
        {
        ar = [ar, IMG[i][0]];
        clrs = [clrs, IMG[i][1]];
        rows = [rows, IMG[i][2]];
        cols = [cols, IMG[i][3]];
        }
      _for i (i + 1, length (rl_.cmp_lnrs) - 1)
        {
        ar = [ar, repeat (" ", COLUMNS)];
        clrs = [clrs, 0];
        rows = [rows, rows[-1] + 1];
        cols = [cols, 0];
        }
      }
  else
    _for i (length (IMG) - length (rl_.cmp_lnrs), length (IMG) - 1)
      {
      ar = [ar, IMG[i][0]];
      clrs = [clrs, IMG[i][1]];
      rows = [rows, IMG[i][2]];
      cols = [cols, IMG[i][3]];
      }

  srv->write_ar_nstr_dr (ar, clrs, rows, cols, pos, COLUMNS);
}

rlf_.restore = &restore;

private define clear (s, pos)
{
  variable
    ar = String_Type[length (rl_.lnrs)],
    clrs = Integer_Type[length (ar)],
    cols = Integer_Type[length (ar)];

  ar[*] = repeat (" ", COLUMNS);
  clrs[*] = 0;
  cols[*] = 0;
  
  ifnot (qualifier_exists ("dont_redraw"))
    srv->write_ar_dr (ar, clrs, rl_.lnrs, cols, pos);
  else
    srv->write_ar_at (ar, clrs, rl_.lnrs, cols);

}

rlf_.clear = &clear;

private define exec_line (s)
{
  variable list = {};

  array_map (Void_Type, &list_append, list, rl_.argv[[1:]]);
  rlf_.clear (cw_.ptr;dont_redraw);

  if (any (rl_.argv[0] == rl_.com))
    (@clinef[rl_.argv[0]]) (__push_list (list));

  rlf_.restore (cw_.ptr);
}

rlf_.execline = &exec_line;

private define readline (s)
{
  rlf_.init ();

  rlf_.prompt ();

  forever
    {
    rl_._chr = get_char ();

    if (033 == rl_._chr)
      {
      rlf_.clear (cw_.ptr;dont_redraw);
      rlf_.restore (cw_.ptr);
      break;
      }

    if ('\r' == rl_._chr)
      {
      rlf_.execline ();
      return;
      }

    if ('\t' == rl_._chr)
      if (rl_._ind && length (rl_.argv))
        {
        variable start = 0 == strlen (rl_.argv[rl_._ind]) ? " " : rl_.argv[rl_._ind];
        if (rlf_.fnamecmp (start) == 1)
          {
          rlf_.execline ();
          return;
          }

        rlf_.prompt ();
        continue;
        }

    rlf_.rout ();

    rlf_.parse_args ();
    rlf_.prompt ();
    }
}

rlf_.read = &readline;

private define first_indices (s, str, ar, pat)
{
  variable
    index = "." == pat ? 0 : strlen (pat),
    len = strlen (ar[0]),
    new_str = len > index ? ar[0][[0:index]] : NULL,
    indices = NULL != new_str ? array_map (Char_Type, &string_match, ar,
        str_quote_string (sprintf ("^%s", new_str), ".+", '\\')) : [0];

  ifnot (length (ar) == length (where (indices)))
    return;

  if ("." != pat)
    @str +=pat;
  else
    @str = "";

  while (NULL != new_str)
    {
    indices = array_map (Char_Type, &string_match, ar,
        str_quote_string (sprintf ("^%s", new_str), ".", '\\'));

    if (length (ar) == length (where (indices)))
      {
      @str += char (new_str[-1]);
      index++;
      new_str = len > index ? ar[0][[0:index]] : NULL;
      }
    else
      return;
    }
}

rlf_.firstindices = &first_indices;

private define append_slash (s, file)
{
  if ('/' != file[-1] && 0 == (1 == strlen (file) && '.' == file[0]))
    return isdirectory (file) ? "/" : "";

  return  "";
}

rlf_.appendslash = &append_slash;;

private define append_dir_indicator (base, files)
{
  variable ar = @files;
  ar[where (array_map (Char_Type, &isdirectory,
    array_map (String_Type, &path_concat, base, files)))] += "/";

  return ar;
}

private define list_directory (s, retval, dir, pat, pos)
{
  variable
    ar = String_Type[0],
    st = stat_file (dir);

  if (NULL == st)
    {
    @retval = -1;
    return ar;
    }

  ifnot (stat_is ("dir", st.st_mode))
    return [dir];

  ar = listdir (dir);

  if (NULL == ar)
    {
    @retval = -1;
    return ar;
    }

  ifnot (NULL == pat)
    ar = ar[wherenot (array_map (Char_Type, &strncmp, ar, pat, pos))];

  return ar[array_sort (ar)];
}

rlf_.listdirectory = &list_directory;

private define fname_completion (s, start)
{
  variable
    ar,
    st,
    str,
    tmp,
    file,
    isdir,
    retval,
    chr = 0,
    pat = "";

 if (' ' != start[0])
    {
    tmp = rlf_.appendslash (start);
    if ("/" == tmp)
      {
      rl_.argv[rl_._ind] += tmp;
      rl_._col += strlen (tmp);
      rlf_.parse_args ();
      rlf_.prompt();
      }
    }

  forever
    {
    pat = "";
    tmp = strlen (rl_._lin) ? rl_.argv[rl_._ind] : "";

    file = ' ' == (rl_._lin)[-1] ? getcwd () :
      sprintf ("%s%s", eval_dir (tmp;dont_change), rlf_.appendslash (tmp));
 
    if (2 < strlen (file))
      if ("./" == file[[0:1]] && 0 == strlen (rl_.argv[rl_._ind]))
        file = file[[2:]];
 
    if (access (file, F_OK) || '/' != (rl_._lin)[-1])
      {
      pat = path_basename (file);
      file = path_dirname (file);
      }
 
    retval = 0;
    ar = rlf_.listdirectory (&retval, file, pat, strlen (pat));

    if (-1 == retval || 0 == length (ar))
      {
      rlf_.restore ([rl_._row, rl_._col]);
      return 0;
      }

    ifnot (1 == length (ar))
      {
      str = "";
      rlf_.firstindices (&str, ar, pat);

      if (strlen (str))
        {
        str = path_concat (file, str);
        rl_.argv[rl_._ind] = sprintf ("%s%s", str, rlf_.appendslash (str));
        if ("./" == rl_.argv[rl_._ind][[0:1]])
          rl_.argv[rl_._ind] = substr (rl_.argv[rl_._ind], 3, -1);

        rl_._col = strlen (strjoin (rl_.argv[[:rl_._ind]], " ")) + 1;
        rlf_.parse_args ();
        rlf_.prompt ();
        }
      }

    tmp = "";
    chr = rlf_.hlitem (append_dir_indicator (file, ar), file, rl_._col, &tmp);
 
    if (033 == chr)
      {
      rlf_.restore ([rl_._row, rl_._col]);
      rl_._col = strlen (strjoin (rl_.argv[[:rl_._ind]], " ")) + 1;
      rlf_.parse_args ();

      return 0;
      }

    if (' ' == chr)
      {
      file = path_concat (file, tmp[-1] == '/' ? substr (tmp, 1, strlen (tmp) - 1) : tmp);
      st = lstat_file (file);
 
      ifnot (NULL == st)  % THIS SHOULD NOT FAIL
        {
        isdir = stat_is ("dir", st.st_mode);
        rl_.argv[rl_._ind] = sprintf ("%s%s", file, isdir ? "/" : "");

        if ("./" == rl_.argv[rl_._ind][[0:1]])
          rl_.argv[rl_._ind] = substr (rl_.argv[rl_._ind], 3, -1);
        rl_._col = strlen (strjoin (rl_.argv[[:rl_._ind]], " ")) + 1;
        rlf_.parse_args ();

        if (isdir)
          {
          rlf_.restore ([rl_._row, rl_._col]);
          rlf_.prompt ();
          continue;
          }
        }
      }
 
    if (any (keys->rmap.backspace == chr) && strlen (rl_._lin))
      {
      rlf_.delete_at ();
      rlf_.parse_args ();
      rlf_.restore ([rl_._row, rl_._col]);
      return 0;
      }

    if (' ' == chr)
      if (length (ar))
        {
        ar = array_map (String_Type, &path_concat, file, ar);
        ar = ar[wherenot (array_map (Char_Type, &strncmp, ar,
          rl_.argv[rl_._ind] + " ", strlen (rl_.argv[rl_._ind]) + 1))];

        if (length (ar))
          {
          rl_.argv[rl_._ind] = sprintf ("%s%s", ar[0], rlf_.appendslash (ar[0]));
          rl_._col = strlen (strjoin (rl_.argv[[:rl_._ind]], " ")) + 1;
          rlf_.parse_args ();
          }
        }
      else
        {
        rlf_.restore ([rl_._row, rl_._col]);
        return 0;
        }

    if ('\r' == chr || 0 == chr || 0 == (' ' < chr <= '~'))
      {
      rlf_.restore ('\r' == chr ? cw_.ptr : [rl_._row, rl_._col]);
      return '\r' == chr;
      }

    rlf_.insert_at (;chr = chr);

    if (strlen (s.appendslash (rl_.argv[rl_._ind])))
      rlf_.insert_at (;chr = '/');

    rlf_.parse_args ();
    rlf_.prompt ();
    rlf_.restore ([rl_._row, rl_._col]);
    }
}

rlf_.fnamecmp = &fname_completion;

private define form_ar (items, fmt, ar, bar)
{
  @bar = String_Type[0];

  ifnot (items)
    return;

  variable i = 0;

  while (i < length (ar))
    {
    if (i + items < length (ar))
      @bar = [@bar, strjoin (array_map (
        String_Type, &sprintf, fmt, ar[[i:i + items - 1]]))];
    else
      @bar = [@bar, strjoin (array_map (String_Type, &sprintf, fmt, ar[[i:]]))];

    i += items;
    }
}

rlf_.formar = &form_ar;

private define hlitem (s, ar, base, acol, item)
{
  variable
    chr,
    car,
    bar,
    len,
    tmp,
    bcol,
    irow,
    lrow = PROMPTROW - (strlen (rl_._lin) / COLUMNS),
    items,
    i = 0,
    page = 0,
    icol = 0,
    colr = 12,
    index = 0,
    max_len = max (strlen (ar)) + 2,
    fmt = sprintf ("%%-%ds", max_len),
    lines;

  if (max_len < COLUMNS)
    items = COLUMNS / max_len;
  else
    items = 1;
 
  if (max_len < COLUMNS)
    if ((items - 1) + (max_len * items) > COLUMNS)
      items--;

  while ((i + 1) * COLUMNS <= acol)
    i++;

  bcol = acol - (COLUMNS * i);

  rlf_.formar (items, fmt, ar, &bar);
 
  len = length (bar);
  @item = ar[index];
  lines = lrow - 1;

  car = @bar;

  irow = lrow - (length (car) > lines ? lines : length (car));

  bar = rlf_.printout (bar, bcol, &len;lines = lines,
    row = PROMPTROW - (strlen (rl_._lin) / COLUMNS) + i,
    hl_region = [colr, irow, icol * max_len, 1, max_len]);
  
  chr = get_char ();
 
  ifnot (len || any (['\t', [keys->UP:keys->RIGHT], keys->PPAGE, keys->NPAGE] == chr))
    {
    rlf_.restore ([rl_._row, rl_._col]);
    return chr;
    }
 
  while ( any (['\t', [keys->UP:keys->RIGHT], keys->PPAGE, keys->NPAGE] == chr))
    {
    if ('\t' == chr)
      if (lines >= length (car) && page == 0)
        chr = keys->RIGHT;
      else
        chr = keys->NPAGE;

    if (keys->NPAGE == chr)
      {
      ifnot (len)
        {
        rlf_.formar (items, fmt, ar, &bar);
        page = 0;
        }

      if (len)
        page++;

      len = length (bar);

      index = (page) * ((lines - 1) * items);

      @item = ar[index];
 
      car = @bar;

      irow = lrow - (length (car) > lines ? lines : length (car));
      icol = 0;
     
      if (length (bar) < lines)
        rlf_.restore ([rl_._row, rl_._col]); 

      bar = rlf_.printout (bar, bcol, &len;lines = lines,
        row = PROMPTROW - (strlen (rl_._lin) / COLUMNS) + i,
        hl_region = [colr, irow, icol * max_len, 1, max_len]);
     
      chr = get_char ();
      continue;
      }
 
    if (keys->UP == chr)
      if ((0 == index || index < items) && 1 < length (car))
        {
        (irow, icol, index) =
          lrow - 1,
          length (car) >= lines
            ? items - 1
            : length (car) mod items
              ? (length (strtok (strjoin (car, " "))) mod items) - 1
              : items - 1,
          length (car) >= lines
            ? ((page) * (lines * items)) + ((lines - 1) * items) + items - 1
            : length (ar) - 1;
        }
      else
        {
        irow--;
        index -= items;
        if (0 == irow || 1 == length (car))
          (irow, icol, index) =
            lrow - 1,
            length (car) >= lines
              ? items - 1
              : length (strtok (strjoin (car, " "))) mod items
                ? (length (strtok (strjoin (car, " "))) mod items) - 1
                : items - 1,
            length (car) >= lines
              ? ((page) * ((lines - 1) * items)) + ((lines - 1) * items) + items - 1
              : length (ar) - 1;
        }

    if (keys->DOWN == chr)
      if (irow + 1 > lines || index + items > length (ar) - 1)
        (irow, icol, index) =
          lrow - (length (car) > lines ? lines : length (car)),
          0,
          page * ((lines - 1) * items);
      else
        {
        irow++;
        index += items;
        }

    if (keys->LEFT == chr)
      {
      icol--;
      index--;
      if (-1 == index)
        if (length (car) < lines)
          (irow, icol, index) =
            lrow - 1,
            length (strtok (strjoin (car, " "))) mod items
              ? (length (strtok (strjoin (car, " "))) mod items) - 1
              : items - 1,
              length (ar) - 1;

      if (-1 == icol)
        {
        irow--;
        icol = length (car) mod items
          ? (length (strtok (strjoin (car, " "))) mod items) - 1
          : items - 1;
        }

      ifnot (irow)
        if (lines > length (car))
          {
          irow++;
          icol = 0;
          index++;
          }
        else
          (irow, icol, index) =
            lrow - 1,
            items - 1,
           ((page) * ((lines - 1) * items)) + ((lines - 1) * items) + items - 1;
      }

    if (keys->RIGHT == chr)
      if (index + 1 > length (ar) - 1)
        (irow, icol, index) =
          lrow - (length (car) > lines ? lines : length (car)),
          0,
          (page) * ((lines - 1) * items);
      else if (icol + 1 == items)
        ifnot (irow > lines)
          {
          irow++;
          icol = 0;
          index++;
          }
        else
          (irow, icol, index) =
            lrow - (length (car) > lines ? lines : length (car)),
            0,
            (page) * ((lines - 1) * items);
      else
        {
        index++;
        icol++;
        }
 
    if (keys->PPAGE== chr)
      {
      ifnot (page)
        {
        if (length (car) > lines)
          page = 0;

        rlf_.formar (items, fmt, ar, &car);
        len = length (car);

        while (len > lines)
          {
          page++;
          car = car[[lines - 1:]];
          bar = car;
          len = length (car);
          }

        (irow, icol, index) =
          lrow - (length (car) > lines ? lines : length (car)),
          0,
          (page) * ((lines - 1) * items);

        if (length (car) < lines)
          rlf_.restore ([rl_._row, rl_._col]);
        }
      else
        {
        page--;
        rlf_.formar (items, fmt, ar, &car);
        loop (page)
          {
          len = length (car);
          car = car[[lines - 1:]];
          }

        bar = car[[lines - 1:]];

        (irow, icol, index) =
          lrow - (length (car) > lines ? lines : length (car)),
          0,
          (page) * ((lines - 1) * items);
        }
      }

    @item = ar[index];

    len = length (car);

    () = rlf_.printout (car, bcol, &len;lines = lines,
      row = PROMPTROW - (strlen (rl_._lin) / COLUMNS) + i,
      hl_region = [colr, irow, icol * max_len, 1, max_len]);

    chr = get_char ();
    }

  return chr;
}

rlf_.hlitem = &hlitem;

private define getline (s, line, prev_l, next_l)
{
  srv->write_nstring_dr ("-- INSERT -- ", COLUMNS, 0, [0, 0, cw_.ptr[0], cw_.ptr[1]]);
  variable gl_ = @Rline_Type;

  gl_._col = cw_.ptr[1];
  gl_._row = cw_.ptr[0];

  forever
    {
    gl_._chr = get_char ();

    if (033 == gl_._chr)
      {
      if (0 < cw_.ptr[1] - cw_._indent)
        cw_.ptr[1]--;

      srv->write_nstring_dr (" ", COLUMNS, 0, [0, 0, cw_.ptr[0], cw_.ptr[1]]);
      return;
      }
     
    if (any (keys->rmap.left == gl_._chr))
      {
      if (0 < cw_.ptr[1] - cw_._indent)
        {
        gl_._col--;
        cw_.ptr[1]--;
        srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
        }

      continue;
      }
    
    if (any (keys->CTRL_y == gl_._chr))
      {
      if (cw_.ptr[1] < strlen (prev_l))
        {
        @line = substr (@line, 1, gl_._col) + substr (prev_l, cw_.ptr[1] + 1, 1)
          + substr (@line, gl_._col + 1, - 1);
        gl_._col++;
        cw_.ptr[1]++;
        srv->write_nstring_dr (@line, COLUMNS, 0, [cw_.ptr[0], 0, cw_.ptr[0], cw_.ptr[1]]);
        }

      continue; 
      }

    if (any (keys->CTRL_e == gl_._chr))
      {
      if (cw_.ptr[1] < strlen (next_l))
        {
        @line = substr (@line, 1, gl_._col) + substr (next_l, cw_.ptr[1] + 1, 1) +
          substr (@line, gl_._col + 1, - 1);
        gl_._col++;
        cw_.ptr[1]++;
        srv->write_nstring_dr (@line, COLUMNS, 0, [cw_.ptr[0], 0, cw_.ptr[0], cw_.ptr[1]]);
        }

      continue; 
      }

    if (any (keys->rmap.right == gl_._chr))
      {
      if (gl_._col < strlen (@line))
        {
        gl_._col++;
        cw_.ptr[1]++;
        srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
        }

      continue;
      }

    if (any (keys->rmap.home == gl_._chr))
      {
      gl_._col = cw_._indent;
      cw_.ptr[1] = cw_._indent;
      srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);

      continue;
      }

    if (any (keys->rmap.end == gl_._chr))
      {
      gl_._col = strlen (@line);
      cw_.ptr[1] = strlen (@line);
      srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);;

      continue;
      }

    if (any (keys->rmap.backspace == gl_._chr))
      {
      if (0 < cw_.ptr[1] - cw_._indent)
        {
        @line = substr (@line, 1, gl_._col - 1) + substr (@line, gl_._col + 1, - 1);
        cw_.ptr[1]--;
        gl_._col--;
        }

      srv->write_nstring_dr (@line, COLUMNS, 0, [cw_.ptr[0], 0, cw_.ptr[0], cw_.ptr[1]]);
            
      continue; 
      }

    if (any (keys->rmap.delete == gl_._chr))
      {
      @line = substr (@line, 1, gl_._col) + substr (@line, gl_._col + 2, - 1);

      srv->write_nstring_dr (@line, COLUMNS, 0, [cw_.ptr[0], 0, cw_.ptr[0], cw_.ptr[1]]);
            
      continue; 
      }

    if (' ' <= gl_._chr <= 126 || 902 <= gl_._chr <= 974)
      {
      @line = substr (@line, 1, gl_._col) + char (gl_._chr) +  substr (@line, gl_._col + 1, - 1);
      gl_._col++;
      cw_.ptr[1]++;
      srv->write_nstring_dr (@line, COLUMNS, 0, [cw_.ptr[0], 0, cw_.ptr[0], cw_.ptr[1]]);
      continue; 
      }
    }
}

rlf_.getline = &getline;
