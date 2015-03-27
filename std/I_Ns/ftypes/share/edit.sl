private define undo ()
{
  if (s_._state + 1 >= s_._states || s_._states == 1)
    return;
 
  s_._state++;

  s_.p_ = s_.getjs ().p_;

  w_._len = length (s_.p_.lins) - 1;
  w_._i = 0;

  draw ();
}

private define redo ()
{
  ifnot (s_._state)
    return;

  s_._state--;

  s_.p_ = s_.getjs ().p_;

  w_._len = length (s_.p_.lins) - 1;
  w_._i = 0;

  draw ();
}

private define indent_out ()
{
  if (s_._indent > COLUMNS - 84)
    return;

  s_._indent += 4;
  w_.ptr[1] = s_._indent;

  reparse (;reparse);
}

private define indent_in ()
{
  if (s_._indent <= 0)
    return;

  s_._indent -= 4;
  w_.ptr[1] = s_._indent;

  reparse (;reparse);
}

private define del_line ()
{
  variable
    i_,
    i = v_lnr ('.'),
    line_ = v_lin ('.');

  if (-1 == w_._len)
    return;

  s_.p_.lins = list_concat (s_.p_.lins[[0:i - 1]], s_.p_.lins[[i + 1:]]);
  s_.p_.lnrs = list_concat (s_.p_.lnrs[[0:i - 1]], s_.p_.lnrs[[i + 1:]]);

  ifnot (s_._type == "txt")
    {
    s_.p_.cols = list_concat (s_.p_.cols[[0:i - 1]], s_.p_.cols[[i + 1:]]);
    s_.p_.clrs = list_concat (s_.p_.clrs[[0:i - 1]], s_.p_.clrs[[i + 1:]]);
    }

  if (length (s_.p_.lnrs))
    if (typeof (s_.p_.lnrs[0]) == List_Type)
      _for i (i, length (s_.p_.lnrs) - 1)
        _for i_ (0, length (s_.p_.lnrs[i]) - 1)
          s_.p_.lnrs[i][i_]--;
   else
      _for i (i, length (s_.p_.lnrs) - 1)
        s_.p_.lnrs[i]--;
 
  ifnot (length (s_.p_.lins))
    {
    w_.ptr = [2, s_._indent];

    s_.p_.lins = {repeat (" ", s_._indent)};
    s_.p_.cols = {0};
    s_.p_.clrs = {0};
    s_.p_.lnrs = {0};

    w_.lins = [repeat (" ", s_._indent)];
    w_._len = -1;
    s_.st_.st_size = 0;
    }
  else
    {
    w_._len--;
    s_.st_.st_size -= strbytelen (line_) - s_._indent + 1;
    }

  ifnot (s_._flags & MODIFIED)
    s_._flags = s_._flags | MODIFIED;
 
  s_.encode ();

  w_._i = w_._ii;

  if (w_._i > w_._len)
    w_._i = w_._len;

  w_.ptr[1] = s_._indent;
}

private define del_word ()
{
  variable
    end,
    start,
    col = w_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line);
  
  if (isblank (line[col]))
    return;

  ifnot (col - s_._indent)
    start = s_._indent;
  else
    {
    while (col--, 0 == isblank (line[col]));
    start = col + 1;
    }
 
  while (col++, col < len && 0 == isblank (line[col]));
    end = col - 1;

  line = sprintf ("%s%s", substr (line, 1, start), substr (line, end + 2, -1)); 
  
  ifnot (s_._flags & MODIFIED)
    s_._flags = s_._flags | MODIFIED;
  
  w_.lins[w_.ptr[0] - 2] = line;
  s_.p_.lins[i] = line;
  w_.ptr[1] = start;
  s_.st_.st_size -= len - strbytelen (line);
 
  s_.encode ();

  srv->write_nstring_dr (line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);
}

private define del_chr ()
{
  variable
    col = w_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line),
    blen = strbytelen (line);

  if ((0 == w_.ptr[1] - s_._indent && 'X' == _chr_) || 0 > len - s_._indent)
    return;
 
  if ('x' == _chr_)
    {
    line = substr (line, 1, col) + substr (line, col + 2, - 1);
    if (w_.ptr[1] == strlen (line))
      w_.ptr[1]--;
    }
  else
    if (0 < w_.ptr[1] - s_._indent)
      {
      line = substr (line, 1, col - 1) + substr (line, col + 1, - 1);
      w_.ptr[1]--;
      }

  if (w_.ptr[1] - s_._indent < 0)
    w_.ptr[1] = s_._indent;

  w_.lins[w_.ptr[0] - 2] = line;
  s_.p_.lins[i] = line;

  s_.st_.st_size -= blen - strbytelen (line);
 
  ifnot (s_._flags & MODIFIED)
    s_._flags = s_._flags | MODIFIED;
  
  s_.encode ();

  srv->write_nstring_dr (line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);
}

