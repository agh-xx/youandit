define main (self, ar, col, len)
{
  ifnot (length (ar))
    {
    @len = 0;
    throw Return, " ", @Array_Type[0];
    }

  variable
    i,
    l,
    lar,
    hlreg = qualifier ("hl_region"),
    lines = qualifier ("lines", LINES),
    origlen = @len,
    rows = [1:lines-3],
    nar = @len < lines - 3 ? @ar : ar[[:lines - 4]],
    header = qualifier ("header", repeat ("_", COLUMNS));

  _for i (0, length (nar) - 1)
    {
    l = strlen (nar[i]);
    if (l < COLUMNS)
      nar[i] = nar[i] + repeat (" ", COLUMNS - l);
    }

  if (@len < lines - 3)
    {
    lar = String_Type[lines-@len-3];
    lar[*] = repeat (" ", COLUMNS);
    nar = [nar, lar];
    }

  srv->write_str_at (sprintf ("%s%s", header,
     repeat (" ", COLUMNS - strlen (header))), qualifier ("head_clr", COLOR.hlhead), 0, 0);

  srv->write_ar_at (nar, qualifier ("color", COLOR.focus), rows, 0);
 
  ifnot (NULL == hlreg)
    srv->set_color_in_region (hlreg[0], hlreg[1], hlreg[2], hlreg[3], hlreg[4]);

  srv->gotorc (qualifier ("row", PROMPTROW), col < COLUMNS ? col : col - COLUMNS);

  srv->refresh;

  @len = @len >= lines - 2;

  throw Return, " ", ar[[origlen >= lines - 3 ? lines - 4 : origlen:]];
}
