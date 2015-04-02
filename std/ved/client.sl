static define char_at ()
{
  sock->send_str (SRV_SOCKET, _function_name ());
  return sock->get_int (SRV_SOCKET);
}

static define set_color_in_region (color, row, col, dr, dc)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_int_ar (SRV_SOCKET,
    [color, row, col, dr, dc, qualifier_exists ("redraw")]);
  () = sock->get_bit (SRV_SOCKET);
}

static define write_nstr (str, clr, row, col, columns)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_str (SRV_SOCKET, str);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [clr, row, col, columns]);
  () = sock->get_bit (SRV_SOCKET);
}

static define write_ar_nstr_at (ar, colors, rows, cols, len)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_str_ar (SRV_SOCKET, ar);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, colors);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, rows);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, cols);
  () = sock->get_bit_send_int (SRV_SOCKET, len);
  () = sock->get_bit (SRV_SOCKET);
}

static define write_ar_at (ar, colors, rows, cols)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_str_ar (SRV_SOCKET, ar);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, colors);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, rows);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, cols);
  () = sock->get_bit (SRV_SOCKET);
}

static define write_ar_nstr_dr (ar, colors, rows, cols, pos, len)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_str_ar (SRV_SOCKET, ar);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, colors);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, rows);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, cols);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, pos);
  () = sock->get_bit_send_int (SRV_SOCKET, len);
  () = sock->get_bit (SRV_SOCKET);
}

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

static define gotorc (row, col)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [row, col]);
  () = sock->get_bit (SRV_SOCKET);
}
