static define write_nstr_dr (s, line, clr, row, col, pos)
{
  srv->write_nstr_dr (line, COLUMNS, clr, [row, col, pos]);
}
