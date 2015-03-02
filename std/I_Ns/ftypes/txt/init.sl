private define parsefile (s)
{
  variable
    indent = repeat (" ", s._indent),
    lins = array_map (String_Type, &sprintf, "%s%s", indent, readfile (s._fname)),
    cols = [0],
    clrs = [0],
    lnrs = [0:length (lins) - 1];

  set_struct_fields (s.p_, lnrs, lins, cols, clrs);

  return 0;
}

define init (self)
{
  variable s = struct
    {
    @self,
    _indent = 4,
    _maxlen = COLUMNS - 4,
    };
 
  s.parsefile = &parsefile;

  return s;
}
