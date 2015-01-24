import ("curl");

typedef struct
{
  url, row, fp,
}Download_Type;

private variable
  Download_Info_Type = struct
    {
    url, row, bytes_received, total_bytes, lcomponent
    },
    EXIT_CODE = 0,
  Total_Bytes_Received = 0,
  LOCKFILE,
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
  if (-1 == access (LOCKFILE, F_OK))
    {
    srv->write_str_at (sprintf ("%8d/%-8d bytes", s.bytes_received, s.total_bytes),
        0, s.row, 0);
    srv->refresh;
    }
}

private define progress_callback (s, dltotal, dlnow, ultotal, ulnow)
{
  if (-1 == access (LOCKFILE, F_OK))
    {
    srv->write_str_at (sprintf ("%8d/%-8d bytes", int (dlnow), int (dltotal)),
        0, s.row, 0);
    srv->refresh;
    }

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
 
    curl_setopt (c, CURLOPT_PROGRESSFUNCTION, &progress_callback, s);
 
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

private define fetch (urls, row)
{
  variable
    list = Assoc_Type[Download_Type],
    mult = curl_multi_new (),
    err,
    buf,
    fp,
    c,
    file,
    i,
    s = @Download_Info_Type;
 
  _for i (0, length (urls) - 1)
    {
    if ("remote" == OUTFILE)
       file = strchop (urls[i], '/', 0)[-1];
    else
      file = OUTFILE;

    list[file] = @Download_Type;
    list[file].fp = fopen (file, "w");
    list[file].row = row;
    row++;
    c = curl_new (urls[i]);
    curl_setopt (c, CURLOPT_WRITEFUNCTION, &write_callback, list[file].fp);

    curl_setopt (c, CURLOPT_PROGRESSFUNCTION, &progress_callback, list[file]);
 
    curl_setopt (c, CURLOPT_HTTPHEADER, [USERAGENT]);

    if (CONNECTIONTIMEOUT)
      curl_setopt (c, CURLOPT_CONNECTTIMEOUT, CONNECTIONTIMEOUT);

    curl_setopt (c, CURLOPT_NOSIGNAL, 1);

    ifnot (NULL == CACERT)
      curl_setopt (c, CURLOPT_CAINFO, CACERT);

    curl_multi_add_handle (mult, c);
    }

  variable
       status,
       n,
       last_n,
       dt = 5.0;
     while (last_n = curl_multi_length (mult), last_n > 0)
       {
          n = curl_multi_perform (mult, dt);
          if (n == last_n)
            continue;
          while (c = curl_multi_info_read (mult, &status), c!=NULL)
            {
               curl_multi_remove_handle (mult, c);
               variable url = curl_get_url (c);
               () = fclose (list[url]);
               if (status == 0)
                 {
                 srv->write_str_at (sprintf ("Retrieved %s", url), 1, list[url].row, 0);
    srv->refresh;
                 }
               else
                 {
                 srv->write_str_at (sprintf ("didn't Retrieved %s", url), 2, list[url].row, 0);
      srv->refresh;
                 }
            }
       }
}

define main ()
{
  variable
    i,
    len,
    urls,
    row,
    c = cmdopt_new (&_usage);

  c.add("O|remote-name", &curl_outfile, "remote");
  c.add("o|output", &curl_outfile; type = "string");
  c.add("remote-name-all", &REMOTEALL);
  c.add("cacert", &CACERT; type = "string");
  c.add("L|location", &FOLLOWLOCATION);
  c.add("connect-timeout", &CONNECTIONTIMEOUT; type = "int");
  c.add("A|user-agent", &USERAGENT; type = "string");
  c.add("lockfile", &LOCKFILE; type = "string");
  c.add("row", &row;type = "int");
  c.add("help", &_usage);
  c.add("info", &info);

  i = c.process (__argv, 1);

  if (i + 1 > __argc && NULL == filelist)
    {
    (@print_err) (sprintf ("%s: It needs at least an argument", __argv[0]));
    return 1;
    }

  urls = __argv[[i:__argc - 1]];

  len = length (urls);

  % if more than one url, use remote's filename
  if ((1 < len) || (REMOTEALL))
    OUTFILE = "remote";
 
  fetch (urls, row);
%  _for url (0, len - 1)
%    if (-1 == curl_main (urls[url]))
%      exit_code = 1;
 
  return EXIT_CODE;
}
