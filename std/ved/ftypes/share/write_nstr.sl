static define write_nstr (s, line, clr, row)
{
  srv->write_nstr (line, clr, row, 0, COLUMNS);
}

