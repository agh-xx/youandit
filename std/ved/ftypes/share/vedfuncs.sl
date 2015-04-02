define clear (frow, lrow)
{
  variable
    len = lrow - frow + 1,
    ar = String_Type[len],
    cols = Integer_Type[len],
    clrs = Integer_Type[len],
    rows = [frow:lrow],
    pos = [cw_.ptr[0], cw_.ptr[1]];
    
  ar[*] = " ";
  cols[*] = 0;
  clrs[*] = 0;

  srv->write_ar_nstr_dr (ar, clrs, rows, cols, pos, COLUMNS);
}

define write_prompt (str, col)
{
  srv->write_nstring_dr (str, COLUMNS, PROMPTCLR,
    [PROMPTROW, 0, qualifier ("row", PROMPTROW), col]);
}

define send_msg_dr (str, clr, row, col)
{
  variable
    lcol = NULL == col ? strlen (str) + 1 : col, 
    lrow = NULL == row ? MSGROW : row;

  srv->write_nstring_dr (str, COLUMNS, clr, [MSGROW, 0, lrow, lcol]);
}

define send_msg (str, clr)
{
  srv->write_nstr (str, clr, MSGROW, 0, COLUMNS);
}

define decode (str)
{
  variable
    d,
    i = 0,
    l = {};

  forever
    {
    (i, d) = strskipchar (str, i);
    if (d)
      list_append (l, d);
    else
      break;
    }

  return length (l) ? list_to_array (l) : ['\n'];
}

define v_linlen (r)
{
  r = (r == '.' ? cw_.ptr[0] : r) - cw_.rows[0];
  return strlen (cw_.lins[r]) - cw_._indent;
}

define v_lin (r)
{
  r = (r == '.' ? cw_.ptr[0] : r) - cw_.rows[0];
  return cw_.lins[r];
}

define v_lnr (r)
{
  r = (r == '.' ? cw_.ptr[0] : r) - cw_.rows[0];
  return cw_.lnrs[r];
}

define tail ()
{
  variable
    lnr = v_lnr ('.') + 1,
    line = v_lin ('.');
  
  return sprintf ("buf [%s] (row %d) (col %d) (linenr %d/%d %.0f%%) (strlen %d) chr (%d)",
    path_basename (cw_._fname), cw_.ptr[0], cw_.ptr[1] - cw_._indent + 1, lnr,
    cw_._len + 1, (100.0 / cw_._len) * lnr, v_linlen ('.'), decode (substr (line, cw_.ptr[1] + 1, 1))[0]);
}

define draw_tail ()
{
  srv->write_nstring_dr (tail, COLUMNS, INFOCLRFG, [cw_.rows[-1], 0, cw_.ptr[0], cw_.ptr[1]]);
}

define reread ()
{
  cw_.lines = s_.getlines ();

  cw_._len = length (cw_.lines) - 1;

  cw_._i = 0;

  s_.draw ();
}

private define change_language ()
{
  chng_lang ();
}

pagerf[string (keys->rmap.changelang[0])] = &change_language;
pagerf[string (keys->CTRL_r)] = &reread;
