define kill_pid (pid)
{
  () = sock->send_str_ar_get_bit (PROC_SOCKET, ["bgkillpid"]);
  () = sock->send_int_get_bit (PROC_SOCKET, pid);
  variable exit_stat = sock->send_bit_get_int (PROC_SOCKET, 0);
  return 256 == exit_stat ? -1 : exit_stat;
}

define get_bg_list ()
{
  () = sock->send_str_ar_get_bit (PROC_SOCKET, ["bglist"]);

  variable
    pids = sock->send_bit_get_int_ar (PROC_SOCKET, 0);

  if (0 == pids[0])
    return Integer_Type[0], String_Type[0];

  return pids, sock->send_bit_get_str_ar (PROC_SOCKET, 0);
}

define get_bg_pids ()
{
  () = sock->send_str_ar_get_bit (PROC_SOCKET, ["bgpids"]);
  variable ar = sock->send_bit_get_int_ar (PROC_SOCKET, 0);
  return 0 == ar[0] ? Integer_Type[0] : ar;
}

define get ()
{
  variable
    i,
    arg,
    type,
    retval,
    argv = __pop_list (_NARGS);

  () = sock->send_str_ar_get_bit (PROC_SOCKET, ["get"]);

  _for i (0, length (argv) - 1)
    {
    arg = argv[i];
    type = string (typeof (arg));
    if ("Array_Type" == type)
      type = sprintf ("%S_Ar", _typeof (arg));
 
    () = sock->send_str_get_bit (PROC_SOCKET, type);
    () = (@sock->sock_f_s_clnt[type]) (PROC_SOCKET, arg);
    }
 
  () = sock->send_str_get_bit (PROC_SOCKET, "end");
 
  retval = sock->send_bit_get_bit (PROC_SOCKET, 0);

  if (retval)
    {
    variable err = sock->send_bit_get_str_ar (PROC_SOCKET, 0);
    writefile (err, CW.msgbuf;mode = "a");
    srv->send_msg ("error calling get", -1);
    return NULL;
    }
 
  type = string (typeof (qualifier ("type", ["a"])));
  if ("Array_Type" == type)
    type = sprintf ("%S_Ar", _typeof (qualifier ("type", ["a"])));

  return (@sock->sock_f_g_clnt[type]) (PROC_SOCKET, 0);
}
