private variable
  _plinlen_,
  _linlen_;

private define down ()
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

private define up ()
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

private define eof ()
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

private define bof ()
{
  w_._i = 0;
 
  w_.ptr[0] = 2;
  w_.ptr[1] = s_._indent;
 
  draw ();
}

private define page_down ()
{
  if (w_._i + w_._avlins > w_._len)
    return;

  w_._i += (w_._avlins - 2);

  w_.ptr[1] = s_._indent;

  draw ();
}

private define page_up ()
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

private define right ()
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

private define eos ()
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

private define eol ()
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

private define left ()
{
  ifnot (w_.ptr[1] - s_._indent)
    return;

  w_.ptr[1]--;

  draw_tail ();
}

private define bol ()
{
  w_.ptr[1] = s_._indent;
  draw_tail ();
}

private define bolnblnk ()
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
