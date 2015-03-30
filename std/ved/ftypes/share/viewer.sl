private variable
  _plinlen_,
  _linlen_;

private define down ()
{
  if (cw_.ptr[0] < cw_.vlins[-1])
    {
    _plinlen_ = v_linlen ('.');

    cw_.ptr[0]++;
 
    _linlen_ = v_linlen ('.');
 
    ifnot (_linlen_)
      cw_.ptr[1] = cw_._indent;
    else if (_linlen_ > cw_._maxlen)
      cw_.ptr[1] = cw_._maxlen - 1;
    else
      if ((0 != _plinlen_ && cw_.ptr[1] - cw_._indent == _plinlen_ - 1)
       || (cw_.ptr[1] - cw_._indent && cw_.ptr[1] - cw_._indent >= _linlen_))
         cw_.ptr[1] = _linlen_ - 1 + cw_._indent;

    draw_tail ();

    return;
    }

  if (cw_.lnrs[-1] == cw_._len)
    return;

  cw_._i++;
 
  s_.draw ();
}

private define up ()
{
  if (cw_.ptr[0] > cw_.vlins[0])
    {
    _plinlen_ = v_linlen ('.');

    cw_.ptr[0]--;
 
    _linlen_ = v_linlen ('.');

    ifnot (_linlen_)
      cw_.ptr[1] = cw_._indent;
    else if (_linlen_ > cw_._maxlen)
      cw_.ptr[1] = cw_._maxlen - 1;
    else
      if ((0 != _plinlen_ && cw_.ptr[1] - cw_._indent == _plinlen_ - 1)
       || (cw_.ptr[1] - cw_._indent && cw_.ptr[1] - cw_._indent >= _linlen_))
         cw_.ptr[1] = _linlen_ - 1 + cw_._indent;
 
    draw_tail ();
 
    return;
    }

  ifnot (cw_.lnrs[0])
    return;

  cw_._i--;

  s_.draw ();
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
    srv->write_wrapped_str_dr (substr (v_lin ('.'), cw_._indent + 1, -1),
     11, [cw_.ptr[0], _linlen_ >= COLUMNS ? 0 : cw_._indent],
     [_linlen_ / cw_._maxlen + (_linlen_ mod cw_._maxlen ? 1 : 0),
      COLUMNS],
      1, [cw_.ptr[0], cw_.ptr[1]]);
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
    srv->write_wrapped_str_dr (substr (v_lin ('.'), cw_._indent + 1, -1),
     11, [cw_.ptr[0], _linlen_ >= COLUMNS ? 0 : cw_._indent],
     [_linlen_ / cw_._maxlen + (_linlen_ mod cw_._maxlen ? 1 : 0),
      cw_._maxlen - cw_._indent + (COLUMNS - cw_._maxlen)],
      1, [cw_.ptr[0], cw_.ptr[1]]);
 
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

pf[string (keys->DOWN)] = &down;
pf[string ('j')] = &down;
pf[string ('k')] = &up;
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
pf[string ('l')] = &right;
pf[string ('h')] = &left;
pf[string (keys->LEFT)] = &left;
pf[string ('-')] = &eos;
pf[string ('$')] = &eol;
pf[string ('^')] = &bolnblnk;
pf[string ('0')] = &bol;
