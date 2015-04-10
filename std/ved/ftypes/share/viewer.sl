define debug (str, get)
{
send_msg_dr (str, 1, cf_.ptr[0], cf_.ptr[1]);
ifnot (NULL == get)
  () = get_char ();
}

private define adjust_col (linlen, plinlen)
{
  if (linlen == 0 || 0 == cf_.ptr[1] - cf_._indent)
    {
    cf_.ptr[1] = cf_._indent;
    cf_._findex = 0;
    cf_._index = 0;
    }
  else if (linlen > cf_._maxlen && cf_.ptr[1] + 1 == cf_._maxlen ||
    (cf_.ptr[1] - cf_._indent == plinlen - 1 && linlen > cf_._maxlen))
      {
      cf_.ptr[1] = cf_._maxlen - 1;
      cf_._findex = 0;
      cf_._index = cf_._maxlen - cf_._indent - 1;
      }
  else if ((0 != plinlen && cf_.ptr[1] - cf_._indent == plinlen - 1 && (
      linlen < cf_.ptr[1] || linlen < cf_._maxlen))
     || (cf_.ptr[1] - cf_._indent && cf_.ptr[1] - cf_._indent >= linlen))
      {
      cf_.ptr[1] = linlen - 1 + cf_._indent;
      cf_._index = linlen - 1;
      cf_._findex = 0;
      }
}

private define down ()
{
  variable
    lnr = v_lnr ('.'),
    linlen,
    plinlen;

  if (lnr == cf_._len)
    return;

  if (is_wrapped_line)
    {
    s_.write_nstr (v_lin ('.'), 0, cf_.ptr[0]);
    is_wrapped_line = 0;
    }

  plinlen = v_linlen ('.');

  if (cf_.ptr[0] < cf_.vlins[-1])
    {
    cf_.ptr[0]++;
 
    linlen = v_linlen ('.');
 
    adjust_col (linlen, plinlen);

    draw_tail ();

    return;
    }

  if (cf_.lnrs[-1] == cf_._len)
    return;

  cf_._i++;
 
  ifnot (cf_.ptr[0] == cf_.vlins[-1])
    cf_.ptr[0]++;

  s_.draw ();
 
  linlen = v_linlen ('.');
 
  adjust_col (linlen, plinlen);
 
  srv->gotorc_draw (cf_.ptr[0], cf_.ptr[1]);
}

private define up ()
{
  variable
    linlen,
    plinlen;

  if (is_wrapped_line)
    {
    s_.write_nstr (v_lin ('.'), 0, cf_.ptr[0]);
    is_wrapped_line = 0;
    }

  plinlen = v_linlen ('.');

  if (cf_.ptr[0] > cf_.vlins[0])
    {
    cf_.ptr[0]--;
 
    linlen = v_linlen ('.');
      adjust_col (linlen, plinlen);
 
    draw_tail ();
 
    return;
    }

  ifnot (cf_.lnrs[0])
    return;

  cf_._i--;

  s_.draw ();
 
  linlen = v_linlen ('.');
 
  adjust_col (linlen, plinlen);
 
  srv->gotorc_draw (cf_.ptr[0], cf_.ptr[1]);
}

