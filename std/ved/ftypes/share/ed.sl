private define indent_in ()
{
  variable
    i_ = cw_._indent,
    i = v_lnr ('.'),
    line = v_lin ('.');

  ifnot (isblank (line[i_]))
    return;
 
  while (isblank (line[i_]))
    i_++;

  if (i_ > s_._shiftwidth)
    i_ = s_._shiftwidth;

  line = substr (line, i_ + 1, -1);

  cw_.lins[cw_.ptr[0] - cw_.rows[0]] = line;
  cw_.lines[i] = line;
  cw_.ptr[1] -= i_;

  if (0 > cw_.ptr[1] - cw_._indent)
    cw_.ptr[1] = cw_._indent;

  cw_._flags = cw_._flags | MODIFIED;
  cw_.st_.st_size += s_._shiftwidth;

  s_.write_nstr (line, 0, cw_.ptr[0]);
  draw_tail ();
}

private define indent_out ()
{
  variable
    i = v_lnr ('.'),
    line = v_lin ('.');

  line = sprintf ("%s%s", repeat (" ", s_._shiftwidth), line);

  cw_.lins[cw_.ptr[0] - cw_.rows[0]] = line;
  cw_.lines[i] = line;
  cw_.ptr[1] += s_._shiftwidth;

  if (cw_.ptr[1] >= cw_._maxlen)
    cw_.ptr[1] = cw_._maxlen - 1;

  cw_._flags = cw_._flags | MODIFIED;
  cw_.st_.st_size += s_._shiftwidth;

  s_.write_nstr (line, 0, cw_.ptr[0]);
  draw_tail ();
}

private define del_line ()
{
  variable
    i = v_lnr ('.'),
    line = v_lin ('.');

  if (0 == cw_._len && (0 == v_linlen ('.') || " " == line))
    return 1;

  ifnot (i)
    ifnot (cw_._len)
      {
      cw_.lines[0] = " ";
      cw_.st_.st_size = 0;
      cw_.ptr[1] = cw_._indent;
      cw_._flags = cw_._flags | MODIFIED;
      return 0;
      }
    
  cw_.lines[i] = NULL;
  cw_.lines = cw_.lines[wherenot (_isnull (cw_.lines))];
  cw_._len--;
 
  cw_._i = cw_._ii;
 
  cw_.ptr[1] = cw_._indent;

  if (cw_.ptr[0] == cw_.vlins[-1] && 1 < length (cw_.vlins))
    cw_.ptr[0]--;

  cw_.st_.st_size -= strbytelen (line);

  cw_._flags = cw_._flags | MODIFIED;

  if (cw_._i > cw_._len)
    cw_._i = cw_._len;
  
  return 0;
}

private define del_word ()
{
  variable
    end,
    start,
    col = cw_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line);
 
  if (isblank (line[col]))
    return;
 
  find_Word (line, col, &start, &end);

  line = sprintf ("%s%s", substr (line, 1, start), substr (line, end + 2, -1));
 
  cw_._flags = cw_._flags | MODIFIED;
 
  cw_.lins[cw_.ptr[0] - cw_.rows[0]] = line;
  cw_.lines[i] = line;
  cw_.ptr[1] = start;

  cw_.st_.st_size -= len - strbytelen (line);

  s_.write_nstr_dr (line, 0, cw_.ptr[0], 0, [cw_.ptr[0], cw_.ptr[1]]);
}

private define chang_chr ()
{
  variable
    chr = get_char (),
    col = cw_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.');

  if (' ' <= chr <= 126 || 902 <= chr <= 974)
    {
    cw_.st_.st_size -= strbytelen (line);
    line = substr (line, 1, col) + char (chr) + substr (line, col + 2, - 1);
    cw_.lins[cw_.ptr[0] - cw_.rows[0]] = line;
    cw_.lines[i] = line;
    cw_.st_.st_size += strbytelen (line);
    cw_._flags = cw_._flags | MODIFIED;
    s_.write_nstr_dr (line, 0, cw_.ptr[0], 0, [cw_.ptr[0], cw_.ptr[1]]);
    }
}

private define del_chr ()
{
  variable
    col = cw_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line),
    blen = strbytelen (line);

  if ((0 == cw_.ptr[1] - cw_._indent && 'X' == cw_._chr) || 0 > len - cw_._indent)
    return;
 
  if (any (['x', keys->rmap.delete] == cw_._chr))
    {
    line = substr (line, 1, col) + substr (line, col + 2, - 1);
    if (cw_.ptr[1] == strlen (line))
      cw_.ptr[1]--;
    }
  else
    if (0 < cw_.ptr[1] - cw_._indent)
      {
      line = substr (line, 1, col - 1) + substr (line, col + 1, - 1);
      cw_.ptr[1]--;
      }

  if (cw_.ptr[1] - cw_._indent < 0)
    cw_.ptr[1] = cw_._indent;

  cw_.lins[cw_.ptr[0] - cw_.rows[0]] = line;
  cw_.lines[i] = line;

  cw_.st_.st_size -= blen - strbytelen (line);
 
  cw_._flags = cw_._flags | MODIFIED;
 
  s_.write_nstr_dr (line, 0, cw_.ptr[0], 0, [cw_.ptr[0], cw_.ptr[1]]);
}

