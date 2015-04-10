ineed ("fetch");
ineed ("json");
ineed ("isconnected");
ineed ("cmdopt");

private variable
  DLINE,
  LOCATION = "default",
  DBFILE = sprintf ("%s/weather", DATADIR),
  KEYFILE = sprintf ("%s/weather/key.txt", DATADIR),
  WEATHER_URL = "http://api.worldweatheronline.com/free/v2/weather.ashx?",
  SEARCH_URL = "http://api.worldweatheronline.com/free/v2/search.ashx?",
  DONT_RETRIEVE = NULL,
  NUM_DAYS = 5;

private define get_key ()
{
  if (-1 == access (KEYFILE, F_OK))
    {
    () =  fprintf (stderr, "%s: doesn't exists\n", KEYFILE);
    return NULL;
    }

  if (-1 == access (KEYFILE, R_OK))
    {
    () = fprintf (stderr, "%s: is not readable\n", KEYFILE);
    return NULL;
    }

  variable key = readfile (KEYFILE);

  ifnot (length (key))
    {
    () = fprintf (stderr, "No key available\n");
    () = fprintf (stderr, "You can obtain one from http://www.worldweatheronline.com/api/\n");
    return NULL;
    }

  return key[0];
}

private define get_from_site ()
{
  variable
    key = get_key ();

  if (NULL == key)
    return NULL;
 
  if (-1 == access (LOCATION, F_OK))
    {
    () = fprintf (stderr, "%s: doesn't exists\n", LOCATION);
    return NULL;
    }

  if (-1 == access (LOCATION, R_OK))
    {
    () = fprintf (stderr, "%s: Is not readble\n", LOCATION);
    return NULL;
    }

  LOCATION = readfile (LOCATION);

  ifnot (length (LOCATION))
    {
    () = fprintf (stderr, "No Latitude and Longitude values found\n");
    return NULL;
    }
 
  LOCATION = LOCATION[0];

  variable
    loc = "includelocation=yes",
    canon = sprintf ("%skey=%s&q=%s&num_days=%d&%s&format=json",
      WEATHER_URL, key, LOCATION, NUM_DAYS, loc),
    s = fetch_new (),
    retval = s.fetch (canon;write_to_var);
 
  ifnot (retval)
    return s.output;
  else
    {
    () = fprintf (stderr, "Couldn't retrieve data from internet\n");
    return NULL;
    }
}

define create_report (s)
{
  variable
    i,
    ia,
    str,
    tmp,
    temps = char (176),
    today = strftime ("%Y-%m-%d"),
    report = {};

  list_append (report, sprintf ("WEATHER REPORT FOR %s %sLat %s Long %s %s",
    s.data.nearest_area[0].areaName[0].value,
    struct_field_exists (s.data.nearest_area[0], "region")
      ? s.data.nearest_area[0].region[0].value + " "
      : "",
      s.data.nearest_area[0].latitude,
      s.data.nearest_area[0].longitude,
      s.data.nearest_area[0].country[0].value));
 
  _for i (0, length (s.data.weather) - 1)
    if (s.data.weather[i].date == today)
      break;
 
  if (s.data.weather[i].date != today)
    return ["No forecast available from previous records"];

  list_append (report, "          OBSERVATION TIME: " + s.data.current_condition[0].observation_time
      + " at " + s.data.weather[0].date);

  list_append (report, DLINE);

  while (i < length (s.data.weather))
    {
    str = s.data.weather[i].date;
    list_append (report, sprintf ("           %s", today == str ? "TODAY" : str));

    list_append (report, "MOONRISE: " + s.data.weather[i].astronomy[0].moonrise
      + " MOONSET: " + s.data.weather[i].astronomy[0].moonset
      + " SUNRISE: " + s.data.weather[i].astronomy[0].sunrise
      + " SUNSET: " + s.data.weather[i].astronomy[0].sunset);
 
    list_append (report, "            MAXTEMP: " + s.data.weather[i].maxtempC + char (176)
                      + "  MINTEMP: " + s.data.weather[i].mintempC + char (176));

    str = "            |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      {
      tmp = s.data.weather[i].hourly[ia].time;
      if ("0" == tmp)
        tmp = "00:00";
      else if (3 == strlen (tmp))
        tmp = "0" + char (tmp[0]) + ":" + tmp[[1:]];
      else
        tmp = tmp[[:1]] + ":" + tmp[[2:]];

      str += sprintf ("%-4s   |", tmp);
      }

    list_append (report, str);
 
    str = "descr       |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      {
      tmp = s.data.weather[i].hourly[ia].weatherDesc[0].value;
      if (8 < strlen (tmp))
        {
        tmp = strtok (tmp);
        if (2 == length (tmp))
          tmp = substr (tmp[0], 1, 8 - strlen (tmp[1])) + tmp[1];
        else if (3 == length (tmp))
          {
          variable a, b, c;
          a = substr (tmp[2], 1, -1);
          b = substr (tmp[0], 1, 1);
          c = substr (tmp[1], 1, 8 - (strlen (a) + strlen (b)));
          tmp = b + c + a;
          }
        else
          tmp = substr (tmp[0], 1, -1);
        }
 
      if (8 != strlen (tmp))
        tmp += repeat (" ", 8 - strlen (tmp));
 
      str += sprintf ("%8s|", tmp);
      }


    list_append (report, str);

    str = "TEMPERATURE |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      str += sprintf ("%4s%s   |", s.data.weather[i].hourly[ia].tempC, temps);
 
    list_append (report, str);
 
    str = "HUMIDITY    |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      str += sprintf ("%4s%%   |", s.data.weather[i].hourly[ia].humidity);

    list_append (report, str);

    str = "RAIN        |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      str += sprintf ("%4s%%   |", s.data.weather[i].hourly[ia].chanceofrain);
 
    list_append (report, str);

    str = "CLOUD       |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      str += sprintf ("%4s%%   |", s.data.weather[i].hourly[ia].cloudcover);
 
    list_append (report, str);
 
    str = "WIND        |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      str += sprintf ("%4s    |", s.data.weather[i].hourly[ia].winddir16Point);

    list_append (report, str);

    str = "WINDSPEED   |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      str += sprintf ("%4s Kph|", s.data.weather[i].hourly[ia].windspeedKmph);

    list_append (report, str);

    str = "FROST       |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      str += sprintf ("%4s%%   |", s.data.weather[i].hourly[ia].chanceoffrost);

    list_append (report, str);

    str = "SNOW        |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      str += sprintf ("%4s%%   |", s.data.weather[i].hourly[ia].chanceofsnow);

    list_append (report, str);

    str = "FOG         |";
    _for ia (0, length (s.data.weather[i].hourly) - 1)
      str += sprintf ("%4s%%   |", s.data.weather[i].hourly[ia].chanceoffog);
 
    list_append (report, str);

    list_append (report, DLINE);
 
    i++;
    }

  return list_to_array (report);

}