private define del ()
{
  send_ans (RLINE_GETCH);
  _chr_ = get_ans ();

  if (any (['d', 'w' == _chr_]))
    {
    if ('d' == _chr_)
      {
      del_line ();

      draw ();
      }
% will change to W and del_Word
    if ('w' == _chr_)
      del_word ();
    }
}

define insert_line (line, index)
{
  variable
    i,
    i_;

  s_.p_.lins = list_concat (s_.p_.lins[[0:index]], s_.p_.lins[[index:]]);
  s_.p_.lnrs = list_concat (s_.p_.lnrs[[0:index]], s_.p_.lnrs[[index:]]);
  s_.p_.clrs = list_concat (s_.p_.clrs[[0:index]], s_.p_.clrs[[index:]]);
  s_.p_.cols = list_concat (s_.p_.cols[[0:index]], s_.p_.cols[[index:]]);

  s_.p_.lins[index] = {line};
  s_.p_.cols[index] = {0};
  s_.p_.clrs[index] = {0};

  if (length (s_.p_.lnrs))
    if (typeof (s_.p_.lnrs[0]) == List_Type)
      _for i (index + 1, length (s_.p_.lnrs) - 1)
        _for i_ (0, length (s_.p_.lnrs[i]) - 1)
          s_.p_.lnrs[i][i_]--;
   else
      _for i (index+1, length (s_.p_.lnrs) - 1)
        s_.p_.lnrs[i]--;
  
  w_._len++;

  ifnot (s_._flags & MODIFIED)
    s_._flags = s_._flags | MODIFIED;
}

private define newlineO ()
{
  variable
    i_,
    i__,
    prev_l,
    next_l,
    col = s_._indent,
    i = v_lnr ('.'),
    line = repeat (" ", s_._indent);
  
  w_.ptr[0]--;
  w_.ptr[1] = strlen (line);
  
  insert_line (line, i-1);

  ifnot (i)
    prev_l = "";
  else
    prev_l = v_lin (w_.ptr[0] - 1);

  if (i == w_._len)
    next_l = "";
  else
    if (typeof (s_.p_.lins[i+1]) == List_Type)
      next_l = strjoin (list_to_array (s_.p_.lins[i+1]));
    else
      next_l = strjoin (s_.p_.lins[i+1]);

  i_ = w_.ptr[0] - 1;
  
  w_._i = w_._ii;

  draw ();

  rl_.getline (&line, prev_l, next_l);
 
  ifnot (s_._flags & MODIFIED)
    s_._flags = s_._flags | MODIFIED;
  
  w_.lins[w_.ptr[0] - 2] = line;

  ifnot (s_._type == "txt")
    {
    variable p = s_.parsearray ([line]);
    p = json_decode (json_encode (p));
    s_.p_.lins[i-1] = p.lins[0];
    s_.p_.cols[i-1] = p.cols[0];
    s_.p_.clrs[i-1] = p.clrs[0];

    s_.p_.lnrs[i-1] = p.lnrs[0];
    variable ii;
    _for ii (0, length (s_.p_.lnrs[i-1]) - 1)
      s_.p_.lnrs[i-1][ii] = i-1;
    s_.p_.lnrs[i-1][*] = i-1;
    }
  else
    s_.p_.lins[i-1] = line;
  
  s_.st_.st_size += strbytelen (line);
  s_.encode ();
  return; 
}

