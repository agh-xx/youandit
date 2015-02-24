private variable
  _list_,
  _dec_,
  _i_;

define decode_str (buf, len)
{
  _list_ = {};
  _i_ = 0;

  forever
    {
    (_i_, _dec_) = strskipchar (@buf, _i_);
    if (_dec_)
      list_append (_list_, _dec_);
    else
      break;

    @len++;
    }

  @buf = length (_list_) ? list_to_array (_list_) : ['\n'];
}

define encode_str (dec_str)
{
  return strjoin (array_map (String_Type, &sprintf, "%c", dec_str));
}
