define decode_str (buf, len)
{
  variable
    d,
    i = 0,
    l = {};

  forever
    {
    (i, d) = strskipchar (@buf, i);
    if (d)
      list_append (l, d);
    else
      break;

    @len++;
    }

  @buf = length (l) ? list_to_array (l) : ['\n'];
}

define encode_str (dec_str)
{
  return strjoin (array_map (String_Type, &sprintf, "%c", dec_str));
}
