private variable
  is_wrapped_str = 0,
  _plinlen_,
  _linlen_;

private define adjust_col ()
{
  if (_linlen_ == 0 || 0 == cw_.ptr[1] - cw_._indent)
    cw_.ptr[1] = cw_._indent;
  else if (_linlen_ > cw_._maxlen && cw_.ptr[1] + 1 == cw_._maxlen ||
    (cw_.ptr[1] - cw_._indent == _plinlen_ - 1 && _linlen_ > cw_._maxlen))
      cw_.ptr[1] = cw_._maxlen - 1;
  else if ((0 != _plinlen_ && cw_.ptr[1] - cw_._indent == _plinlen_ - 1 && (
      _linlen_ < cw_.ptr[1] || _linlen_ < cw_._maxlen))
     || (cw_.ptr[1] - cw_._indent && cw_.ptr[1] - cw_._indent >= _linlen_))
       cw_.ptr[1] = _linlen_ - 1 + cw_._indent;
}

private define down ()
{
  if (is_wrapped_str)
    {
    cw_._i = cw_._ii;
    s_.draw ();
    is_wrapped_str = 0;
    }

  _plinlen_ = v_linlen ('.');

  if (cw_.ptr[0] < cw_.vlins[-1])
    {
    cw_.ptr[0]++;
 
    _linlen_ = v_linlen ('.');
 
    adjust_col ();

    draw_tail ();

    return;
    }

  if (cw_.lnrs[-1] == cw_._len)
    return;

  cw_._i++;
 
  s_.draw ();

  _linlen_ = v_linlen ('.');
 
  adjust_col ();
 
  srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
}

private define up ()
{
  if (is_wrapped_str)
    {
    cw_._i = cw_._ii;
    s_.draw ();
    is_wrapped_str = 0;
    }

  _plinlen_ = v_linlen ('.');

  if (cw_.ptr[0] > cw_.vlins[0])
    {

    cw_.ptr[0]--;
 
    _linlen_ = v_linlen ('.');
      adjust_col ();
 
    draw_tail ();
 
    return;
    }

  ifnot (cw_.lnrs[0])
    return;

  cw_._i--;

  s_.draw ();
 
  _linlen_ = v_linlen ('.');
 
  adjust_col ();
 
  srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
}

private define gotoline ()
{
  if (count <= cw_._len + 1)
    {
    cw_._i = count - (count ? 1 : 0);
    s_.draw ();

    cw_.ptr[0] = cw_.rows[0];
    cw_.ptr[1] = cw_._indent;

    srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
    }
}

private define eof ()
{
  if (count > -1)
    {
    ifnot (count + 1)
      count = 0;

    gotoline ();
    return;
    }

  cw_._i = cw_._len - cw_._avlins;

  cw_.ptr[1] = cw_._indent;

  if (length (cw_.lins) < cw_._avlins - 1)
    {
    cw_.ptr[0] = cw_.vlins[-1];
    srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
    return;
    }

  s_.draw ();

  cw_.ptr[0] = cw_.vlins[-1];

  srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
}

private define bof ()
{
  if (count > 0)
    {
    gotoline ();
    return;
    }

  cw_._i = 0;
 
  cw_.ptr[0] = cw_.rows[0];
  cw_.ptr[1] = cw_._indent;
 
  s_.draw ();
}

private define page_down ()
{
  if (cw_._i + cw_._avlins > cw_._len)
    return;

  cw_._i += (cw_._avlins);

  cw_.ptr[1] = cw_._indent;

  s_.draw ();
}

private define page_up ()
{
  ifnot (cw_.lnrs[0] - 1)
    return;
 
  if (cw_.lnrs[0] >= cw_._avlins)
    cw_._i = cw_.lnrs[0] - cw_._avlins;
  else
    cw_._i = 0;

  cw_.ptr[1] = cw_._indent;

  s_.draw ();
}

private define right ()
{
  _linlen_ = v_linlen (cw_.ptr[0]);

  if (cw_.ptr[1] - cw_._indent < _linlen_ - 1 && cw_.ptr[1] < cw_._maxlen - 1)
   (cw_.ptr[1]++, draw_tail ());
  else if (_linlen_ + cw_._indent > cw_._maxlen && cw_.ptr[1] + 1 == cw_._maxlen)
    {
    srv->write_wrapped_str_dr (substr (v_lin ('.'), cw_._indent + 1, -1),
     11, [cw_.ptr[0], _linlen_ >= COLUMNS ? 0 : cw_._indent],
     [_linlen_ / cw_._maxlen + (_linlen_ mod cw_._maxlen ? 1 : 0),
      COLUMNS],
      1, [cw_.ptr[0], cw_.ptr[1]]);

    is_wrapped_str = 1;
    }
}

private define eos ()
{
  _linlen_ = v_linlen ('.');

  if (_linlen_ > cw_._maxlen)
    cw_.ptr[1] = cw_._maxlen - 1;
  else if (0 == _linlen_)
    cw_.ptr[1] = cw_._indent;
  else
    cw_.ptr[1] = _linlen_ + cw_._indent - 1;

  draw_tail ();
}

private define eol ()
{
  _linlen_ = v_linlen (cw_.ptr[0]);

  if (_linlen_ < cw_._maxlen)
    cw_.ptr[1] = _linlen_ + cw_._indent - 1;
  else
    {
    srv->write_wrapped_str_dr (substr (v_lin ('.'), cw_._indent + 1, -1),
     11, [cw_.ptr[0], _linlen_ >= COLUMNS ? 0 : cw_._indent],
     [_linlen_ / cw_._maxlen + (_linlen_ mod cw_._maxlen ? 1 : 0),
      cw_._maxlen - cw_._indent + (COLUMNS - cw_._maxlen)],
      1, [cw_.ptr[0], cw_.ptr[1]]);

    is_wrapped_str = 1;
    }
 
  draw_tail ();
}

private define left ()
{
  ifnot (cw_.ptr[1] - cw_._indent)
    return;

  cw_.ptr[1]--;

  draw_tail ();
}

private define bol ()
{
  cw_.ptr[1] = cw_._indent;
  draw_tail ();
}

private define bolnblnk ()
{
  cw_.ptr[1] = cw_._indent;

  _linlen_ = v_linlen ('.');

  loop (_linlen_)
    {
    ifnot (isblank (cw_.lins[cw_.ptr[0] - cw_.rows[0]][cw_.ptr[1]]))
      break;

    cw_.ptr[1]++;
    }

  draw_tail ();
}

pagerf[string (keys->DOWN)] = &down;
pagerf[string ('j')] = &down;
pagerf[string ('k')] = &up;
pagerf[string (keys->UP)] = &up;
pagerf[string (keys->END)] = &eof;
pagerf[string ('G')]= &eof;
pagerf[string (keys->HOME)] = &bof;
pagerf[string ('g')]= &bof;
pagerf[string (keys->NPAGE)] = &page_down;
pagerf[string (keys->CTRL_f)] = &page_down;
pagerf[string (keys->CTRL_b)] = &page_up;
pagerf[string (keys->PPAGE)] = &page_up;
pagerf[string (keys->RIGHT)] = &right;
pagerf[string ('l')] = &right;
pagerf[string ('h')] = &left;
pagerf[string (keys->LEFT)] = &left;
pagerf[string ('-')] = &eos;
pagerf[string ('$')] = &eol;
pagerf[string ('^')] = &bolnblnk;
pagerf[string ('0')] = &bol;