private define del ()
{
  cw_._chr = get_char ();
 
  if (any (['d', 'w' == cw_._chr]))
    {
    if ('d' == cw_._chr)
      {
      if (1 == del_line ())
        return;

      s_.draw ();
      }
%% will change to W and del_Word
    if ('w' == cw_._chr)
      del_word ();
    }
}

private define del_to_end ()
{
  variable
    col = cw_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line);
 
  if (cw_.ptr[1] == len)
    return;
 
  cw_.st_.st_size -= strbytelen (line);

  ifnot (cw_.ptr[1] - cw_._indent)
    {
    line = repeat (" ", cw_._indent);
    ifnot (strlen (line))
      line = " ";
 
    cw_.ptr[1] = cw_._indent;

    cw_.lines[i] = line;
    cw_.lins[cw_.ptr[0] - cw_.rows[0]] = line;
 
    cw_._flags = cw_._flags | MODIFIED;

    s_.write_nstr (line, 0, cw_.ptr[0]);

    draw_tail ();
    return;
    }

  line = substr (line, 1, col);

  cw_.lins[cw_.ptr[0] - cw_.rows[0]] = line;
  cw_.lines[i] = line;
 
  cw_._flags = cw_._flags | MODIFIED;

  cw_.st_.st_size += strbytelen (line);

  cw_.ptr[1]--;

  s_.write_nstr (line, 0, cw_.ptr[0]);

  draw_tail ();
}

private define edit_line ()
{
  variable
    prev_l,
    next_l,
    col = cw_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line);

  ifnot (i)
    prev_l = "";
  else
    prev_l = v_lin (cw_.ptr[0] - 1);

  if (i == cw_._len)
    next_l = "";
  else
    next_l = cw_.lines[i+1];
 
  if ('C' == cw_._chr)
    line = substr (line, 1, col);
  else if ('a' == cw_._chr)
    cw_.ptr[1]++;
  else if ('A' == cw_._chr)
    cw_.ptr[1] = len;
 
  cw_.st_.st_size -= strbytelen (line);

  s_.write_nstr_dr (line, 0, cw_.ptr[0], 0, [cw_.ptr[0], cw_.ptr[1]]);

  rlf_.getline (&line, prev_l, next_l;dir = "prev", i = i);
}

private define newline ()
{
  variable
    dir = cw_._chr == 'O' ? "prev" : "next",
    prev_l,
    next_l,
    col = cw_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line);

    if ("prev" == dir)
      ifnot (i)
        prev_l = "";
      else
        prev_l = v_lin (cw_.ptr[0] - 1);
    else
      prev_l = line;
  
  if ("prev" == dir)
    next_l = line;
  else
    if (i == cw_._len)
      next_l = "";
    else
      next_l = v_lin (cw_.ptr[0] + 1);
  
  cw_._len++;

  if (0 == i && "prev" == dir)
    cw_.lines = [" ", cw_.lines];
  else
    cw_.lines = [cw_.lines[[:"next" == dir ? i : i - 1]], " ",
      cw_.lines[["next" == dir ? i + 1 : i:]]];

  cw_._i = i == 0 ? 0 : cw_._ii;
  
  if ("next" == dir)
    if (cw_.ptr[0] == cw_.rows[-2] && cw_.ptr[0] + 1 > cw_._avlins)
      cw_._i++;
    else
      cw_.ptr[0]++;

  cw_.ptr[1] = cw_._indent;
  
  s_.draw ();
  
  line = "";
  rlf_.getline (&line, prev_l, next_l;dir = dir, i = i);
}

pagerf[string ('o')] = &newline;
pagerf[string ('O')] = &newline;
pagerf[string ('d')] = &del;
pagerf[string ('x')] = &del_chr;
pagerf[string ('X')] = &del_chr;
pagerf[string (keys->rmap.delete[0])] = &del_chr;
if (2 == length (keys->rmap.delete))
  pagerf[string (keys->rmap.delete[1])] = &del_chr;
pagerf[string ('D')] = &del_to_end;
pagerf[string ('C')] = &edit_line;
pagerf[string ('i')] = &edit_line;
pagerf[string ('a')] = &edit_line;
pagerf[string ('A')] = &edit_line;
pagerf[string ('r')] = &chang_chr;
pagerf[string ('>')] = &indent_out;
pagerf[string ('<')] = &indent_in;

%pf[string (keys->CTRL_u)] = &redo;
%pf[string ('u')] = &undo;
