ineed ("json");

private variable
  s_,
  _i_,
  __i__,
  _index_,
  _linenr_,
  _buf_,
  _len_,
  _dec_,
  _list_;

private define decode_str ()
{
  _list_ = {};
  _i_ = 0;

  forever
    {
    (_i_, _dec_) = strskipchar (_buf_, _i_);
    if (_dec_)
      list_append (_list_, _dec_);
    else
      break;

    _len_ ++;
    }

  _buf_ =  length (_list_) ? list_to_array (_list_) : ['\n'];
}

private define encode_str (dec_str)
{
  return strjoin (array_map (String_Type, &sprintf, "%c", dec_str));
}

private define append (dec_str)
{
    list_append (s_.js_._lines, {[_linenr_], [encode_str (dec_str)]});
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
  s_ = self;

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

    decode_str ();

    parse_line ();
    }

  () = fclose (s_._fnfp);

  return 0;
}

private define parsearray (self, ar)
{
  s_ = self;

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

    decode_str ();

    parse_line ();
    }

  return 0;
}

define init (self)
{
  variable s_ = struct
    {
    @self,
    _indent = 4,
    _maxlen = COLUMNS - 4,
    };
 
  s_.parseline = &parseline;
  s_.parsearray = &parsearray;
  s_.parsefile = &parsefile;

  return s_;
}
