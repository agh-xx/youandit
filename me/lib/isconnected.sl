ineed ("fetch");

define isconnected ()
{
  variable
    s = fetch_new ();

  return int (42 != s.fetch ("http://www.google.com";write_to_var, dont_print));
}
