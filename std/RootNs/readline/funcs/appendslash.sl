define main (self, file)
{
  variable
    len = strlen (file);

  if ('/' != file[-1] && 0 == (1 == len && '.' == file[0]))
    throw Return, " ", isdirectory (file) ? "/" : "";

  throw Return, " ",  "";
}
