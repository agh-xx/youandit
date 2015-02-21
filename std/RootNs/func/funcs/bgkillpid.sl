define main ()
{
  if (1 == _NARGS)
    {
    srv->send_msg ("pid is required", -1);
    throw GotoPrompt;
    }

  variable
    argv = list_to_array (__pop_list (_NARGS - 1)),
    exit_stat = proc->kill_pid (argv[0]);

  if (-1 == exit_stat)
    srv->send_msg (sprintf ("%s: no such process", argv[0]), -1);
  else
    srv->send_msg (sprintf ("%s: killed process, EXIT_STATUS: %d", argv[0], exit_stat), 0);

  throw GotoPrompt;
}
