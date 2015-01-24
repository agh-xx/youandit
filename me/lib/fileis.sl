define isblock (file)
{
  variable st = qualifier ("st", stat_file (file));
  return NULL != st && stat_is ("blk", st.st_mode);
}
