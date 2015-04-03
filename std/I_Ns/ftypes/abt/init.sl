ineed ("json");
ineed ("edViInitFuncs");

private variable
  _i_,
  __i__,
  _index_,
  _linenr_,
  _col_,
  _buf_,
  _len_,
  _color_,
  _delim_,
  _optok_,
  _cltok_,
  _jump_,
  _entry_;

private define append (p, dec_str)
{
  _jump_ = _delim_ == s_._jumpchar
    ? [_col_:_col_ + length (dec_str)]
    : Integer_Type[0];

  if (length (p.lins) - 1 < _linenr_)
    {
    list_append (p.lins, [encode_str (dec_str)]);
    list_append (p.cols, [_col_]);
    list_append (p.lnrs, [_linenr_]);
    list_append (p.clrs, [_color_]);
    }
  else
    {
    p.lins[-1] = [p.lins[-1], encode_str (dec_str)];
    p.cols[-1] = [p.cols[-1], _col_];
    p.lnrs[-1] = [p.lnrs[-1], _linenr_];
    p.clrs[-1] = [p.clrs[-1], _color_];
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
private define parse_line (p)
{
  _cltok_ = NULL;
  _optok_ = NULL;
  _delim_ = NULL;

  if (_index_ >= _len_)
    {
    ifnot (_len_)
      append (p, [0]);

    return;
    }
 
  find_open_tok (_col_);
  if (NULL == _optok_ || _optok_ == _len_)
    {
    _delim_ = NULL;
    append (p, _buf_[[_index_:]]);
    return;
    }

  find_close_tok ();
  % TODO: what if ..<|word> |>" syntax err?
  if (NULL == _cltok_)
    {
    _delim_ = NULL;
    append (p, _buf_[[_index_:]]);
    return;
    }
 
  if (_optok_)
    append (p, _buf_[[_index_:_optok_ - 1]];linksoff);

  _color_ = s_.dlmcolor[wherefirst_eq (s_.dlm, _delim_)];
  append (p, _buf_[[_optok_+ 2:_cltok_ - 2]]);
 
  parse_line (p);
}

private define parsefile (s)
{
  variable indent = repeat (" ", s_._indent);

  _linenr_ = -1;
 
  variable p = struct
    {
    lnrs = {},
    lins = {},
    cols = {},
    clrs = {}
    };

  s_._fnfp = fopen (s_._fname, "r");
  while (-1 != fgets (&_buf_, s_._fnfp))
    {
    _linenr_++;
    _col_ = 0;
    _color_ = 0;
    _index_ = 0;
    _len_ = 0;

    _buf_ = sprintf ("%s%s", indent, strtrim_end (_buf_));

    decode_str (&_buf_, &_len_);

    parse_line (p);
    }

  s_.p_ = p;

  () = fclose (s_._fnfp);
  return 0;
}

private define parsearray (s, ar)
{
  variable
    i,
    indent = repeat (" ", s_._indent);

  _linenr_ = -1;
 
  variable p = struct
    {
    lnrs = {},
    lins = {},
    cols = {},
    clrs = {}
    };

  _for i (0, length (ar) - 1)
    {
    _linenr_++;
    _col_ = 0;
    _color_ = 0;
    _index_ = 0;
    _len_ = 0;

    _buf_ = sprintf ("%s%s", indent, ar[i]);

    decode_str (&_buf_, &_len_);

    parse_line (p);
    }

  return p;
}

private define writeline (s, index)
{
  variable
    line = "";

  if (1 == length (s.p_.lins[index]))
    line = s.p_.lins[index][0];
  else
    {
    variable
      i = 0,
      dlm;

    while (i < length (s.p_.clrs[index]))
      {
      ifnot (s.p_.clrs[index][i])
        line += s.p_.lins[index][i];
      else
        {
        dlm = char (s.dlm[wherefirst_eq (s.dlmcolor, s.p_.clrs[index][i])]);
        line += "<" + dlm + s.p_.lins[index][i] + dlm + ">";
        }

      i++;
      }
    }

  line = substr (line, s._indent + 1, -1);
  () = fprintf (s._fnfp, "%s\n", line);
  () = fflush (s._fnfp);
}

define init (s)
{
  s = struct
    {
    @s,
    p_ = struct
      {
      lnrs = {},
      lins = {},
      cols = {},
      clrs = {},
      },
    _jumpchar = '|',
    _entrychar = '*',
    dlmcolor = [4, 5],
    dlm = ['|', '*'],
    _indent = 4,
    _maxlen = COLUMNS - 4,
    writeline = &writeline,
    };
 
  s.parsearray = &parsearray;
  s.parsefile = &parsefile;

  return s;
}
