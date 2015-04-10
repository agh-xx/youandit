static define write_str_at (s, line, clr, row, col)
{
  srv->write_nstr (line, clr, row, col, COLUMNS);
}

