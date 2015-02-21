() = evalfile ("julian_day_nr");
() = evalfile ("julian_day_to_cal");

define normalize (v)
{
  v = v - floor (v);
  if (v < 0)
    v++;
 
  return v;
}

define round2 (x)
{
  return (round (100 * x) / 100.0);
}

define moon_phase (tim)
{
  % Thanks goes to
  % http://home.att.net/~srschmitt/zenosamples/zs_lunarphasecalc.html
  % for the moonphase algorithm

  variable
    err,
    jdn,
    lmonth = tim.tm_mon + 1,
    pi = 3.1415926535897932385;

  if ((tim.tm_year >= 2038) && (lmonth >= 1) && (tim.tm_mday >= 19) && (tim.tm_hour >= 3)
     && (tim.tm_min >= 14) && (tim.tm_sec >= 7))
    return "This is the 2038 bug, happens to 32bit systems", NULL;
 
  jdn = julian_day_nr (tim;hour=12);
  if (NULL == jdn)
    {
    err = ();
    return err, NULL;
    }

  variable
    phase,
    ip = (jdn - 2451550.1) / 29.530588853,
    oldip = ((jdn - 1) - 2451550.1) / 29.530588853,
    ag = normalize (ip) * 29.53;

  if (ag < 1.84566) phase = "NEW";
  else if (ag <  5.53699) phase = "Waxing crescent";
  else if (ag <  9.22831) phase = "First quarter";
  else if (ag < 12.91963) phase = "Waxing gibbous";
  else if (ag < 16.61096) phase = "FULL";
  else if (ag < 20.30228) phase = "Waning gibbous";
  else if (ag < 23.99361) phase = "Last quarter";
  else if (ag < 27.68493) phase = "Waning crescent";
  else phase = "NEW";

  ip = ip * 2 * pi;
  oldip = oldip * 2 * pi;
 
  variable
    zodiac,
    dp = 2 * pi * normalize ((jdn - 2451562.2) / 27.55454988),
    olddp= 2 * pi * normalize ((jdn - 1 - 2451562.2) / 27.55454988),
    di = 60.4 - 3.3 * cos (dp) - 0.6 * cos (2 * ip - dp) - 0.5 * cos (2 * ip),
    olddi  = 60.4 - 3.3 * cos (olddp) - 0.6 * cos (2 * oldip - olddp) - 0.5 * cos (2 * oldip),
    np = 2 * pi * normalize ((jdn - 2451565.2 ) / 27.212220817),
    la = 5.1 * sin (np),
    rp = normalize ((jdn - 2451555.8) / 27.321582241),
    lo = 360 * rp + 6.3 * sin (dp) + 1.3 * sin (2 * ip - dp) + 0.7 * sin (2 * ip);

  if (lo < 33.18) zodiac = "Pisces - Ιχθείς";
  else if (lo <  51.16) zodiac = "Aries - Κριός";
  else if (lo <  93.44) zodiac = "Taurus - Ταύρος";
  else if (lo < 119.48) zodiac = "Gemini - Διδυμος";
  else if (lo < 135.30) zodiac = "Cancer - Καρκίνος";
  else if (lo < 173.34) zodiac = "Leo - Λέων";
  else if (lo < 224.17) zodiac = "Virgo - Παρθένος";
  else if (lo < 242.57) zodiac = "Libra - Ζυγός";
  else if (lo < 271.26) zodiac = "Scorpio - Σκορπιός";
  else if (lo < 302.49) zodiac = "Sagittarius - Τοξότης";
  else if (lo < 311.72) zodiac = "Capricorn - Αιγώκερος";
  else if (lo < 348.58) zodiac = "Aquarius - Υδροχόος";
  else zodiac = "Pisces - Ιχθείς";
 
  variable date = julian_day_to_cal (tim, jdn);

  return [
    sprintf ("Date:          %s", date),
    sprintf ("Phase:         %s", phase),
    sprintf ("Age:           %S days (%S)", round2 (ag), round2 (ag) / 29.530588853),
    sprintf ("Distance:      %S earth radii, %s", round2 (di), olddi > di ? "descendant (κατερχόμενη)" : "ascendant (ανερχόμενη)"),
    sprintf ("Latitude:      %S°", round2 (la)),
    sprintf ("Longitude:     %S°", round2 (lo)),
    sprintf ("Constellation: %s", zodiac)];
}