private define newline ()
{
  variable
    i_,
    i__,
    prev_l,
    next_l,
    col = s_._indent,
    i = any (['o', '\r'] == _chr_) ? v_lnr (w_.ptr[0] + 1) : v_lnr (w_.ptr[0] - 1),
    line = repeat (" ", s_._indent);
  
  s_.p_.lins = list_concat (s_.p_.lins[[0:i]], s_.p_.lins[[i:]]);
  s_.p_.lnrs = list_concat (s_.p_.lnrs[[0:i]], s_.p_.lnrs[[i:]]);

  s_.p_.lins[i+1] = line;

  if (length (s_.p_.lnrs))
    if (typeof (s_.p_.lnrs[0]) == List_Type)
      _for i__ (i, length (s_.p_.lnrs) - 1)
        _for i_ (0, length (s_.p_.lnrs[i__]) - 1)
          s_.p_.lnrs[i__][i_]--;
   else
      _for i__ (i, length (s_.p_.lnrs) - 1)
        s_.p_.lnrs[i__]--;

  if (any (['o', '\r'] == _chr_))
    w_.ptr[0]++;
  else
    w_.ptr[0]--;
  
  w_.ptr[1] = col;

  ifnot (i)
    prev_l = "";
  else
    prev_l = v_lin (w_.ptr[0] - 1);

  if (i == w_._len)
    next_l = "";
  else
    if (typeof (s_.p_.lins[i+1]) == List_Type)
      next_l = strjoin (list_to_array (s_.p_.lins[i+1]));
    else
      next_l = strjoin (s_.p_.lins[i+1]);
  
  srv->write_nstring_dr (line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);

  rl_.getline (&line, prev_l, next_l);
 
  ifnot (s_._flags & MODIFIED)
    s_._flags = s_._flags | MODIFIED;
  
  w_.lins[w_.ptr[0] - 2] = line;

  ifnot (s_._type == "txt")
    {
    variable p = s_.parsearray ([line]);
    p = json_decode (json_encode (p));
    s_.p_.lins[i] = p.lins[0];
    s_.p_.cols[i] = p.cols[0];
    s_.p_.clrs[i] = p.clrs[0];

    s_.p_.lnrs[i] = p.lnrs[0];
    variable ii;
    _for ii (0, length (s_.p_.lnrs[i]) - 1)
      s_.p_.lnrs[i][ii] = i;
    s_.p_.lnrs[i][*] = i;
    }
  else
    s_.p_.lins[i] = line;
  
  s_.st_.st_size += strbytelen (line);
  s_.encode ();
  return; 
}

private define edit_line ()
{
  variable
    prev_l,
    next_l,
    col = w_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line);

  ifnot (i)
    prev_l = "";
  else
    prev_l = v_lin (w_.ptr[0] - 1);

  if (i == w_._len)
    next_l = "";
  else
    if (typeof (s_.p_.lins[i+1]) == List_Type)
      next_l = strjoin (list_to_array (s_.p_.lins[i+1]));
    else
      next_l = strjoin (s_.p_.lins[i+1]);
  
  if ('C' == _chr_) 
    line = substr (line, 1, col);
  else if ('a' == _chr_)
    w_.ptr[1]++;
  else if ('A' == _chr_)
    w_.ptr[1] = len;
 
  s_.st_.st_size -= strbytelen (line);

  srv->write_nstring_dr (line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);

  rl_.getline (&line, prev_l, next_l);
 
  ifnot (s_._flags & MODIFIED)
    s_._flags = s_._flags | MODIFIED;
  
  w_.lins[w_.ptr[0] - 2] = line;

  ifnot (s_._type == "txt")
    {
    variable p = s_.parsearray ([line]);
    p = json_decode (json_encode (p));
    s_.p_.lins[i] = p.lins[0];
    s_.p_.cols[i] = p.cols[0];
    s_.p_.clrs[i] = p.clrs[0];

    s_.p_.lnrs[i] = p.lnrs[0];
    variable ii;
    _for ii (0, length (s_.p_.lnrs[i]) - 1)
      s_.p_.lnrs[i][ii] = i;
    s_.p_.lnrs[i][*] = i;
    }
  else
    s_.p_.lins[i] = line;
  
  s_.st_.st_size += strbytelen (line);
  s_.encode ();
  return; 
}

pf[string ('o')] = &newline;
pf[string ('O')] = &newlineO;
pf[string ('d')] = &del;
pf[string ('x')] = &del_chr;
pf[string ('X')] = &del_chr;
pf[string ('C')] = &edit_line;
pf[string ('i')] = &edit_line;
pf[string ('a')] = &edit_line;
pf[string ('A')] = &edit_line;
pf[string (keys->CTRL_u)] = &redo;
pf[string ('u')] = &undo;
pf[string ('>')] = &indent_out;
pf[string ('<')] = &indent_in;