define get_from_db ()
{
  if (-1 == access (DBFILE, F_OK))
    {
    () = fprintf (stderr, "No Internet connection, neither a db file available\n");
    return NULL;
    }

  if (-1 == access (DBFILE, R_OK|W_OK))
    {
    () = fprintf (stderr, "You don't have the required permissions to the db file\n");
    return NULL;
    }
 
  variable line = readfile (DBFILE);

  ifnot (length (line))
    {
    () = fprintf (stderr, "No previous entries in the db file\n");
    return NULL;
    }

  return line[-1];
}

define weather_main ()
{
  variable
    report,
    line;
 
  if (NULL == DONT_RETRIEVE)
    if (isconnected ())
      {
      line = get_from_site ();

      if (NULL == line)
        {
        () = fprintf (stderr, "Couldn't fetch the required data\n");
        return 1;
        }

      writefile (line, DBFILE;mode = "a+");
      writefile (line, strreplace (DBFILE, BINDIR, SOURCEDIR);mode = "a+");
      }
    else
      line = get_from_db ();
  else
    line = get_from_db ();

  if (NULL == line)
    return 1;

  report = create_report (json_decode (line));
 
  () = ar_to_fp (report, "%s\n", stdout);

  return 0;
}

private define _search (pat)
{
  variable
    key = get_key ();

  if (NULL == key)
    return 1;
 
  ifnot (isconnected ())
    {
    () = fprintf (stderr, "Computer is not connected to Internet\n");
    return 1;
    }

  variable
    canon = sprintf ("%skey=%s&query=%s&format=json",
      SEARCH_URL, key, pat),
    s = fetch_new (),
    retval = s.fetch (canon;write_to_var);

    if (retval)
      {
      () = fprintf (stderr, "Couldn't retrieve data from internet\n");
      return 1;
      }

  variable
    i,
    ia,
    str,
    tmp,
    report = {},
    json = json_decode (s.output);

ifnot (NULL == struct_field_exists (json, "data"))
  ifnot (NULL == struct_field_exists (json.data, "error"))
    {
    () = fprintf (stderr, json.data.error[0].msg + "\n");
    return 1;
    }

  _for i (0, length (json.search_api[0].result) - 1)
    {
    tmp = json.search_api[0].result[i];
    list_append (report,
      tmp.areaName[0].value + "  "
     +tmp.country[0].value  + "  "
     +tmp.region[0].value   + "  Latitude "
     +tmp.latitude          + "  Longitude "
     +tmp.longitude         + "  population "
     +tmp.population);
    }
 
  () = ar_to_fp (list_to_array (report), "%s\n", stdout);

  return 0;
}

define main ()
{
  variable
    i,
    retval,
    search = NULL,
    c = cmdopt_new (&_usage);

  c.add ("search", &search;type = "string");
  c.add ("uselocation", &LOCATION;type = "string");
  c.add ("days", &NUM_DAYS;type = "int");
  c.add ("dont-retrieve", &DONT_RETRIEVE);
  c.add ("dline", &DLINE;type = "string");
 
  i = c.process (__argv, 1);

  DBFILE = sprintf ("%s/%s.txt", DBFILE, LOCATION);
  LOCATION = sprintf ("%s/weather/loc_%s.txt", DATADIR, LOCATION);

  ifnot (NULL == search)
    exit (_search (search));

  retval = weather_main ();
 
  exit (NULL == retval ? 1 : retval);
}

main ();
