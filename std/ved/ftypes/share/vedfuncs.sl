define clear (frow, lrow)
{
  variable
    len = lrow - frow + 1,
    ar = String_Type[len],
    cols = Integer_Type[len],
    clrs = Integer_Type[len],
    rows = [frow:lrow],
    pos = [cf_.ptr[0], cf_.ptr[1]];
 
  ar[*] = " ";
  cols[*] = 0;
  clrs[*] = 0;

  srv->write_ar_nstr_dr (ar, clrs, rows, cols, pos, COLUMNS);
}

define topline_dr (str)
{
  variable t = strftime ("[%a %d %b %I:%M:%S]");

  s_.write_nstr_dr (str + repeat (" ", COLUMNS - strlen (str) - strlen (t)) + t,
    16, 0, 0, [cf_.ptr[0], cf_.ptr[1]]);
}

define topline (str)
{
  variable t = strftime ("[%a %d %b %I:%M:%S]");

  s_.write_nstr (str + repeat (" ", COLUMNS - strlen (str) - strlen (t)) + t,
    16, 0);
}

define write_prompt (str, col)
{
  srv->write_nstr_dr (str, COLUMNS, PROMPTCLR,
    [PROMPTROW, 0, qualifier ("row", PROMPTROW), col]);
}

define send_msg_dr (str, clr, row, col)
{
  variable
    lcol = NULL == col ? strlen (str) + 1 : col,
    lrow = NULL == row ? MSGROW : row;

  srv->write_nstr_dr (str, COLUMNS, clr, [MSGROW, 0, lrow, lcol]);
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

define calcsize (ar)
{
  return int (sum (strbytelen (ar)) + length (ar));
}

define v_linlen (r)
{
  r = (r == '.' ? cf_.ptr[0] : r) - cf_.rows[0];
  return strlen (cf_.lins[r]) - cf_._indent;
}

define v_lin (r)
{
  r = (r == '.' ? cf_.ptr[0] : r) - cf_.rows[0];
  return cf_.lins[r];
}

define v_lnr (r)
{
  r = (r == '.' ? cf_.ptr[0] : r) - cf_.rows[0];
  return cf_.lnrs[r];
}

define find_Word (line, col, start, end)
{
  ifnot (col - cf_._indent)
    @start = cf_._indent;
  else
    {
    while (col--, col >= cf_._indent && 0 == isblank (line[col]));
    @start = col + 1;
    }
 
  variable len = strlen (line);
  while (col++, col < len && 0 == isblank (line[col]));
    @end = col - 1;
}

define tail ()
{
  variable
    lnr = v_lnr ('.') + 1,
    line = v_lin ('.');
 
  return sprintf ("[%s] (row %d) (col %d) (linenr %d/%d %.0f%%) (strlen %d) chr (%d), undo (%d/%d)",
    path_basename (cf_._fname), cf_.ptr[0], cf_.ptr[1] - cf_._indent + 1, lnr,
    cf_._len + 1, (100.0 / cf_._len) * lnr, v_linlen ('.'),
    qualifier ("chr", decode (substr (line, cf_._index + 1, 1))[0]),
    undolevel, length (UNDO));
}

define draw_tail ()
{
  if (is_wrapped_line)
    srv->set_color_in_region (1, cf_.ptr[0], COLUMNS - 2, 1, 2);

  srv->write_nstr_dr (tail (;;__qualifiers ()), COLUMNS, INFOCLRFG,
    [cf_.rows[-1], 0, cf_.ptr[0], cf_.ptr[1]]);
}

define reread ()
{
  cf_.lines = s_.getlines ();

  cf_._len = length (cf_.lines) - 1;
 
  ifnot (cf_._len)
    {
    cf_._ii = 0;
    cf_.ptr[0] = cf_.rows[0];
    }
  else if (cf_._ii < cf_._len)
    {
    cf_._i = cf_._ii;
    while (cf_.ptr[0] - cf_.rows[0] + cf_._ii > cf_._len)
      cf_.ptr[0]--;
    }
  else
    {
    while (cf_._ii > cf_._len)
      cf_._ii--;

    cf_.ptr[0] = cf_.rows[0];
    }

  cf_.ptr[1] = 0;
 
  cf_._i = cf_._ii;

  s_.draw ();
}

private define change_language ()
{
  chng_lang ();
}

pagerf[string (keys->rmap.changelang[0])] = &change_language;
pagerf[string (keys->CTRL_l)] = &reread;
