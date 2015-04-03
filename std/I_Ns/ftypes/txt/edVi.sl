variable
  pf = Assoc_Type[Ref_Type],
  com,
  cf = Assoc_Type[Ref_Type],
  w_ = s_.w_,
  _chr_;

w_._avlins = LINES - 4;

define draw ();

ineed ("edViFuncs");
ineed ("viewer");
ineed ("edit");

variable pk = array_map (Integer_Type, &integer, assoc_get_keys (pf));

ineed ("f_");
ineed ("rline");
ineed ("cline");

define draw ()
{
  if (-1 == w_._len)
    {
    srv->write_ar_dr ([repeat (" ", COLUMNS), tail ()], [0, 0], [2, LINES - 1], [0],
      [w_.ptr[0], w_.ptr[1]]);
    return;
    }

  w_.lnrs = LLong_Type[0];
  w_.lins = String_Type[0];

  variable
    i = 2,
    ar = String_Type[0];
 
  w_._ii = w_._i;

  while (w_._i <= w_._len && i <= w_._avlins)
    {
    w_.lnrs = [w_.lnrs, s_.p_.lnrs[w_._i]];
    w_.lins = [w_.lins, s_.p_.lins[w_._i]];
    w_._i++;
    i++;
    }

  w_.vlins = [2:length (w_.lins) - 1 + 2];

  w_._i = w_._i - (i) + 2;

  if (-1 == w_._i)
    w_._i = 0;

  if (w_.ptr[0] >= i)
    w_.ptr[0] = i - 1;

  ar = [array_map (String_Type, &substr, w_.lins, 1, s_._maxlen), tail ()];

  variable
    cols = Integer_Type[length (ar)] + 1,
    clrs = Integer_Type[length (ar)] + 1;

  cols[*] = 0;
  clrs[*] = 0;

  srv->draw_wind (ar, clrs, [w_.vlins, LINES - 1], cols, [w_.ptr[0], w_.ptr[1]]);
 
  w_.state = List_Type[length (w_.vlins)];

  _for i (0, length (w_.vlins) - 1)
    w_.state[i] = {[ar[i]], [clrs[i]], [w_.vlins[i]], [cols]};
}

define edVi (self)
{
  w_._len = length (s_.p_.lins) - 1;

  w_.ptr[0] = 2;
  w_.ptr[1] = s_._indent;

  w_._i = 0;

  draw ();
  draw_head ();

  _chr_ = get_ans ();

  srv->write_ar_dr ([repeat (" ", COLUMNS), repeat (" ", COLUMNS)], [0, 0], [0, 1],
    [0, 0], [w_.ptr[0], w_.ptr[1]]);

  forever
    {
    if (any (pk == _chr_))
      (@pf[string (_chr_)]);

    if (_chr_ == ':')
      rl_.read ();
 
    send_ans (RLINE_GETCH);
    _chr_ = get_ans ();
    }
}
