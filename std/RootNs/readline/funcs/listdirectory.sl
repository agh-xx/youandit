define main (self, retval, dir, pat, pos)
{
  variable
    ar = String_Type[0],
    st = stat_file (dir);

  if (NULL == st)
    {
    @retval = -1;
    throw Return, " ", ar;
    }

  ifnot (stat_is ("dir", st.st_mode))
    throw Return, " ", [dir];

  ar = listdir (dir);

  if (NULL == ar)
    {
    @retval = -1;
    throw Return, " ", ar;
    }

  ifnot (NULL == pat)
    ar = ar[wherenot (array_map (Char_Type, &strncmp, ar, pat, pos))];

  throw Return, " ", ar[array_sort (ar)];
}
