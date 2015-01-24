sigprocmask (SIG_BLOCK, [SIGINT]);

set_slang_load_path (getenv ("LOAD_PATH"));
set_import_module_path (getenv ("IMPORT_PATH"));

try
  array_map (Void_Type, &import, ["slsmg", "socket"]);
catch ImportError:
  {
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
      strtok (sprintf ("Caught an exception:%s\n\
        Message:     %s\n\
        Object:      %S\n\
        Function:    %s\n\
        Line:        %d\n\
        File:        %s\n\
        Description: %s\n\
        Error:       %d\n",
        _push_struct_field_values (__get_exception_info)), "\n"));
  exit (1);
  }

variable
  DEBUG,
  SRV_FD,
  SRV_SOCKADDR = getenv ("SRV_SOCKADDR"),
  STDNS = getenv ("STDNS"),
  USRNS = getenv ("USRNS"),
  funcs = Assoc_Type[Ref_Type];

() = evalfile (sprintf ("%s/conf/colors/Init", STDNS));
() = evalfile ( sprintf ("%s/SockNs/sock_funcs", STDNS), "sock");

private define set_basic_color (field, color)
{
  % TODO: when make a map, check if field exists,
  %       also if wherefirst returns NULL
  variable colors =
    [
    "white", "red", "green", "brown", "blue", "magenta",
    "cyan", "lightgray", "gray", "brightred", "brightgreen",
    "yellow", "brightblue", "brightmagenta", "brightcyan",
    "blackonbrightcyan", "blackonwhite", "blackonred", "blackonbrown",
    "blackonyellow"
    ];

  set_struct_field (COLOR, field, wherefirst (colors == color));
}

array_map (Void_Type, &set_basic_color,
  ["normal", "msgerror", "msgsuccess", "msgwarn", "prompt",
   "border", "focus", "hlchar", "info", "activeframe", "out", "hlregion", "hlhead"],
  [COLOR.normal, COLOR.msgerror, COLOR.msgsuccess, COLOR.msgwarn,
   COLOR.prompt, COLOR.border, COLOR.focus, COLOR.hlchar,
   COLOR.info, COLOR.activeframe, COLOR.out, COLOR.hlregion, COLOR.hlhead]);

array_map (Void_Type, &slsmg_define_color, [0:14:1],
  [
  "white", "red", "green", "brown", "blue", "magenta",
  "cyan", "lightgray", "gray", "brightred", "brightgreen",
  "yellow", "brightblue", "brightmagenta", "brightcyan"
  ],
  "black");

array_map (Void_Type, &slsmg_define_color, [15:19:1],
  "black",
  array_map (String_Type, &substr,
  [
  "blackonbrightcyan", "blackonwhite", "blackonred", "blackonbrown",
  "blackonyellow",
  ], 8, -1)
  );

private define f_write (str, color, row, col)
{
  slsmg_gotorc (row, col);
  slsmg_set_color (color);
  slsmg_write_string (str);
}

private define f_erase_eol_at (row, col)
{
  slsmg_gotorc (row, col);
  slsmg_erase_eol ();
}

define f_send_msg (str, color, row, col)
{
  slsmg_gotorc (row, 0);
  slsmg_write_string (str);
  slsmg_erase_eol ();
  slsmg_set_color_in_region (
  [COLOR.msgsuccess, COLOR.msgwarn, COLOR.prompt, COLOR.msgerror][color],
    row, 0, 1, col);
}

private define write_ar_at ()
{
  variable
    ar = sock->send_bit_get_str_ar (SRV_FD, 0),
    colors = sock->send_bit_get_int_ar (SRV_FD, 0),
    rows = sock->send_bit_get_int_ar (SRV_FD, 0),
    cols = sock->send_bit_get_int_ar (SRV_FD, 0);

  array_map (Void_Type, &f_write, ar, colors, rows, cols);
  sock->send_bit (SRV_FD, 0);
}

funcs["write_ar_at"] = &write_ar_at;

private define multi_rline_prompt ()
{
  variable
    rows = sock->send_bit_get_int_ar (SRV_FD, 0),
    ar = sock->send_bit_get_str_ar (SRV_FD, 0),
    arb = sock->send_bit_get_int_ar (SRV_FD, 0);

  array_map (Void_Type, &f_erase_eol_at, rows, 0);

  slsmg_set_color_in_region (arb[0], rows[0], 0, length (rows), arb[3]);
 
  array_map (Void_Type, &f_write, ar, arb[0], rows, 0);
 
  slsmg_gotorc (arb[1], arb[2]);
  slsmg_refresh ();
 
  sock->send_bit (SRV_FD, 0);
}

funcs["multi_rline_prompt"] = &multi_rline_prompt;

private define write_prompt ()
{
  variable
    str = sock->send_bit_get_str (SRV_FD, 0),
    ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  f_erase_eol_at (ar[1], 0);

  slsmg_set_color_in_region (ar[0], ar[1], 0, 1, ar[3]);

  f_write (str, ar[0], ar[1], 0);
 
  slsmg_gotorc (ar[1], ar[2]);
  slsmg_refresh ();
 
  sock->send_bit (SRV_FD, 0);
}

funcs["write_prompt"] = &write_prompt;

private define write_nstring_at ()
{
  variable
    str = sock->send_bit_get_str (SRV_FD, 0),
    ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  slsmg_gotorc (ar[3], ar[4]);
  slsmg_set_color (ar[1]);
  slsmg_write_nstring (str, ar[0]);
  slsmg_gotorc (ar[5], ar[6]);

  if (ar[2])
    slsmg_refresh ();

  sock->send_bit (SRV_FD, 0);
}

