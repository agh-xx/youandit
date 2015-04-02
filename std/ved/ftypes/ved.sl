ineed ("vedfuncs");
ineed ("viewer");
ineed ("search");
ineed ("rline");
ineed ("ed");

pagerc = array_map (Integer_Type, &integer, assoc_get_keys (pagerf));

%CHANGE
define set_img ()
{
  variable i;
  IMG = List_Type[PROMPTROW];
  _for i (1, length (IMG) - 1)
    IMG[i] = {" ", 0, i, 0};
  IMG[0] = {strftime ("%c"), 3, 0, 0};
}

set_img ();

define ved (s)
{
  cw_ = @Frame_Type;
  
  cw_._maxlen = COLUMNS;
  cw_._fname = get_file ();
  cw_.st_ = stat_file (cw_._fname);
  cw_.rows = get_rows ();
  cw_._indent = 0;
  cw_.lines = s_.getlines ();
  cw_._flags = 0;
  
  cw_.ptr = Integer_Type[2];

  write_prompt (" ", 0);
  cw_._len = length (cw_.lines) - 1;
  cw_.cols = Integer_Type[length (cw_.rows)];
  cw_.cols[*] = 0;
  cw_.clrs = Integer_Type[length (cw_.rows)];
  cw_.clrs[*] = 0;
  cw_.clrs[-1] = INFOCLRFG;
  cw_._avlins = length (cw_.rows) - 2;
  cw_.ptr[0] = cw_.rows[0];
  cw_.ptr[1] = 0;

  cw_._i = 0;

  s.draw ();

  variable func = get_func ();
  if (func)
    {
    count = get_count ();
    if (any (pagerc == func))
      (@pagerf[string (func)]);
    }

  if (DRAWONLY)
    return;
  
  forever
    {
    count = -1;
    cw_._chr = get_char ();
    
    if ('1' <= cw_._chr <= '9')
      {
      count = "";
      
      while ('0' <= cw_._chr <= '9')
        {
        count += char (cw_._chr);
        cw_._chr = get_char ();
        }

      count = integer (count);
      }

    if (any (pagerc == cw_._chr))
      (@pagerf[string (cw_._chr)]);
    
    if (':' == cw_._chr)
      rlf_.read ();

    if (cw_._chr == 'q')
      (@clinef["q"]) (;force);
    }
}
