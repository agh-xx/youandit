PROC_SOCKET = socket (PF_UNIX, SOCK_STREAM, 0);

forever
  {
  try
    connect (PROC_SOCKET, PROC_SOCKADDR);
  catch AnyError:
    continue;

   break;
  }
