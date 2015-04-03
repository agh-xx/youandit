define main (self, ar, col, len)
{
  ifnot (length (ar))
    {
    @len = 0;
    throw Return, " ", @Array_Type[0];
    }

  variable
    l,
    i,
    row,
    lrow = qualifier ("last_row"),
    lar = String_Type[0],
    rows = Integer_Type[0],
    cols = Integer_Type[0],
    clrs = Integer_Type[0],
    hlreg = qualifier ("hl_region"),
    lines = qualifier ("lines", LINES),
    origlen = @len,
    header = qualifier ("header"),
    nar = @len < lines ? @ar : ar[[:lines - 1]];

  ifnot (NULL == PRINTROWS)
    {
    _for i (0, length (PRINTROWS) - 1)
      {
      row = PRINTROWS[i];
      rows = [rows, row];
      if (NULL == IMG[row].str)
        {
        lar = [lar, repeat (" ", COLUMNS)];
        cols = [cols, 0];
        clrs = [clrs, COLOR.normal];
        }
      else
        {
        lar = [lar, IMG[row].str];
        cols = [cols, IMG[row].col];
        clrs = [clrs, IMG[row].clr];
        }
      }

    srv->write_ar_nstr_at (lar, clrs, rows, cols, COLUMNS);
    }

  _for i (0, length (nar) - 1)
    {
    l = strlen (nar[i]);
    if (l < COLUMNS)
      nar[i] = nar[i] + repeat (" ", COLUMNS - l);
    }
 
  if (NULL == lrow)
    {
    if (@len < lines)
      {
      lar = String_Type[lines-@len];
      lar[*] = repeat (" ", COLUMNS);
      nar = [nar, lar];
      PRINTROWS = [1:lines];
      }
    }
  else
    PRINTROWS = [lrow - length (nar):lrow - 1];

  srv->write_ar_at (nar, qualifier ("color", COLOR.focus), PRINTROWS, 0);

  ifnot (NULL == header)
    {
    PRINTROWS = [(NULL != lrow ? lrow : 0) - length (nar) - 1, PRINTROWS];
    srv->write_str_at (sprintf ("%s%s", header,
      repeat (" ", COLUMNS - strlen (header))), qualifier ("head_clr", COLOR.hlhead), PRINTROWS[0], 0);
    }

  ifnot (NULL == hlreg)
    srv->set_color_in_region (hlreg[0], hlreg[1], hlreg[2], hlreg[3], hlreg[4]);

  srv->gotorc (qualifier ("row", PROMPTROW), col < COLUMNS ? col : col - COLUMNS);

  srv->refresh;

  @len = @len >= lines + 1;

  throw Return, " ", ar[[origlen >= lines ? lines - 1 : origlen:]];
}
