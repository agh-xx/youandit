define main (self)
{
  variable
    fp = popen ("mplayer --help", "r"),
    ar = array_map (String_Type, &strtrim_end, fgetslines (fp)),
    v = ar[-1];

  ifnot (strlen (v))
    v = ar[-2];

  ifnot (strncmp (v, "MPlayer2", strlen ("MPlayer2")))
    return 2;

  return 1;
}
