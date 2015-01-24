define main ()
{
  variable frame;

  if (1 == _NARGS)
    frame = CW.cur.frame;
  else
    {
    frame = ();
    frame = atoi (frame);
    }

  CW.framedelete (frame);
}
