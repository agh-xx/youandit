define modetoint (mode)
{
  variable
    S_ISUID = 04000,    % Set user ID on execution
    S_ISGID = 02000,    % Set group ID on execution
    S_ISVTX = 01000,    % Save swapped text after use (sticky)
    CHMOD_MODE_BITS =  (S_ISUID|S_ISGID|S_ISVTX|S_IRWXU|S_IRWXG|S_IRWXO);

  return atoi (sprintf ("%d", mode & CHMOD_MODE_BITS));

  % the following code stays here as a convertion example
  % variable m = 0;
  % oct = sprintf ("%o", mode & CHMOD_MODE_BITS);

  % oct = 3 == strlen (oct) ? "0" + oct : oct;

  % % code from gnu-coreutils
  % _for i (0,3)
  %   {
  %   chr = oct[i];
  %   m = 8 * m + chr - '0';
  %   }

  % return m;
}
