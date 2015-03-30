variable
  count = 0,
  pf = Assoc_Type[Ref_Type];

ineed ("vedfuncs");
ineed ("viewer");
ineed ("rline");
ineed ("search");

variable pk = array_map (Integer_Type, &integer, assoc_get_keys (pf));

define ved (s)
{
  cw_ = @Frame_Type;
  
  cw_._maxlen = COLUMNS;
  cw_._indent = 0;
  cw_._fname = get_file ();
  cw_.rows =  get_rows ();
  cw_.lines = s_.getlines ();
  
  cw_.ptr = Integer_Type[2];

  write_prompt (" ", 0);
  cw_._len = length (cw_.lines) - 1;
  cw_.cols = Integer_Type[length (cw_.rows)];
  cw_.cols[*] = 0;
  cw_.clrs = Integer_Type[length (cw_.rows)];
  cw_.clrs[*] = 0;
  cw_.clrs[-1] = INFOCLRFG;
  cw_._avlins = length (cw_.rows) - 2;
  cw_.state = List_Type[length (cw_.rows)];
  cw_.ptr[0] = cw_.rows[0];
  cw_.ptr[1] = 0;

  cw_._i = 0;

  s.draw ();

  variable func = get_func ();
  if (func)
    {
    count = get_count ();
    if (any (pk == func))
      (@pf[string (func)]);
    }

  if (DRAWONLY)
    return;
  
  forever
    {
    count = -1;
    cw_._chr = get_char ();
    
    if ('0' <= cw_._chr <= '9')
      {
      count = "";
      
      while ('0' <= cw_._chr <= '9')
        {
        count += char (cw_._chr);
        cw_._chr = get_char ();
        }

      count = integer (count);
      }

    if (any (pk == cw_._chr))
      (@pf[string (cw_._chr)]);
    
    if (cw_._chr == 'q')
      break;
    }
}
