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

rl_.firstindices = &first_indices;

private define append_slash (s, file)
{
  if ('/' != file[-1] && 0 == (1 == strlen (file) && '.' == file[0]))
    return isdirectory (file) ? "/" : "";

  return  "";
}

rl_.appendslash = &append_slash;;

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

rl_.listdirectory = &list_directory;

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
    tmp = s.appendslash (start);
    if ("/" == tmp)
      {
      s.c_.argv[s.c_._ind] += tmp;
      s.c_._col += strlen (tmp);
      s.parse_args ();
      s.prompt();
      }
    }

  forever
    {
    pat = "";
    tmp = strlen (s.c_._lin) ? s.c_.argv[s.c_._ind] : "";

    file = ' ' == (s.c_._lin)[-1] ? getcwd () :
      sprintf ("%s%s", eval_dir (tmp;dont_change), s.appendslash (tmp));
 
    if (2 < strlen (file))
      if ("./" == file[[0:1]] && 0 == strlen (s.c_.argv[s.c_._ind]))
        file = file[[2:]];
 
    if (access (file, F_OK) || '/' != (s.c_._lin)[-1])
      {
      pat = path_basename (file);
      file = path_dirname (file);
      }
 
    retval = 0;
    ar = s.listdirectory (&retval, file, pat, strlen (pat));

    if (-1 == retval || 0 == length (ar))
      {
      s.restore ([s.c_._row, s.c_._col]);
      return 0;
      }

    ifnot (1 == length (ar))
      {
      str = "";
      s.firstindices (&str, ar, pat);

      if (strlen (str))
        {
        str = path_concat (file, str);
        s.c_.argv[s.c_._ind] = sprintf ("%s%s", str, s.appendslash (str));
        if ("./" == s.c_.argv[s.c_._ind][[0:1]])
          s.c_.argv[s.c_._ind] = substr (s.c_.argv[s.c_._ind], 3, -1);

        s.c_._col = strlen (strjoin (s.c_.argv[[:s.c_._ind]], " ")) + 1;
        s.parse_args ();
        s.prompt ();
        }
      }

    tmp = "";
    chr = s.hlitem (append_dir_indicator (file, ar), file, s.c_._col, &tmp);
 
    if (033 == chr)
      {
      s.restore ([s.c_._row, s.c_._col]);
      s.c_._col = strlen (strjoin (s.c_.argv[[:s.c_._ind]], " ")) + 1;
      s.parse_args ();

      return 0;
      }

    if (' ' == chr)
      {
      file = path_concat (file, tmp[-1] == '/' ? substr (tmp, 1, strlen (tmp) - 1) : tmp);
      st = lstat_file (file);
 
      ifnot (NULL == st)  % THIS SHOULD NOT FAIL
        {
        isdir = stat_is ("dir", st.st_mode);
        s.c_.argv[s.c_._ind] = sprintf ("%s%s", file, isdir ? "/" : "");

        if ("./" == s.c_.argv[s.c_._ind][[0:1]])
          s.c_.argv[s.c_._ind] = substr (s.c_.argv[s.c_._ind], 3, -1);
        s.c_._col = strlen (strjoin (s.c_.argv[[:s.c_._ind]], " ")) + 1;
        s.parse_args ();

        if (isdir)
          {
          s.restore ([s.c_._row, s.c_._col]);
          s.prompt ();
          continue;
          }
        }
      }
 
    if (any (keys->rmap.backspace == chr) && strlen (s.c_._lin))
      {
      s.delete_at ();
      s.parse_args ();
      s.restore ([s.c_._row, s.c_._col]);
      return 0;
      }

    if (' ' == chr)
      if (length (ar))
        {
        ar = array_map (String_Type, &path_concat, file, ar);
        ar = ar[wherenot (array_map (Char_Type, &strncmp, ar,
          s.c_.argv[s.c_._ind] + " ", strlen (s.c_.argv[s.c_._ind]) + 1))];

        if (length (ar))
          {
          s.c_.argv[s.c_._ind] = sprintf ("%s%s", ar[0], s.appendslash (ar[0]));
          s.c_._col = strlen (strjoin (s.c_.argv[[:s.c_._ind]], " ")) + 1;
          s.parse_args ();
          }
        }
      else
        {
        s.restore ([s.c_._row, s.c_._col]);
        return 0;
        }

    if ('\r' == chr || 0 == chr || 0 == (' ' < chr <= '~'))
      {
      s.restore ('\r' == chr ? w_.ptr : [s.c_._row, s.c_._col]);
      return '\r' == chr;
      }

    s.insert_at (;chr = chr);

    if (strlen (s.appendslash (s.c_.argv[s.c_._ind])))
      s.insert_at (;chr = '/');

    s.parse_args ();
    s.prompt ();
    s.restore ([s.c_._row, s.c_._col]);
    }
}

rl_.fnamecmp = &fname_completion;

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

