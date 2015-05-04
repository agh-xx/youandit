private variable colors = [
%functions
  14,
%conditional
  13,
%type
  12,
%errors
  17,
];

private variable regexps = [
%functions
  pcre_compile ("\
((evalfile(?=\s))\
|(?<!\w)(import(?=\s))\
|(?<!\w)(sigprocmask(?=\s))\
|(?<!\w)(\(\)(?=\s))\
|(?<!\w)(ineed(?=\s))\
|(?<!\w)(getlinestr(?=\s))\
|(?<!\w)(waddlineat(?=\s))\
|(?<!\w)(waddlineat_dr(?=\s))\
|(?<!\w)(waddlinear_dr(?=\s))\
|(?<!\w)(waddlinear(?=\s))\
|(?<!\w)(waddline(?=\s))\
|(?<!\w)(waddline_dr(?=\s)))+"R),
%conditional
  pcre_compile ("\
(((?<!\w)if(?=\s))\
|((?<!\w)ifnot(?=\s))\
|((?<!\w)else if(?=\s))\
|((?<!\w)else$)\
|((?<!\w)\{$)\
|((?<!\{)(?<!\w)\}(?=;))\
|((?<!\w)\}$)\
|((?<!\w)while(?=\s))\
|((?<!\w)loop$)\
|((?<!\w)switch(?=\s))\
|((?<!\w)case(?=\s))\
|((?<!\w)_for(?=\s))\
|((?<!\w)for(?=\s))\
|((?<!\w)foreach(?=\s))\
|((?<!\w)forever$)\
|((?<!\w)do$)\
|((?<!\w)then$)\
|((?<=\w)--(?=;))\
|((?<=\w)\+\+(?=;))\
|((?<!\w)\?(?=\s))\
|((?<!\w):(?=\s))\
|((?<!\w)\+(?=\s))\
|((?<!\w)-(?=\s))\
|((?<!\w)\*(?=\s))\
|((?<!\w)/(?=\s))\
|((?<!\w)mod(?=\s))\
|((?<!\w)\+=(?=\s))\
|((?<!\w)!=(?=\s))\
|((?<!\w)>=(?=\s))\
|((?<!\w)<=(?=\s))\
|((?<!\w)<(?=\s))\
|((?<!\w)>(?=\s))\
|((?<!\w)==(?=\s)))+"R),
%type
  pcre_compile ("\
(((?<!\w)define(?=\s))\
|(^\{$)\
|(^\}$)\
|((?<!\w)variable(?=[\s]*))\
|((?<!\w)private(?=\s))\
|((?<!\w)public(?=\s))\
|((?<!\w)static(?=\s))\
|((?<!\w)typedef struct$)\
|((?<!\w)struct(?=[\s]*))\
|((?<!\w)try(?=[\s]*))\
|((?<!\w)catch(?=\s))\
|((?<!\w)throw(?=\s))\
|((?<!\w)finally(?=\s))\
|((?<!\w)return(?=[\s;]))\
|((?<!\w)break(?=;))\
|((?<!\w)continue(?=;))\
|(NULL)\
|((?<!\w)[\w]+_Type(?=[\[;\]]))\
|((?<=\()[\w]+_Type(?=,))\
|((?<!\w)[\w]+Error(?=:)))+"R),
%errors
  pcre_compile ("\
((?<=\w)(\s+$))+"R),
];

private define sl_hl_groups (lines, vlines)
{
  variable
    i,
    ii,
    col,
    subs,
    match,
    color,
    regexp,
    context;
 
  _for i (0, length (lines) - 1)
    {
    _for ii (0, length (regexps) - 1)
      {
      color = colors[ii];
      regexp = regexps[ii];
      col = 0;

      while (subs = pcre_exec (regexp, lines[i], col), subs > 1)
        {
        match = pcre_nth_match (regexp, 1);
        col = match[0];
        context = match[1] - col;
        srv->set_color_in_region (color, vlines[i], col, 1, context);
        col += context;
        }
      }
    }
}

define sl_lexicalhl (lines, vlines)
{
  sl_hl_groups (lines, vlines);
}
