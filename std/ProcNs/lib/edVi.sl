private define get_chr ()
{
  variable chr = (@getch);
  return sock->send_int_get_int (EDVI_SOCKET, chr);
}

private define get_line ()
{
  variable chr = (@getch);
  return sock->send_int_get_int (EDVI_SOCKET, chr);
}

private define get_chr_from_array ()
{
  variable ar = sock->send_bit_get_int_ar (EDVI_SOCKET, 0);
  variable chr = (@getch);
  while (0 == any (ar == chr))
    chr = (@getch);

  return sock->send_int_get_int (EDVI_SOCKET, chr);
}

private define getyn ()
{
  variable chr = (@getch);
  while (0 == any (['y', 'n'] == chr))
    chr = (@getch);
 
  return sock->send_int_get_int (EDVI_SOCKET, 'y' == chr);
}

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
  () = sock->send_int_ar_get_bit (PROC_SOCKET, [LINES, COLUMNS]);
 
  variable
    chr,
    line,
    GOTO_EXIT = 0x06f,
    READ_STDOUT = 0x0B,
    READ_STDERR = 0x016,
    RLINE_GETCH = 0x021,
    RLINE_GETLINE = 0x02C,
    RLINE_GETYN = 0x01BC,
    RLINE_GETFROMARRAY = 0x022b,
    funcs = Assoc_Type[Ref_Type],
    edvi_fd = socket (PF_UNIX, SOCK_STREAM, 0);

  funcs[string (RLINE_GETCH)] = &get_chr;
  funcs[string (RLINE_GETLINE)] = &get_line;
  funcs[string (RLINE_GETYN)] = &getyn;
  funcs[string (RLINE_GETFROMARRAY)] = &get_chr_from_array;

  bind (edvi_fd, EDVI_SOCKADDR);
  listen (edvi_fd, 2);
  EDVI_SOCKET = accept (edvi_fd);

  retval = sock->send_bit_get_int (EDVI_SOCKET, savejs);

  retval = (typeof (retval) == Integer_Type) ? retval : GOTO_EXIT;

  ifnot (GOTO_EXIT == retval)
    while (
      retval = (@funcs[string (retval)]),
      retval = (typeof (retval) == Integer_Type) ? retval : GOTO_EXIT,
      retval != GOTO_EXIT);

  variable
    out = NULL,
    err = NULL,
    exit_stat = sock->send_bit_get_int (PROC_SOCKET, 0);

  if (READ_STDOUT == exit_stat)
    {
    out = sock->send_bit_get_str_ar (PROC_SOCKET, 0);
    exit_stat = sock->send_bit_get_int (PROC_SOCKET, 0);
    }
 
  if (READ_STDERR == exit_stat)
    {
    err = sock->send_bit_get_str_ar (PROC_SOCKET, 0);
    exit_stat = sock->send_bit_get_int (PROC_SOCKET, 0);
    }

  ifnot (NULL == out)
    writefile (out, CW.buffers[CW.cur.frame].fname);
 
  ifnot (NULL == err)
    {
    writefile (err, CW.buffers[CW.cur.frame].fname);
    writefile (err, CW.msgbuf);
    }

  return 256 == exit_stat ? -1 : exit_stat;
}
