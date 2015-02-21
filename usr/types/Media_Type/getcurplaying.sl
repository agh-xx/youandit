define main (self)
{
  variable
    ar,
    fp = fopen (self.fifo, "w");

  () = fprintf (fp, "get_file_name\nget_time_length\nget_time_pos\n");
  () = fclose (fp);

  sleep (0.2);
 
  ar = readfile (self.outputfile);
  ifnot (length (ar))
    throw Return, " ", NULL;

  ar = ar[[length (ar) - 3:]];
 
  throw Return, " ", struct
    {
    fname = path_basename_sans_extname (substr (ar[0], 15, -1)),
    len = atoi (strchop (ar[1], '=', 0)[1]),
    pos = atoi (strchop (ar[2], '=', 0)[1])
    };
}
