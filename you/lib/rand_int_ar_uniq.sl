import ("rand");

define rand_int_ar_uniq (imin, imax, num)
{
  variable
    i,
    index = 0,
    randar = Integer_Type[num],
    rtype = rand_new (),
    ar = rand (rtype, num * 100);

  % code from upstream
  ar = __tmp(ar) mod (imax - imin + 1);

  _for i (0, length (ar) - 1)
    {
    if (any (ar[i] == randar))
     continue;
    randar[index] = ar[i];
    index ++;
    if (index == num)
      break;
    }
 
  randar += imin;

  return randar;
}