funcs["write_nstring_at"] = &write_nstring_at;

private define reset_smg ()
{
  slsmg_reset_smg ();
  sock->send_bit (SRV_FD, 0);
}

funcs["reset_smg"] = &reset_smg;

private define refresh ()
{
  slsmg_refresh ();
  sock->send_bit (SRV_FD, 0);
}

funcs["refresh"] = &refresh;

private define init ()
{
  slsmg_init_smg ();
  sock->send_bit (SRV_FD, 0);
}

funcs["init"] = &init;

private define gotorc ()
{
  variable ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  slsmg_gotorc (ar[0], ar[1]);
  sock->send_bit (SRV_FD, 0);
}

funcs["gotorc"] = &gotorc;

private define send_msg ()
{
  variable
    str = sock->send_bit_get_str (SRV_FD, 0),
    ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  f_send_msg (str, ar[0], ar[1], ar[2]);
  sock->send_bit (SRV_FD, 0);
}

funcs["send_msg"] = &send_msg;

private define send_msg_and_refresh ()
{
  variable
    str = sock->send_bit_get_str (SRV_FD, 0),
    ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  f_send_msg (str, ar[0], ar[1], ar[2]);
  slsmg_refresh ();
  sock->send_bit (SRV_FD, 0);
}

funcs["send_msg_and_refresh"] = &send_msg_and_refresh;

private define write_str_at ()
{
  variable
    str = sock->send_bit_get_str (SRV_FD, 0),
    ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  f_write (str, ar[0], ar[1], ar[2]);
  sock->send_bit (SRV_FD, 0);
}

funcs["write_str_at"] = &write_str_at;

private define clear_frame ()
{
  variable ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  array_map (Void_Type, &f_erase_eol_at, [ar[1]:ar[2]], 0);

  slsmg_set_color_in_region (COLOR.normal, ar[1], 0, ar[0], ar[4]);

  if (ar[5])
    {
    f_erase_eol_at (ar[2] + 1, 0);
    slsmg_set_color_in_region (COLOR.info, ar[2] + 1, 0, 1, ar[4]);
    }

  sock->send_bit (SRV_FD, 0);
}

funcs["clear_frame"] = &clear_frame;

private define draw_frame ()
{
  % clear frame
  variable ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  array_map (Void_Type, &f_erase_eol_at, [ar[1]:ar[2]], 0);

  slsmg_set_color_in_region (ar[3], ar[1], 0, ar[0], ar[4]);

  if (ar[5])
    {
    f_erase_eol_at (ar[2] + 1, 0);
    slsmg_set_color_in_region (COLOR.info, ar[2] + 1, 0, 1, ar[4]);
    }
 
  % write ar
  ar = sock->send_bit_get_str_ar (SRV_FD, 0);
  variable
    colors = sock->send_bit_get_int_ar (SRV_FD, 0),
    rows = sock->send_bit_get_int_ar (SRV_FD, 0),
    cols = sock->send_bit_get_int_ar (SRV_FD, 0);

  array_map (Void_Type, &f_write, ar, colors, rows, cols);

  % write infoline
  variable
    str = sock->send_bit_get_str (SRV_FD, 0);

  ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  f_write (str, ar[0], ar[1], ar[2]);

  % pos
  ar = sock->send_bit_get_int_ar (SRV_FD, 0);
  slsmg_gotorc (ar[0], ar[1]);

  sock->send_bit (SRV_FD, 0);
}

funcs["draw_frame"] = &draw_frame;

private define get_color ()
{
  variable color = sock->send_bit_get_str (SRV_FD, 0);
  sock->send_int (SRV_FD, get_struct_field (COLOR, color));
}

funcs["get_color"] = &get_color;

private define char_at ()
{
  sock->send_int (SRV_FD, slsmg_char_at ());
}

funcs["char_at"] = &char_at;

private define erase_eol_at ()
{
  variable ar = sock->send_bit_get_int_ar (SRV_FD, 0);
  f_erase_eol_at (ar[0], ar[1]);
  sock->send_bit (SRV_FD, 0);
}

funcs["erase_eol_at"] = &erase_eol_at;

private define erase_eol_at_bg ()
{
  variable
    oldrow = slsmg_get_row (),
    oldcol = slsmg_get_column (),
    ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  f_erase_eol_at (ar[0], ar[1]);
  slsmg_gotorc (oldrow, oldcol);
  sock->send_bit (SRV_FD, 0);
}

funcs["erase_eol_at_bg"] = &erase_eol_at_bg;

private define set_color_in_region ()
{
  variable ar = sock->send_bit_get_int_ar (SRV_FD, 0);
  slsmg_set_color_in_region (ar[0], ar[1], ar[2], ar[3], ar[4]);
  sock->send_bit (SRV_FD, 0);
}

funcs["set_color_in_region"] = &set_color_in_region;

private define quit ()
{
  slsmg_reset_smg ();
  sock->send_bit (SRV_FD, 0);
  exit (0);
}

funcs["quit"] = &quit;

private define cls ()
{
  slsmg_cls ();
  sock->send_bit (SRV_FD, 0);
}

funcs["cls"] = &cls;

define main ()
{
  forever
    (@funcs[sock->get_str (SRV_FD)]);
}

variable s = socket (PF_UNIX, SOCK_STREAM, 0);
bind (s, SRV_SOCKADDR);
listen (s, 1);
SRV_FD = accept (s);

DEBUG = sock->send_bit_get_bit (SRV_FD, 0);

if (DEBUG)
  () = evalfile (sprintf ("%s/SlsmgSrv_dbg", path_dirname (__FILE__)), "srv");

main ();
