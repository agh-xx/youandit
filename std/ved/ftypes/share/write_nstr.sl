static define write_nstr (s, line, clr, row)
{
  srv->write_nstr (line, clr, row, cf_._indent, COLUMNS);
}
