define form_ar (items, fmt, ar, bar)
{
  @bar = String_Type[0];

  ifnot (items)
    return;

  variable i = 0;

  while (i < length (ar))
    {
    if (i + items < length (ar))
      @bar = [@bar, strjoin (array_map (
        String_Type, &sprintf, fmt, ar[[i:i + items - 1]]))];
    else
      @bar = [@bar, strjoin (array_map (String_Type, &sprintf, fmt, ar[[i:]]))];

    i += items;
    }
}
