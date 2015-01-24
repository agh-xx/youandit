define sigint_handler ();

define sigint_handler (sig)
{
  signal (sig, &sigint_handler);

  variable
    func = __get_reference ("init_tty"),
    tty_inited = __get_reference ("TTY_Inited"),
    flush = NULL != tty_inited ? __get_reference ("flush_input") : NULL,
    reset = NULL != tty_inited ? __get_reference ("reset_tty") : NULL;

  if (@tty_inited)
    {
    (@flush) ();
    (@reset) ();
    }
 
  ifnot (NULL == func)
    (@func) (-1, 0, 0);

  if (NULL == $9)
    exit (1);

  CW.gotoprompt ();
}

signal (SIGINT, &sigint_handler);

