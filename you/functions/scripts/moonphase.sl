() = evalfile ("julian_day_nr");
() = evalfile ("week_day");
() = evalfile ("julian_day_to_cal");
() = evalfile ("moon_phase");
() = evalfile ("isleap");

define increase_tf (tim)
{
  variable
    year = (@tim).tm_year,
    months = [31, 28 + isleap (year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
    day = (@tim).tm_mday,
    mon = ((@tim).tm_mon);

  if (day == months[mon])
    {
    (@tim).tm_mday = 1;
    (@tim).tm_mon ++;
    if (12 == (@tim).tm_mon)
      {
      (@tim).tm_year ++;
      (@tim).tm_mon = 0;
      }
    }
  else
    (@tim).tm_mday ++;

}

define main ()
{
  variable
    err,
    tim,
    ltim = localtime (_time),
    mp,
    tok,
    ar,
    i,
    repeats = NULL,
    c = cmdopt_new (&_usage);

  c.add ("tf", &tim;type = "string");
  c.add ("for", &repeats;type = "int");

  () = c.process (__argv, 1);
 
  tok = strtok (tim, ":");

  tok = array_map (Integer_Type, &atoi, tok);
  set_struct_fields (ltim, tok[0], tok[1], tok[2], tok[3], tok[4], tok[5]);
 
  if (NULL != repeats)
    {
    mp = moon_phase (ltim);
 
    if (NULL == mp)
      {
      err = ();
      (@print_err) (err;print_in_msg_line);
      return 1;
      }

    mp = [mp];

    loop (repeats)
      {
      increase_tf (&ltim);

      mp = [mp, repeat ("_", COLUMNS), moon_phase (ltim)];
      }
    }
  else
    {
    mp = moon_phase (ltim);
 
    if (NULL == mp)
      {
      err = ();
      (@print_err) (err;print_in_msg_line);
      return 1;
      }
    }
 
  array_map (Void_Type, print_out, mp);
  return 0;
}
