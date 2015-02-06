import ("curl");

private variable
  Download_Info_Type = struct
    {
    url, row, bytes_received, total_bytes, lcomponent
    },
  Total_Bytes_Received = 0,
  CACERT = "/etc/ssl/certs/ca-bundle.crt",
  FOLLOWLOCATION = 1,
  CONNECTIONTIMEOUT = 30,
  USERAGENT = "User-Agent: S-Lang cURL Module",
  REMOTEALL = 0;

private define write_progress_info (s)
{
  (@print_out) (sprintf ("%8d/%-8d bytes ",  s.bytes_received, s.total_bytes);
    print_in_msg_line, dont_write_to_stdout);
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

define fetch (url, dir)
{
  variable
    saveddir = getcwd (),
    msg,
    err,
    buf,
    fp,
    c,
    file,
    s = @Download_Info_Type;
 
  ifnot (saveddir == dir)
    if (-1 == chdir (dir))
      {
      (@print_err) (sprintf ("couldn't change directory to: %s", dir));
      return -1;
      }

  s.url = path_dirname (url);
  s.row = 3;
  s.bytes_received = 0;
  s.lcomponent = path_basename (url);

  file = strchop (url, '/', 0)[-1];

  fp = fopen (file, "w");

  try (err)
    {
    c = curl_new (url);

    curl_setopt (c, CURLOPT_FOLLOWLOCATION, 1);

    curl_setopt (c, CURLOPT_WRITEFUNCTION, &write_callback, fp);
 
    curl_setopt (c, CURLOPT_PROGRESSFUNCTION, &progress_callback, s);
 
    curl_setopt (c, CURLOPT_HTTPHEADER, [USERAGENT]);

    curl_setopt (c, CURLOPT_CONNECTTIMEOUT, CONNECTIONTIMEOUT);

    curl_setopt (c, CURLOPT_NOSIGNAL, 1);

    curl_setopt (c, CURLOPT_CAINFO, CACERT);

    curl_perform (c);
    }
  catch CurlError:
    {
    (@print_err) (sprintf ("Unable to retrieve `%s'", url), sprintf ("%s", err.message));
 
    () = remove (file);
 
    ifnot (saveddir == dir)
      () = chdir (saveddir);

    return -1;
    }

  if (-1 == fclose (fp))
    {
    (@print_err) (sprintf ("Unable to close file `%s'", file));
    if (-1 == remove (file))
      (@print_err) (sprintf ("Unable to remove file `%s', ERRNO: %s", file,
        errno_string (errno)));

    ifnot (saveddir == dir)
      () = chdir (saveddir);
 
    return -1;
    }

  fp = fopen (file, "rb");
  if (-1 == fread (&buf, String_Type, 500, fp))
    {
    (@print_err) (sprintf ("Unable to read file `%s'", file));
 
    ifnot (saveddir == dir)
      () = chdir (saveddir);
 
    return -1;
    }

  if (-1 == fclose (fp))
    {
    (@print_err) (sprintf ("Unable to close file `%s'", file));
    if (-1 == remove (file))
      (@print_err) (sprintf ("Unable to remove file `%s', ERRNO: %s", file,
        errno_string (errno)));

    ifnot (saveddir == dir)
      () = chdir (saveddir);
 
    return -1;
    }

  if (string_match (buf, "404 Not Found", 1) || string_match (buf, "page not found", 1))
    {
    (@print_err) (sprintf ("remote file `%s' didn't retrieved (404 Not Found)",
       file));
 
    ifnot (saveddir == dir)
      () = chdir (saveddir);

    return -1;
    }

  ifnot (saveddir == dir)
    () = chdir (saveddir);

  (@print_out) (sprintf ("file: %s retrieved and saved to %s", file, dir));

  return 0;
}
