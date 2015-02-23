ineed ("json");

private variable
  s_,
  _i_,
  __i__,
  _index_,
  _linenr_,
  _col_,
  _buf_,
  _len_,
  _color_,
  _dec_,
  _list_,
  _delim_,
  _optok_,
  _cltok_,
  _jump_,
  _entry_;

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
  _jump_ = _delim_ == s_._jumpchar
    ? [_col_:_col_ + length (dec_str)]
    : Integer_Type[0];

  if (length (s_.js_._lines) - 1 < _linenr_)
    list_append (s_.js_._lines, {[_linenr_], [_col_],
        [_color_], [encode_str (dec_str)], _jump_});
  else
    {
    s_.js_._lines[_linenr_][0] = [s_.js_._lines[_linenr_][0], _linenr_];
    s_.js_._lines[_linenr_][1] = [s_.js_._lines[_linenr_][1], _col_];
    s_.js_._lines[_linenr_][2] = [s_.js_._lines[_linenr_][2], _color_];
    s_.js_._lines[_linenr_][3] = [s_.js_._lines[_linenr_][3], encode_str (dec_str)];
    s_.js_._lines[_linenr_][4] = [s_.js_._lines[_linenr_][4], _jump_];
    }
 
  ifnot (qualifier_exists ("linksoff"))
    if (_delim_ == s_._entrychar)
      {
      s_.js_._links[0] = [s_.js_._links[0], s_.js_._lines[-1][3][-1]];
      s_.js_._links[1] = [s_.js_._links[1], _linenr_];
      }

  _col_ += length (dec_str);
  _index_ = NULL == _cltok_ ? _index_ + length (dec_str) : _cltok_ + 1;
  _color_ = 0;
}

private define find_open_tok (index)
{
  _optok_ = wherefirst_eq (_buf_, '<', index);

  while (_optok_ && '\\' == _buf_[_optok_ - 1])
    _optok_ = wherefirst_eq (_buf_, '<', _optok_ + 1);
 
  while ((0 == _optok_ || _optok_) && 0 == any (s_.dlm == _buf_[_optok_ + 1]))
    _optok_ = wherefirst_eq (_buf_, '<', _optok_ + 1);
 
  ifnot (NULL == _optok_)
    _delim_ = _buf_[_optok_ + 1];
}

private define find_close_tok ()
{
  _cltok_ = wherefirst_eq (_buf_, '>', _optok_ + 1);

  while (_cltok_ && 0 == (_delim_ == _buf_[_cltok_ - 1]))
    _cltok_ = wherefirst_eq (_buf_, '>', _cltok_ + 1);
}

private define parse_line ();
private define parse_line ()
{
  _cltok_ = NULL;
  _optok_ = NULL;
  _delim_ = NULL;

  if (_index_ >= _len_)
    {
    ifnot (_len_)
      append ([0]);

    return;
    }
 
  find_open_tok (_col_);
  if (NULL == _optok_ || _optok_ == _len_)
    {
    _delim_ = NULL;
    append (_buf_[[_index_:]]);
    return;
    }

  find_close_tok ();
  % TODO: what if ..<|word> |>" syntax err?
  if (NULL == _cltok_)
    {
    _delim_ = NULL;
    append (_buf_[[_index_:]]);
    return;
    }
 
  if (_optok_)
    append (_buf_[[_index_:_optok_ - 1]];linksoff);

  _color_ = s_.dlmcolor[char (_delim_)];
  append (_buf_[[_optok_+ 2:_cltok_ - 2]]);
 
  parse_line ();
}

private define parseline (self, line, linenr)
{
  variable indent = repeat (" ", s_._indent);
  _buf_ = sprintf ("%s%s", indent, line);
  _linenr_ = linenr;
  _col_ = 0;
  _color_ = 0;
  _index_ = 0;
  _len_ = 0;
  s_.js_._lines[_linenr_][0] = Integer_Type[0];
  s_.js_._lines[_linenr_][1] = Integer_Type[0];
  s_.js_._lines[_linenr_][2] = Integer_Type[0];
  s_.js_._lines[_linenr_][3] = String_Type[0];
  s_.js_._lines[_linenr_][4] = Integer_Type[0];

  parse_line ();
}

private define parsefile (self)
{
  s_ = self;

  variable indent = repeat (" ", s_._indent);

  s_.js_._links = {String_Type[0], Integer_Type[0]};
  s_.js_._lines = {};
 
  _linenr_ = -1;

  s_._fnfp = fopen (s_._fname, "r");
  while (-1 != fgets (&_buf_, s_._fnfp))
    {
    _linenr_ ++;
    _col_ = 0;
    _color_ = 0;
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

  s_.js_._links = {String_Type[0], Integer_Type[0]};
  s_.js_._lines = {};
 
  _linenr_ = -1;

  _for i (0, length (ar) - 1)
    {
    _linenr_ ++;
    _col_ = 0;
    _color_ = 0;
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
    js_ = struct
      {
      _lines,
      _links,
      },
    _jumpchar = '|',
    _entrychar = '*',
    dlmcolor = Assoc_Type[Integer_Type],
    dlm = ['|', '$', '*'],
    _indent = 4,
    _maxlen = COLUMNS - 4,
    };
 
  s_.parseline = &parseline;
  s_.parsearray = &parsearray;
  s_.parsefile = &parsefile;,

  s_.dlmcolor["|"] = 4;
  s_.dlmcolor["*"] = 5;
 
  return s_;
}
