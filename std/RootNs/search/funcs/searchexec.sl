import ("pcre");

define main (self, str, start, end)
{
  variable nr, match, pat;

  try
    {
    pat = pcre_compile (self.pattern, 0);
    }
  catch ParseError:
    throw Return, " ", 0;

  nr = pcre_exec (pat, str);

  if (nr)
    {
    match = pcre_nth_match (pat, 0);
    @start = match[0];
    @end = match[1];
    throw Return, " ", 1;
    }

  throw Return, " ", 0;
}
