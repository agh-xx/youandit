
static define write_ar_dr (ar, colors, rows, cols, pos)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_str_ar (SRV_SOCKET, ar);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, colors);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, rows);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, cols);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, pos);
  () = sock->get_bit (SRV_SOCKET);
}

static define write_nstring_dr (str, len, color, pos)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  str = str == NULL || 0 == strlen (str) ? " " : str;

  () = sock->get_bit_send_str (SRV_SOCKET, str);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [len, color, pos]);
  () = sock->get_bit (SRV_SOCKET);
}

static define write_wrapped_str_dr (str, clr, upcorn, drdc, fill, pos)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  () = sock->get_bit_send_str (SRV_SOCKET, str);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [clr, upcorn, drdc, fill, pos]);
  () = sock->get_bit (SRV_SOCKET);
}

static define gotorc_draw (row, col)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  () = sock->get_bit_send_int_ar (SRV_SOCKET, [row, col]);
  () = sock->get_bit (SRV_SOCKET);
}

static define draw_wind (ar, colors, rows, cols, goto)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  () = sock->get_bit_send_str_ar (SRV_SOCKET, ar);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, colors);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, rows);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, cols);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, goto);

  () = sock->get_bit (SRV_SOCKET);
}
