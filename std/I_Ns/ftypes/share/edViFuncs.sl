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
  _head_ = String_Type[2],
  _hrows_ = [0, 1],
  _hcols_ = [0, 0],
  _hcolors_ = [6, 6];

define linlen (r)
{
  if ('.' == r)
    return strlen (_lines_[s_.ptr[0] - 2]) - s_._indent;

  return strlen (_lines_[r - 2]) - s_._indent;
}

define getvirtline (r)
{
  if ('.' == r)
    return _lines_[s_.ptr[0] - 2];

  return _lines_[r - 2];
}

define tail ()
{
  return sprintf ("(virt row %d) (col %d) (linenr %d) (length %d) (strlen %d) state %d, states %d",
    s_.ptr[0], s_.ptr[1] - s_._indent + 1, _linenrs_[s_.ptr[0] - 2] + 1,
    _len_ + 1, linlen ('.'), s_._state + 1, s_._states);
}

define draw_tail ()
{
  srv->write_nstring_dr (tail, COLUMNS, 0, [LINES - 1, 0, s_.ptr[0], s_.ptr[1]]);
}

define draw_head ()
{
  _head_ = [s_._fname + ", owned by (" + s_._uown + "/" + s_._gown + ") and you are "
    + WHOAMI + ", access " + s_._access, "m " + ctime (s_.st_.st_mtime) +
    " - a " + ctime (s_.st_.st_atime) + " - c " + ctime (s_.st_.st_ctime) + " - size "
    + string (s_.st_.st_size)];
  srv->write_ar_dr (_head_, _hcolors_, [0, 1], _hcols_, [s_.ptr[0], s_.ptr[1]]);
}

define reparse ()
{
  s_.decode (;;__qualifiers ()); 

  _len_ = length (s_.js_._lines) - 1;
  _i_ = 0;

  draw ();
}

define down ()
{
  if (s_.ptr[0] < _vlines_[-1])
    {
    _plinlen_ = linlen ('.');

    s_.ptr[0]++;
    
    _linlen_ = linlen ('.');
   
    ifnot (_linlen_)
      s_.ptr[1] = s_._indent;
    else
      if ((0 != _plinlen_ && s_.ptr[1] - s_._indent == _plinlen_ - 1)
       || (s_.ptr[1] - s_._indent && s_.ptr[1] - s_._indent >= _linlen_))
         s_.ptr[1] = _linlen_ - 1 + s_._indent;

    draw_tail ();

    return; 
    }

  if (_linenrs_[-1] == _len_)
    return;

  _i_++;
  
  draw ();
}

define up ()
{
  if (s_.ptr[0] > _vlines_[0])
    {
    _plinlen_ = linlen ('.');

    s_.ptr[0]--;
    
    _linlen_ = linlen ('.');

    ifnot (_linlen_)
      s_.ptr[1] = s_._indent;
    else
      if ((0 != _plinlen_ && s_.ptr[1] - s_._indent == _plinlen_ - 1)
       || (s_.ptr[1] - s_._indent && s_.ptr[1] - s_._indent >= _linlen_))
         s_.ptr[1] = _linlen_ - 1 + s_._indent;
    
    draw_tail ();
    
    return;
    }

  ifnot (_linenrs_[0])
    return;

  _i_--;

  draw ();
}

define end_of_file ()
{
  _i_ = _len_ - _avlines_ + 2;

  s_.ptr[1] = s_._indent;

  if (length (_lines_) < _avlines_ - 1)
    {
    s_.ptr[0] = _vlines_[-1];
    srv->gotorc_draw (s_.ptr[0], s_.ptr[1]);
    return;
    }

  draw ();

  s_.ptr[0] = _vlines_[-1];

  srv->gotorc_draw (s_.ptr[0], s_.ptr[1]);
}

define go_home ()
{
  _i_ = 0;
  
  s_.ptr[0] = 2;
  s_.ptr[1] = s_._indent;
  
  draw ();
}

define page_down ()
{
  if (_i_ + _avlines_ > _len_)
    return;

  _i_ += (_avlines_ - 2);

  s_.ptr[1] = s_._indent;

  draw ();
}

