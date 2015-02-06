ineed ("json");

private variable
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

private define append (s, dec_str)
{
  _jump_ = _delim_ == s.jumpchar ? [_col_:_col_ + length (dec_str)] : Integer_Type[0];

  if (length (s.js.lines) - 1 < _linenr_)
    list_append (s.js.lines, {[_col_], [_color_], [encode_str (dec_str)], _jump_});
  else
    {
    s.js.lines[_linenr_][0] = [s.js.lines[_linenr_][0], _col_];
    s.js.lines[_linenr_][1] = [s.js.lines[_linenr_][1], _color_];
    s.js.lines[_linenr_][2] = [s.js.lines[_linenr_][2], encode_str (dec_str)];
    s.js.lines[_linenr_][3] = [s.js.lines[_linenr_][3], _jump_];
    }
 
  ifnot (qualifier_exists ("linksoff"))
    if (_delim_ == s.entrychar)
      {
      s.js.links[0] = [s.js.links[0], s.js.lines[-1][2][-1]];
      s.js.links[1] = [s.js.links[1], _linenr_];
      }

  _col_ += length (dec_str);
  _index_ = NULL == _cltok_ ? _index_ + length (dec_str) : _cltok_ + 1;
  _color_ = 1;
}

private define find_open_tok (s, index)
{
  _optok_ = wherefirst_eq (_buf_, '<', index);

  while (_optok_ && '\\' == _buf_[_optok_ - 1])
    _optok_ = wherefirst_eq (_buf_, '<', _optok_ + 1);
 
  while ((0 == _optok_ || _optok_) && 0 == any (s.delim == _buf_[_optok_ + 1]))
    _optok_ = wherefirst_eq (_buf_, '<', _optok_ + 1);
 
  ifnot (NULL == _optok_)
    _delim_ = _buf_[_optok_ + 1];
}

private define find_close_tok (s)
{
  _cltok_ = wherefirst_eq (_buf_, '>', _optok_ + 1);

  while (_cltok_ && 0 == (_delim_ == _buf_[_cltok_ - 1]))
    _cltok_ = wherefirst_eq (_buf_, '>', _cltok_ + 1);
}

private define parse_line ();

private define parse_line (s)
{
  _cltok_ = NULL;
  _optok_ = NULL;
  _delim_ = NULL;

  if (_index_ >= _len_)
    {
    ifnot (_len_)
      append (s, ['\n']);

    return;
    }
 
  find_open_tok (s, _col_);
  if (NULL == _optok_ || _optok_ == _len_)
    {
    _delim_ = NULL;
    append (s, _buf_[[_index_:]]);
    return;
    }

  find_close_tok (s);
  % TODO: what if ..<|word> |>" syntax err?
  if (NULL == _cltok_)
    {
    _delim_ = NULL;
    append (s, _buf_[[_index_:]]);
    return;
    }
 
  if (_optok_)
    append (s, _buf_[[_index_:_optok_ - 1]];linksoff);

  _color_ = s.delimcolor[char (_delim_)];
  append (s, _buf_[[_optok_+ 2:_cltok_ - 2]]);
 
  parse_line (s);
}

private define parse (s, file)
{
  variable spaces = "";

  ifnot (NULL == s.spaces)
    spaces = repeat (" ", s.spaces);

  variable fp = fopen (file, "r");

  if (NULL == fp)
    {
    list_append (s.msg, sprintf ("%s: can't open file, ERRNO: %s", file, errno_string (errno)));
    return NULL;
    }
 
  s.js.links = {String_Type[0], Integer_Type[0]};
  s.js.lines = {};
  
  _linenr_ = 0;

  while (-1 != fgets (&_buf_, fp))
    {
    _linenr_ ++;
    _col_ = 0;
    _color_ = 1;
    _index_ = 0;
    _len_ = 0;

    _buf_ = sprintf ("%s%s", spaces, strtrim_end (_buf_));

    decode_str ();

    parse_line (s);
    }

  ifnot (qualifier_exists ("dont_write_json"))
    writefile (json_encode (s.js), sprintf ("%s.json", file));

  return 0;
}

define init ()
{
  variable colors = Assoc_Type[Integer_Type];
  colors["|"] = 4;
  colors["*"] = 5;

  return struct
    {
    msg = {},
    delim = ['|', '$', '*'],
    jumpchar = '|',
    entrychar = '*',
    delimcolor = colors,
    spaces = 4,
    js = struct
      {
      lines,
      links,
      },
    parse = &parse,
    };
}
