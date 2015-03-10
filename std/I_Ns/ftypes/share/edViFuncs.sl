private variable
  _plinlen_,
  _linlen_,
  _hcolors_ = [6, 6];

define v_linlen (r)
{
  r = (r == '.' ? w_.ptr[0] : r) - 2;
  return strlen (w_.lins[r]) - s_._indent;
}

define v_lin (r)
{
  r = (r == '.' ? w_.ptr[0] : r) - 2;
  return w_.lins[r];
}

define v_lnr (r)
{
  r = (r == '.' ? w_.ptr[0] : r) - 2;
  return w_.lnrs[r];
}

define tail ()
{
  % is a bug in slsmg?
  % last line is not cleared, even with slsmg_cls, or slsmg_erase_eos,
  % or slsmg_write_nstring
 
  variable t = sprintf ("(virt row %d) (col %d) (linenr %d) (length %d) (strlen %d) state %d, states %d",
    w_.ptr[0], w_.ptr[1] - s_._indent + 1, v_lnr ('.') + 1,
    w_._len + 1, v_linlen ('.'), s_._state + 1, s_._states);
 
  t += repeat (" ", COLUMNS - strlen (t));
  return t;
}

define draw_tail ()
{
  srv->write_nstring_dr (tail, COLUMNS, 0, [LINES - 1, 0, w_.ptr[0], w_.ptr[1]]);
}

define draw_head ()
{
  variable head = [s_._fname + ", owned by (" + s_._uown + "/" + s_._gown + ") and you are "
    + WHOAMI + ", access " + s_._access, "m " + ctime (s_.st_.st_mtime) +
    " - a " + ctime (s_.st_.st_atime) + " - c " + ctime (s_.st_.st_ctime) + " - size "
    + string (s_.st_.st_size)];

  srv->write_ar_dr (head, _hcolors_, [0, 1], [0, 0], [w_.ptr[0], w_.ptr[1]]);
}

define reparse ()
{
  s_.decode (;;__qualifiers ());

  w_._len = length (s_.p_.lins) - 1;

  w_._i = 0;

  draw ();
}

define down ()
{
  if (w_.ptr[0] < w_.vlins[-1])
    {
    _plinlen_ = v_linlen ('.');

    w_.ptr[0]++;
 
    _linlen_ = v_linlen ('.');
 
    ifnot (_linlen_)
      w_.ptr[1] = s_._indent;
    else if (_linlen_ > s_._maxlen)
      w_.ptr[1] = s_._maxlen - 1;
    else
      if ((0 != _plinlen_ && w_.ptr[1] - s_._indent == _plinlen_ - 1)
       || (w_.ptr[1] - s_._indent && w_.ptr[1] - s_._indent >= _linlen_))
         w_.ptr[1] = _linlen_ - 1 + s_._indent;

    draw_tail ();

    return;
    }

  if (w_.lnrs[-1] == w_._len)
    return;

  w_._i++;
 
  draw ();
}

define up ()
{
  if (w_.ptr[0] > w_.vlins[0])
    {
    _plinlen_ = v_linlen ('.');

    w_.ptr[0]--;
 
    _linlen_ = v_linlen ('.');

    ifnot (_linlen_)
      w_.ptr[1] = s_._indent;
    else if (_linlen_ > s_._maxlen)
      w_.ptr[1] = s_._maxlen - 1;
    else
      if ((0 != _plinlen_ && w_.ptr[1] - s_._indent == _plinlen_ - 1)
       || (w_.ptr[1] - s_._indent && w_.ptr[1] - s_._indent >= _linlen_))
         w_.ptr[1] = _linlen_ - 1 + s_._indent;
 
    draw_tail ();
 
    return;
    }

  ifnot (w_.lnrs[0])
    return;

  w_._i--;

  draw ();
}

define eof ()
{
  w_._i = w_._len - w_._avlins + 2;

  w_.ptr[1] = s_._indent;

  if (length (w_.lins) < w_._avlins - 1)
    {
    w_.ptr[0] = w_.vlins_[-1];
    srv->gotorc_draw (w_.ptr[0], w_.ptr[1]);
    return;
    }

  draw ();

  w_.ptr[0] = w_.vlins[-1];

  srv->gotorc_draw (w_.ptr[0], w_.ptr[1]);
}

define bof ()
{
  w_._i = 0;
 
  w_.ptr[0] = 2;
  w_.ptr[1] = s_._indent;
 
  draw ();
}

define page_down ()
{
  if (w_._i + w_._avlins > w_._len)
    return;

  w_._i += (w_._avlins - 2);

  w_.ptr[1] = s_._indent;

  draw ();
}

define page_up ()
{
  ifnot (w_.lnrs[0] - 1)
    return;
 
  if (w_.lnrs[0] >= w_._avlins)
    w_._i = w_.lnrs[0] - w_._avlins + 2;
  else
    w_._i = 0;

  w_.ptr[1] = s_._indent;

  draw ();
}

