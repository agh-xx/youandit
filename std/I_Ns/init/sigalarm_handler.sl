define sigalarm_handler ();

define sigalarm_handler (sig)
{
  signal (SIGINT, SIG_IGN);
  signal (sig, &sigalarm_handler);
  variable buf;
  () = read (FD_FIFO_ROOT, &buf, 16);
}

signal (SIGALRM, &sigalarm_handler);
