import ("curl");

private variable
  Download_Info_Type = struct
    {
    url, row, bytes_received, total_bytes, lcomponent
    },
  Total_Bytes_Received = 0,
  OUTFILE = "remote",
  CACERT = NULL,
  FOLLOWLOCATION = 0,
  CONNECTIONTIMEOUT = 0,
  USERAGENT = "User-Agent: S-Lang cURL Module",
  REMOTEALL = 0;
 
private define curl_outfile (out)
{
  OUTFILE = out;
}

private define write_progress_info (s)
{
 % msg_gotorc (0, 0);
 % msg_set_color (0);
 % msg_write_string (sprintf ("%s: S-Lang curl module. Version: %s\n",
 %                     path_basename (__argv[0]), Version));
 % msg_gotorc (s.row - 1, 0);
 % msg_draw_hline(SLsmg_Screen_Cols);
 % msg_gotorc (s.row, 0);
 % msg_write_string ( sprintf ("Downloading: `%s' from `%s'\n", s.lcomponent, s.url));
 % msg_set_color (1);
 % msg_gotorc (s.row + 1, 0);
 % msg_write_string (sprintf ("%8d/%-8d bytes ",  s.bytes_received, s.total_bytes));
 % msg_set_color (0);
 % msg_erase_eol ();
 % variable str = sprintf ("Bytes Received: %8d", Total_Bytes_Received);
 % msg_gotorc (SLsmg_Screen_Rows-1, SLsmg_Screen_Cols-strlen(str)-3);
 % msg_write_string (str);
 % msg_erase_eol ();
 % msg_refresh ();
 (@print_out) (sprintf ("%8d/%-8d bytes ",  s.bytes_received, s.total_bytes));
}

private define progress_callback (s, dltotal, dlnow, ultotal, ulnow)
{
   dlnow = int (dlnow);
   Total_Bytes_Received += (dlnow - s.bytes_received);
   s.bytes_received = dlnow;
   s.total_bytes = int (dltotal);
   write_progress_info (s);
   return 0;
}

private define write_callback (fp, str)
{
  variable len = bstrlen (str);
  if (len != fwrite (str, fp))
    return -1;

  return 0;
}

private define curl_main (url)
{
  variable
    err,
    buf,
    fp,
    c,
    file,
    s = @Download_Info_Type;

  s.url = path_dirname (url);
  s.row = 3;
  s.bytes_received = 0;
  s.lcomponent = path_basename (url);

  if ("remote" == OUTFILE)
     file = strchop (url, '/', 0)[-1];
  else
    file = OUTFILE;

  fp = fopen (file, "w");

  try (err)
    {
    c = curl_new (url);

    if (FOLLOWLOCATION)
      curl_setopt (c, CURLOPT_FOLLOWLOCATION, 1);

    curl_setopt (c, CURLOPT_WRITEFUNCTION, &write_callback, fp);
 
%    curl_setopt (c, CURLOPT_PROGRESSFUNCTION, &progress_callback, s);
 
    curl_setopt (c, CURLOPT_HTTPHEADER, [USERAGENT]);

    if (CONNECTIONTIMEOUT)
      curl_setopt (c, CURLOPT_CONNECTTIMEOUT, CONNECTIONTIMEOUT);

    curl_setopt (c, CURLOPT_NOSIGNAL, 1);

    ifnot (NULL == CACERT)
      curl_setopt (c, CURLOPT_CAINFO, CACERT);

    curl_perform (c);
    }
  catch CurlError:
    {
    (@print_err) (sprintf ("Unable to retrieve `%s'", url);print_in_msg_line);
    (@print_err) (sprintf ("%s", err.message));
    ()= remove (file);
    return -1;
    }

  if (-1 == fclose (fp))
    {
    (@print_err) (sprintf ("Unable to close file `%s'", file));
    if (-1 == remove (file))
      (@print_err) (sprintf ("Unable to remove file `%s', ERRNO: %s", file,
        errno_string (errno)));

    return -1;
    }

  fp = fopen (file, "rb");
  if (-1 == fread (&buf, String_Type, 100, fp))
    {
    (@print_err) (sprintf ("Unable to read file `%s'", file));
    return -1;
    }

  if (-1 == fclose (fp))
    {
    (@print_err) (sprintf ("Unable to close file `%s'", file));
    if (-1 == remove (file))
      (@print_err) (sprintf ("Unable to remove file `%s', ERRNO: %s", file,
        errno_string (errno)));

    return -1;
    }

  if (string_match (buf, "404 Not Found", 1))
    {
    (@print_err) (sprintf ("remote file `%s' didn't retrieved (404 Not Found)",
       file));
      return -1;
    }

  return 0;
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
  c.add("o|output", &curl_outfile; type = "string");
  c.add("remote-name-all", &REMOTEALL);
  c.add("cacert", &CACERT; type = "string");
  c.add("L|location", &FOLLOWLOCATION);
  c.add("connect-timeout", &CONNECTIONTIMEOUT; type = "int");
  c.add("A|user-agent", &USERAGENT; type = "string");
  c.add("filelist", &filelist; type = "string");
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
 
  _for url (0, len - 1)
    if (-1 == curl_main (urls[url]))
      exit_code = 1;
 
  return exit_code;
}
