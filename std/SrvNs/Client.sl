ifnot (is_defined ("DONTRECONNECT"))
  SRV_SOCKET = socket (PF_UNIX, SOCK_STREAM, 0);

ifnot (is_defined ("DONTRECONNECT"))
  forever
    {
    try
      connect (SRV_SOCKET, SRV_SOCKADDR);
    catch AnyError:
      continue;

     break;
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

static define write_str_at (str, color, row, col)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_str (SRV_SOCKET, str);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [color, row, col]);
  () = sock->get_bit (SRV_SOCKET);
}

static define multi_rline_prompt (rows, ar, color, row, col)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_int_ar (SRV_SOCKET, rows);
  () = sock->get_bit_send_str_ar (SRV_SOCKET, ar);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [color, row, col, COLUMNS]);
  () = sock->get_bit (SRV_SOCKET);
}

static define write_prompt (str, col)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  str = str == NULL || 0 == strlen (str) ? " " : str;

  () = sock->get_bit_send_str (SRV_SOCKET,
    sprintf ("%s%s", qualifier ("prompt_char", ":"), str));
  () = sock->get_bit_send_int_ar (SRV_SOCKET,
    [qualifier ("color", 11), qualifier ("prompt_row", PROMPTROW), col, COLUMNS]);
  () = sock->get_bit (SRV_SOCKET);
}

static define write_nstring_at (str, len, color, refresh, pos)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  str = str == NULL || 0 == strlen (str) ? " " : str;

  () = sock->get_bit_send_str (SRV_SOCKET, str);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [len, color, refresh, pos]);
  () = sock->get_bit (SRV_SOCKET);
}

static define write_nstring_dr (str, color, pos)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  str = str == NULL || 0 == strlen (str) ? " " : str;

  () = sock->get_bit_send_str (SRV_SOCKET, str);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [COLUMNS, color, pos]);
  () = sock->get_bit (SRV_SOCKET);
}

static define send_msg (str, color)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  str = str == NULL || 0 == strlen (str) ? " " : str;

  () = sock->get_bit_send_str (SRV_SOCKET, str);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [color, MSGROW, COLUMNS]);
  () = sock->get_bit (SRV_SOCKET);
}

static define send_msg_and_refresh (str, color)
{
  sock->send_str (SRV_SOCKET, _function_name ());
 
  str = str == NULL || 0 == strlen (str) ? " " : str;

  () = sock->get_bit_send_str (SRV_SOCKET, str);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [color, MSGROW, COLUMNS]);
  () = sock->get_bit (SRV_SOCKET);
}

static define reset_smg ()
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit (SRV_SOCKET);
}

static define refresh ()
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit (SRV_SOCKET);
}

static define char_at ()
{
  sock->send_str (SRV_SOCKET, _function_name ());
  return sock->get_int (SRV_SOCKET);
}

static define get_color (color)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_str (SRV_SOCKET, color);
  return sock->get_int (SRV_SOCKET);
}

static define gotorc (row, col)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [row, col]);
  () = sock->get_bit (SRV_SOCKET);
}

static define gotorc_draw (row, col)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [row, col]);
  () = sock->get_bit (SRV_SOCKET);
}

static define cls ()
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit (SRV_SOCKET);
}

static define set_color_in_region (color, row, col, dr, dc)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [color, row, col, dr, dc]);
  () = sock->get_bit (SRV_SOCKET);
}

static define erase_eol_at (row, col)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [row, col]);
  () = sock->get_bit (SRV_SOCKET);
}

static define erase_eol_at_bg (row, col)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_int_ar (SRV_SOCKET, [row, col]);
  () = sock->get_bit (SRV_SOCKET);
}

static define clear_frame (frame_size, rowfirst, rowlast, color, clear_infoline)
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit_send_int_ar (SRV_SOCKET,
    [frame_size, rowfirst, rowlast, color, COLUMNS, clear_infoline]);
  () = sock->get_bit (SRV_SOCKET);
}

static define quit ()
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit (SRV_SOCKET);
}

static define init ()
{
  sock->send_str (SRV_SOCKET, _function_name ());
  () = sock->get_bit (SRV_SOCKET);
}

static define draw_frame (clear_frame, write_list, info_list, pos)
{
  sock->send_str (SRV_SOCKET, _function_name ());

  () = sock->get_bit_send_int_ar (SRV_SOCKET, [clear_frame[[:3]], COLUMNS, clear_frame[-1]]);

  () = sock->get_bit_send_str_ar (SRV_SOCKET, write_list[0]);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, write_list[1]);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, write_list[2]);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, write_list[3]);

  () = sock->get_bit_send_str (SRV_SOCKET, info_list[0]);
  () = sock->get_bit_send_int_ar (SRV_SOCKET, info_list[1]);

  () = sock->get_bit_send_int_ar (SRV_SOCKET, pos);

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

ifnot (is_defined ("DONTRECONNECT"))
  () = sock->get_bit_send_bit (SRV_SOCKET, DEBUG);

if (DEBUG)
  ifnot (is_defined ("DONTRECONNECT"))
    () = evalfile (sprintf ("%s/SlsmgMsg_dbg", path_dirname (__FILE__)), "srv");