define page_up ()
{
  ifnot (_linenrs_[0] - 1)
    return;
  
  if (_linenrs_[0] >= _avlines_)
    _i_ = _linenrs_[0] - _avlines_ + 2;
  else
    _i_ = 0;

  s_.ptr[1] = s_._indent;

  draw ();
}

define right ()
{
  _linlen_ = linlen (s_.ptr[0]);

  if (s_.ptr[1] - s_._indent < _linlen_ - 1 && s_.ptr[1] < s_._maxlen - 1)
    {
    s_.ptr[1]++;
    draw_tail ();
    }
  else if (_linlen_ > s_._maxlen && s_.ptr[1] + 1 == s_._maxlen)
    srv->write_wrapped_str_dr (substr (_lines_[s_.ptr[0] - 2], s_._indent + 1, -1),
     11, [s_.ptr[0], s_._indent],
     [_linlen_ / s_._maxlen + (_linlen_ mod s_._maxlen ? 1 : 0), s_._maxlen - s_._indent],
      1, [s_.ptr[0], s_.ptr[1]]);
}

define eos ()
{
  _linlen_ = linlen ('.');

  if (_linlen_ > s_._maxlen)
    s_.ptr[1] = s_._maxlen - 1;
  else if (0 == _linlen_)
    s_.ptr[1] = s_._indent;
  else
    s_.ptr[1] = _linlen_ + s_._indent - 1;

  draw_tail ();
}

define eol ()
{
  _linlen_ = linlen (s_.ptr[0]);

  if (_linlen_ < s_._maxlen)
    s_.ptr[1] = _linlen_ + s_._indent - 1;
  else
    srv->write_wrapped_str_dr (substr (_lines_[s_.ptr[0] - 2], s_._indent + 1, -1),
     11, [s_.ptr[0], s_._indent],
     [_linlen_ / s_._maxlen + (_linlen_ mod s_._maxlen ? 1 : 0), s_._maxlen - s_._indent],
      1, [s_.ptr[0], s_.ptr[1]]);
  
  draw_tail ();
}

define left ()
{
  ifnot (s_.ptr[1] - s_._indent)
    return;

  s_.ptr[1]--;

  draw_tail ();
}

define bol ()
{
  s_.ptr[1] = s_._indent;
  draw_tail ();
}

define bolnblnk ()
{
  s_.ptr[1] = s_._indent;

  _linlen_ = linlen ('.');

  loop (_linlen_)
    {
    ifnot (isblank (_lines_[s_.ptr[0] - 2][s_.ptr[1]]))
      break;

    s_.ptr[1]++;
    }

  draw_tail ();
}

define undo ()
{
  if (s_._state + 1 >= s_._states || s_._states == 1)
    return;
  
  s_._state++;

  variable js_ = s_.getjs ();
  s_.js_._lines = js_._lines;

  _len_ = length (s_.js_._lines) - 1;
  _i_ = 0;

  draw ();
}

define undo_forw ()
{
  ifnot (s_._state)
    return;

  s_._state--;

  variable js_ = s_.getjs ();
  s_.js_._lines = js_._lines;

  _len_ = length (s_.js_._lines) - 1;
  _i_ = 0;

  draw ();
}

define indent_out ()
{
  if (s_._indent > COLUMNS - 84)
    return;

  s_._indent += 4;
  s_.ptr[1] = s_._indent;

  reparse (;reparse);
}

define indent_in ()
{
  if (s_._indent <= 0)
    return;

  s_._indent -= 4;
  s_.ptr[1] = s_._indent;

  reparse (;reparse);
}

_funcs_[string (keys->CTRL_r)] = &reparse;
_funcs_[string (keys->DOWN)] = &down;
_funcs_[string (keys->UP)] = &up;
_funcs_[string (keys->END)] = &end_of_file;
_funcs_[string ('G')]= &end_of_file;
_funcs_[string (keys->HOME)] = &go_home;
_funcs_[string ('g')]= &go_home;
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
_funcs_[string (keys->CTRL_u)] = &undo_forw;
_funcs_[string ('u')] = &undo;
_funcs_[string ('>')] = &indent_out;
_funcs_[string ('<')] = &indent_in;
