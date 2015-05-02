define waddlineat_dr (line, clr, row, col, pos, len)
{
  srv->write_nstr_dr (line, len, clr, [row, col, pos]);
}

define waddlineat (line, clr, row, col, len)
{
  srv->write_nstr (line, clr, row, col, len);
}

define waddline (line, clr, row)
{
  waddlineat (line, clr, row, cf_._indent, cf_._linlen);
}

define waddlinear (ar, clrs, rows, cols, len)
{
  srv->write_ar_nstr (ar, clrs, rows, cols, len);
}

define waddlinear_dr (ar, clrs, rows, cols, pos, len)
{
  srv->write_ar_nstr_dr (ar, clrs, rows, cols, pos, len);
}

define send_msg_dr (str, clr, row, col)
{
  variable
    lcol = NULL == col ? strlen (str) + 1 : col,
    lrow = NULL == row ? MSGROW : row;

  waddlineat_dr (str, clr, MSGROW, 0, [lrow, lcol], COLUMNS);
}

define send_msg (str, clr)
{
  waddlineat (str, clr, MSGROW, 0, COLUMNS);
}

