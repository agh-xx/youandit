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
    lrow = PROMPTROW - (strlen (self.cur.line) / COLUMNS),
    irow,
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

  irow = lrow - (length (car) > lines ? lines : length (car));

  bar = root.lib.printout (bar, bcol, &len; header = header, lines = lines,
    last_row = PROMPTROW - (strlen (self.cur.line) / COLUMNS),
    row = PROMPTROW - (strlen (self.cur.line) / COLUMNS) + i,
    hl_region = [colr, irow, icol * max_len, 1, max_len]);

  chr = (@getch) (;esc_pend = esc_pend);
 
  ifnot (len || any (['\t', [keys->UP:keys->RIGHT], keys->PPAGE, keys->NPAGE] == chr))
    return chr;
 
  while ( any (['\t', [keys->UP:keys->RIGHT], keys->PPAGE, keys->NPAGE] == chr))
    {
    if ('\t' == chr)
      if (lines >= length (ar) && page == 0)
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
        last_row = PROMPTROW - (strlen (self.cur.line) / COLUMNS),
        row = PROMPTROW - (strlen (self.cur.line) / COLUMNS) + i,
        hl_region = [colr, irow, icol * max_len, 1, max_len]);

      chr = (@getch) (;esc_pend = esc_pend);
      continue;
      }
 
    if (keys->UP == chr)
      if ((0 == index || index < items) && 1 < length (car))
        {
        (irow, icol, index) =
          lrow - 1,
          length (car) >= lines
            ? items - 1
            : length (car) mod items
              ? ((length (ar) - (index + 1)) mod items) - 1
              : items - 1,
          length (car) >= lines
            ? ((page) * (lines * items)) + ((lines - 1) * items) + items - 1
            : length (ar) - 1;
        }
      else
        {
        irow--;
        index -= items;
        if (0 == irow || 1 == length (car))
          (irow, icol, index) =
            lrow - 1,
            length (car) >= lines
              ? items - 1
              : length (strtok (strjoin (car, " "))) mod items
                ? (length (strtok (strjoin (car, " "))) mod items) - 1
                : items - 1,
            length (car) >= lines
              ? ((page) * ((lines - 1) * items)) + ((lines - 1) * items) + items - 1
              : length (ar) - 1;
        }

    if (keys->DOWN == chr)
      if (irow + 1 > lines || index + items > length (ar) - 1)
        (irow, icol, index) =
          lrow - (length (car) > lines ? lines : length (car)),
          0,
          page * ((lines - 1) * items);
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
        if (length (car) < lines)
          (irow, icol, index) =
            lrow - 1,
            length (car) mod items
              ? ((length (ar) - (index + 1)) mod items) - 1
              : items - 1,
              length (ar) -1;

      if (-1 == icol)
        {
        irow--;
        icol = length (car) mod items
          ? (length (strtok (strjoin (car, " "))) mod items) - 1
          : items - 1;
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
            lrow - 1,
            items - 1,
           ((page) * ((lines - 1) * items)) + ((lines - 1) * items) + items - 1;
      }

    if (keys->RIGHT == chr)
      if (index + 1 > length (ar) - 1)
        (irow, icol, index) =
          lrow - (length (car) > lines ? lines : length (car)),
          0,
          (page) * ((lines - 1) * items);
      else if (icol + 1 == items)
        ifnot (irow + 4 > lines)
          {
          irow++;
          icol = 0;
          index++;
          }
        else
          (irow, icol, index) =
            lrow - (length (car) > lines ? lines : length (car)),
            0,
            (page) * ((lines - 1) * items);
      else
        {
        index++;
        icol++;
        }
 
    if (keys->PPAGE== chr)
      {
      ifnot (page)
        {
        if (length (car) > lines)
          page = 0;

        car = @ar;
        len = length (car);
        while (len > lines)
          {
          page++;
          car = car[[lines - 1:]];
          bar = car;
          len = length (car);
          }

        (irow, icol, index) =
          lrow - (length (car) > lines ? lines : length (car)),
          0,
          (page) * ((lines - 1) * items);
        }
      else
        {
        page--;
        car = @ar;
        loop (page)
          {
          len = length (car);
          car = car[[lines - 1:]];
          }

        bar = car[[lines - 1:]];

        (irow, icol, index) =
          lrow - (length (car) > lines ? lines : length (car)),
          0,
          (page) * ((lines - 1) * items);

        }
      }

    @item = ar[index];

    if (qualifier_exists ("goto_prompt"))
      CW.readline.my_prompt ();
 
    len = length (car);

    () = root.lib.printout (car, bcol, &len; header = header, lines = lines,
      last_row = PROMPTROW - (strlen (self.cur.line) / COLUMNS),
      row = PROMPTROW - (strlen (self.cur.line) / COLUMNS) + i,
      hl_region = [colr, irow, icol * max_len, 1, max_len]);

    chr = (@getch) (;esc_pend = esc_pend);
    }

  return chr;
}
