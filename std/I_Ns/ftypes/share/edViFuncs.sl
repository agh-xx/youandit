variable
  _keys_ = [
    keys->DOWN, keys->UP, keys->NPAGE, keys->CTRL_f, keys->CTRL_b,
    keys->PPAGE, keys->END, 'G', 'g', keys->HOME, keys->RIGHT,
    keys->LEFT, keys->CTRL_r, '-', '$', '0', '^', '>', '<', 'u', keys->CTRL_u,
    'd'
    ],
  _funcs_ = Assoc_Type[Ref_Type];

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
  s_.p_.cols = list_concat (s_.p_.cols[[0:i - 1]], s_.p_.cols[[i + 1:]]);
  s_.p_.clrs = list_concat (s_.p_.clrs[[0:i - 1]], s_.p_.clrs[[i + 1:]]);

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

  s_._flags = s_._flags | MODIFIED;
  
  s_.encode ();

  w_._i = w_._ii;

  if (w_._i > w_._len)
    w_._i = w_._len;
}

define del ()
{
  send_ans (RLINE_GETCH);
  _chr_ = get_ans ();

  if (any (['d', 'w' == _chr_]))
    if ('d' == _chr_)
      {
      del_line ();

      draw ();
      }
}

_funcs_[string ('d')] = &del;
_funcs_[string (keys->CTRL_r)] = &reparse;
_funcs_[string (keys->DOWN)] = &down;
_funcs_[string (keys->UP)] = &up;
_funcs_[string (keys->END)] = &eof;
_funcs_[string ('G')]= &eof;
_funcs_[string (keys->HOME)] = &bof;
_funcs_[string ('g')]= &bof;
_funcs_[string (keys->NPAGE)] = &page_down;
_funcs_[string (keys->CTRL_f)] = &page_down;
_funcs_[string (keys->CTRL_b)] = &page_up;
_funcs_[string (keys->PPAGE)] = &page_up;
_funcs_[string (keys->RIGHT)] = &right;
_funcs_[string ('-')] = &eos;
_funcs_[string ('$')] = &eol;
_funcs_[string (keys->LEFT)] = &left;
_funcs_[string ('^')] = &bolnblnk;
_funcs_[string ('0')] = &bol;
_funcs_[string (keys->CTRL_u)] = &redo;
_funcs_[string ('u')] = &undo;
_funcs_[string ('>')] = &indent_out;
_funcs_[string ('<')] = &indent_in;
