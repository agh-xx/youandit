ineed ("fetch");

private variable
  OUTFILE = "remote",
  CACERT = NULL,
  FOLLOWLOCATION = NULL,
  CONNECTIONTIMEOUT = NULL,
  USERAGENT = NULL,
  REMOTEALL = 0;

private define curl_outfile (out)
{
  OUTFILE = out;
}

private define curl_main (s, url)
{
  variable file;

  if ("remote" == OUTFILE)
     file = strchop (url, '/', 0)[-1];
  else
    file = OUTFILE;
  
  return s.fetch(url;file = file);
}

define main ()
{
  variable
    i,
    len,
    url,
    urls,
    exit_code = 0,
    filelist = NULL,
    c = cmdopt_new (&_usage);

  c.add("O|remote-name", &curl_outfile, "remote");
  c.add("o|output", &curl_outfile;type = "string");
  c.add("remote-name-all", &REMOTEALL);
  c.add("cacert", &CACERT; type = "string");
  c.add("L|location", &FOLLOWLOCATION);
  c.add("connect-timeout", &CONNECTIONTIMEOUT;type = "int");
  c.add("A|user-agent", &USERAGENT; type = "string");
  c.add("filelist", &filelist;type = "string");
  c.add("help", &_usage);
  c.add("info", &info);

  i = c.process (__argv, 1);

  if (i + 1 > __argc && NULL == filelist)
    {
    (@print_err) (sprintf ("%s: It needs at least an argument", __argv[0]));
    return 1;
    }

  ifnot (NULL == filelist)
    {
    if (-1 == access (filelist, F_OK|R_OK))
      {
      (@print_err) (sprintf ("%s: No such file", filelist));
      return 1;
      }

    urls = readfile (filelist);
    }
  else
    urls = __argv[[i:__argc - 1]];

  len = length (urls);

  % if more than one url, use remote's filename
  if ((1 < len) || (REMOTEALL))
    OUTFILE = "remote";

  variable s = fetch_new (); 

  ifnot (NULL == CACERT)
    s.cacert = CACERT;

  ifnot (NULL == USERAGENT)
    s.useragent = USERAGENT;

  ifnot (NULL == FOLLOWLOCATION)
    s.followlocation = FOLLOWLOCATION;

  ifnot (NULL == CONNECTIONTIMEOUT)
    s.connectiontimeout = CONNECTIONTIMEOUT;

  _for url (0, len - 1)
    if (-1 == curl_main (s, urls[url]))
      exit_code = 1;
 
  return exit_code;
}
