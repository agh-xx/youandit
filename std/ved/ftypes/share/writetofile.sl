private define write_line (fp, line)
{
  line = substr (line, cw_._indent + 1, -1);
  return fwrite (line, fp);
}

static define writetofile (s, file)
{
  variable
    i,
    fp = fopen (file, "w");
 
  if (NULL == fp)
    return errno;

  _for i (0, length (cw_.lines) - 1)
    if (-1 == write_line (fp, cw_.lines[i] + "\n"))
      return errno;

  () = fclose (fp);
 
  return 0;
}
