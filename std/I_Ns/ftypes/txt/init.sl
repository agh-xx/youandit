ineed ("json");
ineed ("edViInitFuncs");

private variable
  _i_,
  __i__,
  _buf_,
  _len_,
  _index_,
  _linenr_;

private define append (dec_str)
{
  list_append (s_.js_._lines, {[_linenr_], [encode_str (dec_str)], [0], [0]});
}

private define parse_line ()
{
  if (_index_ >= _len_)
    {
    ifnot (_len_)
      append ([0]);

    return;
    }
  
 append (_buf_); 
}

private define parseline (self, line, linenr)
{
  variable indent = repeat (" ", s_._indent);
  _buf_ = sprintf ("%s%s", indent, line);
  _linenr_ = linenr;
  _index_ = 0;
  _len_ = 0;

  s_.js_._lines[_linenr_][0] = Integer_Type[0];
  s_.js_._lines[_linenr_][1] = String_Type[0];

  parse_line ();
}

private define parsefile (self)
{
  variable indent = repeat (" ", s_._indent);

  s_.js_._lines = {};
 
  _linenr_ = -1;

  s_._fnfp = fopen (s_._fname, "r");
  while (-1 != fgets (&_buf_, s_._fnfp))
    {
    _linenr_ ++;
    _index_ = 0;
    _len_ = 0;

    _buf_ = sprintf ("%s%s", indent, strtrim_end (_buf_));

    decode_str (&_buf_, &_len_);

    parse_line ();
    }

  () = fclose (s_._fnfp);

  return 0;
}

private define parsearray (self, ar)
{
  variable
    i,
    indent = repeat (" ", s_._indent);

  s_.js_._lines = {};
 
  _linenr_ = -1;

  _for i (0, length (ar) - 1)
    {
    _linenr_ ++;
    _index_ = 0;
    _len_ = 0;

    _buf_ = sprintf ("%s%s", indent, ar[i]);

    decode_str (&_buf_, &_len_);

    parse_line ();
    }

  return 0;
}

define init (self)
{
  variable s = struct
    {
    @self,
    _indent = 4,
    _maxlen = COLUMNS - 4,
    };
 
  s.parseline = &parseline;
  s.parsearray = &parsearray;
  s.parsefile = &parsefile;

  return s;
}
