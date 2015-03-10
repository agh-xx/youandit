import ("rand");

define main ()
{
  variable
    i,
    ar,
    fp,
    num,
    imin,
    imax,
    file,
    rtype,
    randar,
    index = 0,
    c = cmdopt_new (&_usage);

  c.add ("min", &imin;type="int");
  c.add ("max", &imax;type="int");
  c.add ("num", &num;type="int");
  c.add ("file", &file;type="string");
 
  () = c.process (__argv, 1);
 
  rtype = rand_new ();
  ar = rand (rtype, num * 100);

  % code from upstream
  ar = __tmp (ar) mod (imax - imin + 1);
 
  randar = Integer_Type[num];

  _for i (0, length (ar) - 1)
    {
    if (any (ar[i] == randar))
     continue;
    randar[index] = ar[i];
    index++;
    if (index > num)
      break;
    }

  fp = fopen (file, "w");
  () = fwrite (randar, fp);
  () = fclose (fp);

  return 0;
}