define right ()
{
  _linlen_ = v_linlen (w_.ptr[0]);

  if (w_.ptr[1] - s_._indent < _linlen_ - 1 && w_.ptr[1] < s_._maxlen - 1)
   (w_.ptr[1]++, draw_tail ());
  else if (_linlen_ + s_._indent > s_._maxlen && w_.ptr[1] + 1 == s_._maxlen)
    srv->write_wrapped_str_dr (substr (v_lin ('.'), s_._indent + 1, -1),
     11, [w_.ptr[0], _linlen_ >= COLUMNS ? 0 : s_._indent],
     [_linlen_ / s_._maxlen + (_linlen_ mod s_._maxlen ? 1 : 0),
      COLUMNS],
      1, [w_.ptr[0], w_.ptr[1]]);
}

define eos ()
{
  _linlen_ = v_linlen ('.');

  if (_linlen_ > s_._maxlen)
    w_.ptr[1] = s_._maxlen - 1;
  else if (0 == _linlen_)
    w_.ptr[1] = s_._indent;
  else
    w_.ptr[1] = _linlen_ + s_._indent - 1;

  draw_tail ();
}

define eol ()
{
  _linlen_ = v_linlen (w_.ptr[0]);

  if (_linlen_ < s_._maxlen)
    w_.ptr[1] = _linlen_ + s_._indent - 1;
  else
    srv->write_wrapped_str_dr (substr (v_lin ('.'), s_._indent + 1, -1),
     11, [w_.ptr[0], _linlen_ >= COLUMNS ? 0 : s_._indent],
     [_linlen_ / s_._maxlen + (_linlen_ mod s_._maxlen ? 1 : 0),
      s_._maxlen - s_._indent + (COLUMNS - s_._maxlen)],
      1, [w_.ptr[0], w_.ptr[1]]);
 
  draw_tail ();
}

define left ()
{
  ifnot (w_.ptr[1] - s_._indent)
    return;

  w_.ptr[1]--;

  draw_tail ();
}

define bol ()
{
  w_.ptr[1] = s_._indent;
  draw_tail ();
}

define bolnblnk ()
{
  w_.ptr[1] = s_._indent;

  _linlen_ = v_linlen ('.');

  loop (_linlen_)
    {
    ifnot (isblank (w_.lins[w_.ptr[0] - 2][w_.ptr[1]]))
      break;

    w_.ptr[1]++;
    }

  draw_tail ();
}

define undo ()
{
  if (s_._state + 1 >= s_._states || s_._states == 1)
    return;
 
  s_._state++;

  s_.p_ = s_.getjs ().p_;

  w_._len = length (s_.p_.lins) - 1;
  w_._i = 0;

  draw ();
}

define redo ()
{
  ifnot (s_._state)
    return;

  s_._state--;

  s_.p_ = s_.getjs ().p_;

  w_._len = length (s_.p_.lins) - 1;
  w_._i = 0;

  draw ();
}

define indent_out ()
{
  if (s_._indent > COLUMNS - 84)
    return;

  s_._indent += 4;
  w_.ptr[1] = s_._indent;

  reparse (;reparse);
}

define indent_in ()
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
    start,
    end,
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

private define edit_line ()
{
  variable
    col = w_.ptr[1],
    i = v_lnr ('.'),
    prev_l,
    next_l,
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

pf[string ('d')] = &del;
pf[string ('x')] = &del_chr;
pf[string ('X')] = &del_chr;
pf[string ('C')] = &edit_line;
pf[string ('i')] = &edit_line;
pf[string ('a')] = &edit_line;
pf[string ('A')] = &edit_line;
pf[string (keys->CTRL_r)] = &reparse;
pf[string (keys->DOWN)] = &down;
pf[string (keys->UP)] = &up;
pf[string (keys->END)] = &eof;
pf[string ('G')]= &eof;
pf[string (keys->HOME)] = &bof;
pf[string ('g')]= &bof;
pf[string (keys->NPAGE)] = &page_down;
pf[string (keys->CTRL_f)] = &page_down;
pf[string (keys->CTRL_b)] = &page_up;
pf[string (keys->PPAGE)] = &page_up;
pf[string (keys->RIGHT)] = &right;
pf[string ('-')] = &eos;
pf[string ('$')] = &eol;
pf[string (keys->LEFT)] = &left;
pf[string ('^')] = &bolnblnk;
pf[string ('0')] = &bol;
pf[string (keys->CTRL_u)] = &redo;
pf[string ('u')] = &undo;
pf[string ('>')] = &indent_out;
pf[string ('<')] = &indent_in;

pk = array_map (Integer_Type, &integer, assoc_get_keys (pf));
