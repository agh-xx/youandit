define main (self, str, ar, pat)
{
  variable
    index = "." == pat ? 0 : strlen (pat),
    len = strlen (ar[0]),
    new_str = len > index ? ar[0][[0:index]] : NULL,
    indices = NULL != new_str ? array_map (Char_Type, &string_match, ar,
        str_quote_string (sprintf ("^%s", new_str), ".+", '\\')) : [0];

  ifnot (length (ar) == length (where (indices)))
    throw Break;

  if ("." != pat)
    @str +=pat;
  else
    @str = "";

  while (NULL != new_str)
    {
    indices = array_map (Char_Type, &string_match, ar,
        str_quote_string (sprintf ("^%s", new_str), ".", '\\'));

    if (length (ar) == length (where (indices)))
      {
      @str += char (new_str[-1]);
      index ++;
      new_str = len > index ? ar[0][[0:index]] : NULL;
      }
    else
      throw Break;
    }
}
