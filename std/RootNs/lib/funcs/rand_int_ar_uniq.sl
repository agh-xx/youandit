define main (self, imin, imax, num)
{
  variable
    ar,
    file = sprintf ("%s/rand_ar.txt", TEMPDIR);
 
    () = proc->call (["rand_int_ar_uniq", "--nocl",
      sprintf ("--min=%d", imin),
      sprintf ("--max=%d", imax),
      sprintf ("--num=%d", num),
      sprintf ("--file=%s", file),
      sprintf ("--execdir=%s/scripts", STDNS),
      sprintf ("--msgfname=%s", CW.msgbuf),
      sprintf ("--mainfname=%s", file)]);

  variable fp = fopen (file, "rb");
  () = fread (&ar, Integer_Type, num, fp);
  throw Return, " ", ar;
}
