define main (self, pat)
{
  variable keep = @self.cur;

  self.cur.chr = 0;
  self.cur.argv = [qualifier ("pat", "")];
  self.cur.col = strlen (self.cur.argv[0]) + 1;
  self.cur.index = 0;
  self.cur.line = self.cur.argv[0];

  variable
    ar = readfile (sprintf ("%s/data/pcresyntax.txt", STDNS)),
    len = length (ar),
    lines = LINES - (strlen (keep.line) / COLUMNS);

  srv->write_nstring_at (NULL, COLUMNS, 7, 0, [PROMPTROW - (strlen (self.cur.line) / COLUMNS) - length (ar) - 1,
     0, 0, strlen (self.cur.argv[0])]);

  () = root.lib.printout (ar, strlen (self.cur.argv[0]), &len;
    header = qualifier ("pat", ""), lines = lines,
    last_row = PROMPTROW - (strlen (self.cur.line) / COLUMNS),
    row = PROMPTROW - (strlen (self.cur.line) / COLUMNS) - length (ar) - 1,
    );

  forever
    {
    self.cur.chr = (@getch);

    if (any (keys->cmap.changelang == self.cur.chr))
      {
      root.func.call ("change_getch");
      continue;
      }

    if (1 == self.cur.col)
      srv->send_msg ("", 0);
 
    if (any (['\r', 033] == self.cur.chr))
      {
      ifnot (qualifier_exists ("dont_draw"))
        CW.drawwind (;dont_reread);
      root.topline ();
 
      @pat = '\r' == self.cur.chr ? self.cur.argv[0] : "";
      self.cur = @keep;
      throw Break;
      }
 
    self.cur.line = self.cur.argv[0];
    self.routine (;insert_ws);

    srv->write_nstring_at (self.cur.argv[0], COLUMNS, 7, 1, [PROMPTROW - (strlen (self.cur.line) / COLUMNS) - length (ar) - 1, 0,PROMPTROW - (strlen (self.cur.line) / COLUMNS) - length (ar) - 1, self.cur.col - 1]);
    }
}
