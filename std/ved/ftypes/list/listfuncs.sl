variable frame = 1;

private variable
  frames = Frame_Type[2],
  LINES = get_lines ();

frames[0] = @Frame_Type;
frames[1] = @Frame_Type;

private define togglecur ()
{
  frame = frame ? 0 : 1;
  cw_ = frames[frame];
}

private define init (s)
{
  frames[1].rows = [LINES - 8:LINES - 2];
  frames[0].rows = [1:LINES - 9];

  variable len = length (frames[1].rows);

  frames[1].ptr = Integer_Type[2];
  frames[1].cols = Integer_Type[len];
  frames[1].cols[*] = 0;
  frames[1].clrs = Integer_Type[len];
  frames[1].clrs[*] = 0;
  frames[1].clrs[-1] = INFOCLRFG;
  frames[1]._avlins = length (len) - 1;
  frames[1]._maxlen = COLUMNS;
  frames[1].state = List_Type[len];
  frames[1].ptr[0] = frames[1].rows[0];
  frames[1].ptr[1] = 0;
  frames[1]._i = 0;
 
  len = length (frames[0].rows);  

  frames[0].cols = Integer_Type[len];
  frames[0].cols[*] = 0;
  frames[0].clrs = Integer_Type[len];
  frames[0].clrs[*] = 0;
  frames[0].clrs[-1] = INFOCLRFG;
  frames[0]._avlins = len - 1;
  frames[0].state = List_Type[len];
  frames[0]._indent = 0;
  frames[0]._maxlen = COLUMNS;
  frames[0].ptr = Integer_Type[2];
  frames[0].ptr[0] = frames[0].rows[0];
  frames[0].ptr[1] = 0;
  frames[0]._i = 0;
}

private define getitem ()
{
  variable
    line = v_lin ('.'),
    tok = strchop (line, '|', 0),
    col = atoi (strtok (tok[1])[2]),
    lnr = atoi (strtok (tok[1])[0]),
    fname = sprintf ("%s/%s", getcwd (), tok[0]);

  if (-1 == access (fname, F_OK))
    {
    () = fprintf (stderr, "%s: No such filename", fname);
    return NULL;
    }

  return struct {lnr = lnr, col = col, fname = fname};
}

private define drawfile ()
{
  variable l = getitem ();
  
  if (NULL == l)
    return;
  
  togglecur ();

  cw_.lines = readfile (l.fname);
  cw_._len = length (frames[0].lines) - 1;
  cw_._fname = l.fname;
  cw_._i = cw_._len >= l.lnr ? l.lnr - 1 : 0;
  cw_.ptr[0] = 1;
  cw_.ptr[1] = l.col - 1;
  s_.draw ();
}

private define chframe ()
{
  togglecur ();
  srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
}

pf[string ('\r')] = &drawfile;
pf[string (keys->CTRL_w)] = &chframe;

pk = array_map (Integer_Type, &integer, assoc_get_keys (pf));

define ved (s)
{
  cw_ = frames[1];

  cw_._fname = get_file ();

  cw_._indent = 0;
  cw_.lines = s_.getlines ();
  cw_._len = length (cw_.lines) - 1;

  init (s);
  
  clear (1, LINES);

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

