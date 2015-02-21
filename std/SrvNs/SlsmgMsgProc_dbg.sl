define send_msg (str, color)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  str = str == NULL || 0 == strlen (str) ? " " : str;

  () = sock->get_bit_send_str_ar (SRV_SOCKET, [str, STDERR]);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [color, MSGROW, COLUMNS]);
  () = sock->get_bit (SRV_SOCKET);
}

define send_msg_and_refresh (str, color)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  str = str == NULL || 0 == strlen (str) ? " " : str;

  () = sock->get_bit_send_str_ar (SRV_SOCKET, [str, STDERR]);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [color, MSGROW, COLUMNS]);
  () = sock->get_bit (SRV_SOCKET);
}
