define edVi (file, savejs)
{
  () = sock->send_str_ar_get_bit (PROC_SOCKET, ["edVi"]);
  () = sock->send_int_get_bit (PROC_SOCKET, qualifier_exists ("issudo"));

  if (qualifier_exists ("issudo"))
    {
    variable passwd = root.lib.getpasswd ();

    ifnot (strlen (passwd))
      {
      srv->send_msg ("Password is an empty string. Aborting ...", -1);
      return NULL;
      }

    variable retval = root.lib.validate_passwd (passwd);

    if (NULL == retval)
      {
      srv->send_msg ("This is not a valid password", -1);
      return NULL;
      }

    () = sock->send_str_get_bit (PROC_SOCKET, passwd);
    passwd = NULL;
    }

  () = sock->send_str_get_bit (PROC_SOCKET, file);
  () = sock->send_str_get_bit (PROC_SOCKET, getenv ("TERM"));
  () = sock->send_str_get_bit (PROC_SOCKET, getenv ("LANG"));
  () = sock->send_int_ar_get_bit (PROC_SOCKET, [O_RDONLY]);
  () = sock->send_int_ar_get_bit (PROC_SOCKET, [LINES, COLUMNS]); 
  
  variable
    chr,
    edvi_fd = socket (PF_UNIX, SOCK_STREAM, 0);

  bind (edvi_fd, EDVI_SOCKADDR);
  listen (edvi_fd, 2);
  EDVI_SOCKET = accept (edvi_fd);

  retval = sock->send_bit_get_int (EDVI_SOCKET, savejs);

  ifnot (111 == retval)
    while (
        chr = (@getch),
        retval = sock->send_int_get_int (EDVI_SOCKET, chr),
        retval != 111);

  variable
    out = NULL,
    err = NULL,
    exit_stat = sock->send_bit_get_int (PROC_SOCKET, 0);

  if (11 == exit_stat)
    {
    out = sock->send_bit_get_str_ar (PROC_SOCKET, 0);
    exit_stat = sock->send_bit_get_int (PROC_SOCKET, 0);
    }
  
  if (22 == exit_stat)
    {
    err = sock->send_bit_get_str_ar (PROC_SOCKET, 0);  
    exit_stat = sock->send_bit_get_int (PROC_SOCKET, 0);
    }

ifnot (NULL == out)
  writefile (out, CW.buffers[CW.cur.frame].fname);
  
ifnot (NULL == err)
  writefile (err, CW.msgbuf);

  return 256 == exit_stat ? -1 : exit_stat;
}