rl_.formar = &form_ar;

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
    items,
    i = 0,
    page = 0,
    icol = 0,
    colr = 12,
    index = 0,
    max_len = max (strlen (ar)) + 2,
    fmt = sprintf ("%%-%ds", max_len),
    lines = LINES - 6 - (strlen (s.c_._lin) / COLUMNS);

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

  s.formar (items, fmt, ar, &bar);
 
  len = length (bar);
  @item = ar[index];
  
  irow = LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - (length (bar) > lines ? lines + 1 : length (bar));

  car = @bar;

  bar = s.printout (bar, bcol, &len;lines = lines,
    row = LINES - 2 - (strlen (s.c_._lin) / COLUMNS) + i,
    hl_region = [colr, irow, icol * max_len, 1, max_len]);
  
  send_ans (RLINE_GETCH);
  chr = get_ans ();
 
  ifnot (len || any (['\t', [keys->UP:keys->RIGHT], keys->PPAGE, keys->NPAGE] == chr))
    {
    s.restore ([s.c_._row, s.c_._col]);
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
        s.formar (items, fmt, ar, &bar);
        page = 0;
        }

      icol = 0;

      if (len)
        page++;

      len = length (bar);

      index = (page) * (lines * items);

      @item = ar[index];
 
      car = @bar;

      irow = LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - (length (car) > lines ? lines + 1 : length (car));
     
      if (length (bar) < lines)
        s.restore ([s.c_._row, s.c_._col]); 

      bar = s.printout (bar, bcol, &len;lines = lines,
        row = LINES - 2 - (strlen (s.c_._lin) / COLUMNS) + i,
        hl_region = [colr, irow, icol * max_len, 1, max_len]);
     
      send_ans (RLINE_GETCH);
      chr = get_ans ();
      continue;
      }
 
    if (keys->UP == chr)
      if ((0 == index || index < items) && 1 < length (car))
        (irow, icol, index) =
          LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - 1,
          length (car) >= lines
            ? items - 1
            : length (car) mod items
              ? (length (car) mod items) - 1
              : items - 1,
          length (car) >= lines
            ? ((page) * (lines * items)) + (lines * items) + items - 1
            : length (ar) - 1;
      else
        {
        irow--;
        index -= items;
        ifnot (irow - 1)
          (irow, icol, index) =
            LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - 1,
            length (car) >= lines
              ? items - 1
              : length (car) mod items
                ? (length (car) mod items) - 1
                : items - 1,
            length (car) >= lines
              ? ((page) * (lines * items)) + (lines * items) + items - 1
              : length (ar) - 1;
        }

    if (keys->DOWN == chr)
      if (irow - 1 > lines || index + items > length (ar) - 1)
        (irow, icol, index) =
          LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - (length (car) > lines ? lines + 1 : length (car)),
          0,
          page * ((lines - 4) * items);
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
        (irow, icol, index) =
          LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - 1,
          length (car) >= lines
            ? items - 1
            : length (car) mod items
              ? (length (car) mod items) - 1
              : items - 1,
          length (car) >= lines
            ? ((page) * (lines * items)) + (lines * items) + items - 1
            : length (ar) - 1;

      if (-1 == icol)
        {
        irow--;
        icol = items - 1;
        }

      ifnot (irow - 1)
        (irow, icol, index) =
          LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - 1,
          length (car) >= lines
            ? items - 1
            : length (car) mod items
              ? (length (car) mod items) - 1
              : items - 1,
          length (car) >= lines
            ? ((page) * (lines * items)) + (lines * items) + items - 1
            : length (ar) - 1;
      }

    if (keys->RIGHT == chr)
      if (index + 1 > length (ar) - 1)
        (irow, icol, index) =
          LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - (length (car) > lines ? lines + 1 : length (car)),
          0,
          (page) * ((lines - 4) * items);
      else if (icol + 1 == items)
        ifnot (irow - 1 > lines)
          {
          irow++;
          icol = 0;
          index++;
          }
        else
          (irow, icol, index) =
            LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - (length (car) > lines ? lines + 1 : length (car)),
            0,
            (page) * ((lines - 4) * items);
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

        s.formar (items, fmt, ar, &car);
        len = length (car);
        while (len > lines)
          {
          page++;
          car = car[[lines:]];
          bar = car;
          len = length (car);
          }

        (irow, icol, index) =
          LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - (length (car) > lines ? lines + 1 : length (car)),
          0,
          (page) * (lines * items);
        }
      else
        {
        page--;
        s.formar (items, fmt, ar, &car);
        loop (page)
          {
          len = length (car);
          car = car[[lines:]];
          }

        bar = car[[lines:]];

        (irow, icol, index) =
          LINES - 3 - (strlen (s.c_._lin) / COLUMNS) - (length (car) > lines ? lines + 1 : length (car)),
          0,
          (page) * (lines * items);
        }
      }

    @item = ar[index];

    len = length (car);
    () = s.printout (car, bcol, &len;lines = lines,
      row = LINES - 2 - (strlen (s.c_._lin) / COLUMNS) + i,
      hl_region = [colr, irow, icol * max_len, 1, max_len]);

    send_ans (RLINE_GETCH);
    chr = get_ans ();
    }

  return chr;
}

rl_.hlitem = &hlitem;
