define main (self, stdout_file, stderr_file)
{

  self.pid = fork ();

  variable
    env = [
       sprintf ("HOME=%s", getenv ("HOME")),
       sprintf ("TERM=%s", getenv ("TERM")),
       sprintf ("DISPLAY=%S", getenv ("DISPLAY"))],
%    stdinw = open ("/tmp/c",   O_WRONLY|O_CREAT|O_NOCTTY,          S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH),
    stderrw = open (stderr_file, O_WRONLY|O_APPEND|O_CREAT|O_NOCTTY, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH),
    stdoutw = open (stdout_file, O_WRONLY|O_APPEND|O_CREAT|O_NOCTTY, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH);

%  self.fd_fifo = open (self.fifo, O_WRONLY);
  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);
%  () = dup2_fd (stdinw, 0);
%  () = dup2_fd (self.fd_fifo, 0);

  stdoutw = @FD_Type (1);
  stderrw = @FD_Type (2);
%  stdinw = @FD_Type (0);

  if ((0 == self.pid) && -1 == execve (self.argv[0], self.argv, env))
    return -1;

  return 0;
}
