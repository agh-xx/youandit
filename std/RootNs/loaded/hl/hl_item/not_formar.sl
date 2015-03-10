define hlitem (self, ar, base, acol, item)
{
  variable
    chr,
    car,
    bar = @ar,
    len,
    tmp,
    bcol,
    lines,
    items = 1,
    i = 0,
    page = 0,
    irow = 1,
    icol = 0,
    colr = qualifier ("color", COLOR.hlregion),
    index = 0,
    esc_pend = qualifier ("esc_pend", 0),
    max_len = max (strlen (ar)) + 2,
    header = qualifier ("header", "");
 
  while ((i + 1) * COLUMNS <= acol)
    i++;

  bcol = acol - (COLUMNS * i);
 
  len = length (bar);
  @item = ar[index];
  lines = LINES - (strlen (self.cur.line) / COLUMNS);

  car = @bar;

  bar = root.lib.printout (bar, bcol, &len; header = header, lines = lines,
    row = PROMPTROW - (strlen (self.cur.line) / COLUMNS) + i,
    hl_region = [colr, irow, icol * max_len, 1, max_len]);

  chr = (@getch) (;esc_pend = esc_pend);
 
  ifnot (len || any (['\t', [keys->UP:keys->RIGHT], keys->PPAGE, keys->NPAGE] == chr))
    return chr;
 
  while ( any (['\t', [keys->UP:keys->RIGHT], keys->PPAGE, keys->NPAGE] == chr))
    {
    if ('\t' == chr)
      if (lines - 3 >= length (ar) && page == 0)
        chr = keys->RIGHT;
      else
        chr = keys->NPAGE;

    if (keys->NPAGE == chr)
      {
      ifnot (len)
        {
        bar = @ar;
        page = 0;
        }

      irow = 1;
      icol = 0;

      if (len)
        page++;

      len = length (bar);

      index = (page) * ((lines - 4) * items);

      @item = ar[index];
 
      car = @bar;

      bar = root.lib.printout (bar, bcol, &len; header = header, lines = lines,
        row = PROMPTROW - (strlen (self.cur.line) / COLUMNS) + i,
        hl_region = [colr, irow, icol * max_len, 1, max_len]);

      chr = (@getch) (;esc_pend = esc_pend);
      continue;
      }
 
    if (keys->UP == chr)
      if (0 == irow - 1)
        (irow, icol, index) =
          lines - 3 <= length (car) ? lines - 3 : length (car),
          length (car) mod items
            ? ((length (ar) - (index + 1)) mod items) - 1
            : items - 1,
          length (car) >= lines - 3
            ? (page) * ((lines - 4) * items) + ((lines - 4) * items)
            : length (ar) -1;
      else if (0 > index - items)
        (irow, icol, index) =
          1,
          0,
          (page) * ((lines - 4) * items);
      else
        {
        irow--;
        index -= items;
        }

    if (keys->DOWN == chr)
      if (irow + 4 > lines || index + items > length (ar) - 1)
        (irow, icol, index) =
          1,
          0,
          page * ((lines - 4) * items);
      else
        {
        irow++;
        index += items;
        }

    if (keys->LEFT == chr)
      {
      icol--;
      index--;

      if (-1 == index)
        if (length (car) < lines - 3)
          (irow, icol, index) =
            length (car),
            length (car) mod items
              ? ((length (ar) - (index + 1)) mod items) - 1
              : items - 1,
              length (ar) -1;

      if (-1 == icol)
        {
        irow--;
        icol = items - 1;
        }

      ifnot (irow)
        if (lines - 3 > length (car))
          {
          irow++;
          icol = 0;
          index++;
          }
        else
          (irow, icol, index) =
            lines - 3,
            0,
            (page) * ((lines - 4) * items) + ((lines - 4) * items);
      }

    if (keys->RIGHT == chr)
      if (index + 1 > length (ar) - 1)
        (irow, icol, index) =
          1,
          0,
          (page) * ((lines - 4) * items);
      else if (icol + 1 == items)
        ifnot (irow + 4 > lines)
          {
          irow++;
          icol = 0;
          index++;
          }
        else
          (irow, icol, index) =
            1,
            0,
            (page) * ((lines - 4) * items);
      else
        {
        index++;
        icol++;
        }
 
    if (keys->PPAGE== chr)
      {
      ifnot (page)
        {
        if (length (car) > lines - 3)
          page = 0;
          car = @ar;
          len = length (car);
          while (len > lines - 3)
            {
            page++;
            car = car[[lines - 4:]];
            bar = car;
            len = length (car);
            }

          (irow, icol, index) =
            1,
            0,
            (page) * ((lines - 4) * items);
        }
      else
        {
        page--;
        car = @ar;
        loop (page)
          {
          len = length (car);
          car = car[[lines - 4:]];
          }

        bar = car[[lines - 4:]];

        (irow, icol, index) =
          1,
          0,
          (page) * ((lines - 4) * items);
        }
      }

    @item = ar[index];

    if (qualifier_exists ("goto_prompt"))
      CW.readline.my_prompt ();
 
    len = length (car);

    () = root.lib.printout (car, bcol, &len; header = header, lines = lines,
      row = PROMPTROW - (strlen (self.cur.line) / COLUMNS) + i,
      hl_region = [colr, irow, icol * max_len, 1, max_len]);

    chr = (@getch) (;esc_pend = esc_pend);
    }

  return chr;
}
