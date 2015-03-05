module Test_upstartinit =
    let lns = Upstartinit.lns
    let script_line = Upstartinit.script_line
    let script = Upstartinit.script
    let lifecycle = Upstartinit.lifecycle
    let respawn = Upstartinit.respawn

    test lns get "\n" = {}
    test lns get "# bla\n" = { "#comment" = "bla" }
    test script_line get "end script\n" = *
    test script_line get "foo\n" = { "1" = "foo" }
    test script get "script\nend script\n" =  { "script" }
    test script get "script\nfoo\nend script\n" =  { "script" { "1" = "foo" } }
    test script get "script\n\nend script\n" = { "script" { "1" } }
    test script get "script\n\tfoo\nend script\n" = { "script" { "1" = "\tfoo" } }
    test lns get "script\nfoo\nbar\nend script\n" =
        { "script"
            { "1" = "foo" }
            { "2" = "bar" }
        }
    test lifecycle get "post-stop exec hi\n" =
        { "post-stop"
            { "exec" = "hi" }
        }
    test lns get "post-stop exec hi\n" =
        { "post-stop"
            { "exec" = "hi" }
        }
    test lns get "exec foo bar baz\n" = { "exec" = "foo bar baz" }
    
    test respawn get "respawn\n" = { "respawn" }
    test respawn get "respawn foo bar baz\n" = { "respawn" = "foo bar baz" }

    test lns get "# tty - getty
#
# This service maintains a getty on the specified device.

stop on runlevel [S016]

respawn
instance $TTY
exec /sbin/mingetty $TTY
usage 'tty TTY=/dev/ttyX  - where X is console id'
" = (
  { "#comment" = "tty - getty" }
  {  }
  { "#comment" = "This service maintains a getty on the specified device." }
  {  }
  { "stop" = "on runlevel [S016]" }
  {  }
  { "respawn" }
  { "instance" = "$TTY" }
  { "exec" = "/sbin/mingetty $TTY" }
  { "usage" = "'tty TTY=/dev/ttyX  - where X is console id'" }
)

(*
    test lns get "
# On machines where kexec isn't going to be used, free the memory reserved for it.

start on stopped rcS
task

script
	if [ ! -x /sbin/kexec ] || ! chkconfig kdump 2>/dev/null ; then
		echo -n \"0\" > /sys/kernel/kexec_crash_size 2>/dev/null
	fi
	exit 0
end script
" = 
(
  {  }
  { "#comment" = "On machines where kexec isn't going to be used, free the memory reserved for it." }
  {  }
  { "start" = "on stopped rcS" }
  { "task" }
  {  }
  { "script"
    { "1" = "   if [ ! -x /sbin/kexec ] || ! chkconfig kdump 2>/dev/null ; then" }
    { "2" = "           echo -n \"0\" > /sys/kernel/kexec_crash_size 2>/dev/null" }
    { "3" = "   fi" }
    { "4" = "   exit 0" }
  }
)

*)