private define gotoline ()
{
  if (count <= cf_._len + 1)
    {
    cf_._i = count - (count ? 1 : 0);
    s_.draw ();

    cf_.ptr[0] = cf_.rows[0];
    cf_.ptr[1] = cf_._indent;
    cf_._findex = 0;
    cf_._index = 0;

    srv->gotorc_draw (cf_.ptr[0], cf_.ptr[1]);
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

  cf_._i = cf_._len - cf_._avlins;

  cf_.ptr[1] = cf_._indent;
  cf_._findex = 0;
  cf_._index = 0;

  if (length (cf_.lins) < cf_._avlins - 1)
    {
    cf_.ptr[0] = cf_.vlins[-1];
    srv->gotorc_draw (cf_.ptr[0], cf_.ptr[1]);
    return;
    }

  s_.draw ();

  cf_.ptr[0] = cf_.vlins[-1];

  srv->gotorc_draw (cf_.ptr[0], cf_.ptr[1]);
}

private define bof ()
{
  if (count > 0)
    {
    gotoline ();
    return;
    }

  cf_._i = 0;
 
  cf_.ptr[0] = cf_.rows[0];
  cf_.ptr[1] = cf_._indent;
  cf_._findex = 0;
  cf_._index = 0;
 
  s_.draw ();
}

private define page_down ()
{
  if (cf_._i + cf_._avlins > cf_._len)
    return;

  is_wrapped_line = 0;
  cf_._i += (cf_._avlins);

  cf_.ptr[1] = cf_._indent;
  cf_._index = cf_._indent;
  cf_._findex = cf_._indent;

  s_.draw ();
}

private define page_up ()
{
  ifnot (cf_.lnrs[0] - 1)
    return;
 
  if (cf_.lnrs[0] >= cf_._avlins)
    cf_._i = cf_.lnrs[0] - cf_._avlins;
  else
    cf_._i = 0;

  is_wrapped_line = 0;
  cf_.ptr[1] = cf_._indent;
  cf_._findex = cf_._indent;
  cf_._index = cf_._indent;

  s_.draw ();
}

private define left ()
{
  ifnot (cf_.ptr[1] - cf_._indent)
    ifnot (is_wrapped_line)
      return;

  cf_._index--;

  if (is_wrapped_line)
    {
    ifnot (cf_.ptr[1] - cf_._indent)
      {
      cf_._findex--;
 
      ifnot (cf_._findex)
        is_wrapped_line = 0;

      variable line;
      if (is_wrapped_line)
        line = substr (v_lin ('.'), cf_._findex + 1, cf_._maxlen);
      else
        line = v_lin ('.');

      s_.write_nstr (line, 0, cf_.ptr[0]);
      }
    else
      cf_.ptr[1]--;
    }
  else
    cf_.ptr[1]--;

  draw_tail ();
}

private define right ()
{
  variable linlen = v_linlen (cf_.ptr[0]);
  if (cf_._index == linlen - 1)
    return;

  if (cf_.ptr[1] < cf_._maxlen - 1)
    {
    cf_.ptr[1]++;
    cf_._index++;
    draw_tail ();
    return;
    }
 
  cf_._index++;
  cf_._findex++;

  variable line = substr (v_lin ('.'), cf_._findex + 1, cf_._maxlen);

  s_.write_nstr (line, 0, cf_.ptr[0]);

  is_wrapped_line = 1;

  draw_tail ();
}

private define eos ()
{
  variable linlen = v_linlen ('.');

  if (linlen > cf_._maxlen)
    {
    cf_.ptr[1] = cf_._maxlen - 1;
    cf_._index = cf_._findex + cf_._maxlen - 1;
    }
  else if (0 == linlen)
    {
    cf_.ptr[1] = cf_._indent;
    cf_._index = 0;
    cf_._findex = 0;
    }
  else
    {
    cf_.ptr[1] = linlen + cf_._indent - 1;
    cf_._findex = 0;
    cf_._index = linlen - 1;
    }

  draw_tail ();
}

private define eol ()
{
  variable linlen = v_linlen (cf_.ptr[0]);
 
  cf_._index = linlen - 1;

  if (linlen < cf_._maxlen)
    cf_.ptr[1] = linlen + cf_._indent - 1;
  else
    {
    cf_.ptr[1] = cf_._maxlen - 1;

    cf_._findex = linlen - cf_._maxlen;

    variable line = substr (v_lin ('.'), cf_._findex + 1, cf_._maxlen);
 
    s_.write_nstr (line, 0, cf_.ptr[0]);

    is_wrapped_line = 1;
    }
 
  draw_tail ();
}

private define bol ()
{
  cf_.ptr[1] = cf_._indent;
  cf_._findex = cf_._indent;
  cf_._index = cf_._indent;

  if (is_wrapped_line)
    {
    variable line = v_lin ('.');
    s_.write_nstr (line, 0, cf_.ptr[0]);
    is_wrapped_line = 0;
    }

  draw_tail ();
}

private define bolnblnk ()
{
  cf_.ptr[1] = cf_._indent;

  variable linlen = v_linlen ('.');

  loop (linlen)
    {
    ifnot (isblank (cf_.lins[cf_.ptr[0] - cf_.rows[0]][cf_.ptr[1]]))
      break;

    cf_.ptr[1]++;
    }

  cf_._findex = 0;
  cf_._index = cf_.ptr[1] - cf_._indent;

  draw_tail ();
}

pagerf[string (keys->DOWN)] = &down;
pagerf[string ('j')] = &down;
pagerf[string ('k')] = &up;
pagerf[string (keys->UP)] = &up;
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
pagerf[string (keys->END)] = &eol;
pagerf[string ('$')] = &eol;
pagerf[string ('^')] = &bolnblnk;
pagerf[string ('0')] = &bol;
