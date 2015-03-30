ineed ("listfuncs");

define draw ()
{
  if (-1 == cw_._len)
    {
    srv->write_ar_dr ([repeat (" ", COLUMNS), tail ()], [0, 0], [2, cw_.rows[-1], [0],
      [cw_.ptr[0], cw_.ptr[1]]]);
    return;
    }

  cw_.lnrs = Integer_Type[0];
  cw_.lins = String_Type[0];

  variable
    i = cw_.rows[0],
    ar = String_Type[0];

  cw_._ii = cw_._i;

  while (cw_._i <= cw_._len && i <= cw_.rows[-2])
    {
    cw_.lnrs = [cw_.lnrs, cw_._i];
    cw_.lins = [cw_.lins, cw_.lines[cw_._i]];
    cw_._i++;
    i++;
    }

  cw_.vlins = [cw_.rows[0]:cw_.rows[0] + length (cw_.lins) - 1];

  cw_._i = cw_._i - (i) + cw_.rows[0];

  if (-1 == cw_._i)
    cw_._i = 0;

  if (cw_.ptr[0] >= i)
    cw_.ptr[0] = i - 1;

  ar = array_map (String_Type, &substr, cw_.lins, 1, cw_._maxlen);

  if (length (ar) < length (cw_.rows) - 1)
    {
    variable t = String_Type[length (cw_.rows) - length (ar) - 1];
    t[*] = " ";
    ar = [ar, t];
    }

  ar = [ar, tail];
  
  _for i (0, length (ar) - 1)
    IMG[cw_.rows[i]] = {[ar[i]], [cw_.clrs[i]], [cw_.rows[i]], [cw_.cols[i]]};

  srv->write_ar_nstr_dr (ar, cw_.clrs, cw_.rows, cw_.cols, [cw_.ptr[0], cw_.ptr[1]], COLUMNS);
}
