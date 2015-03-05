cmits-example.pdf
-----------------

This is the unified policy document built from the CMITS example policy. It
collects all of the human-written documentation (in the example policy, there
isn't much of this), the Puppet manifest with its embedded documentation, and
auto-summaries into one document suitable for saving in a fireproof box or
handing to an auditor.


texmf.zip
---------

All you need to install the iadoc and iacic LaTeX packages under Windows with
MiKTeX. These packages are necessary if you want to build your own unified
policy document out of your own CMITS-based policy. To use, unzip somewhere,
and then register the resultant texmf folder as a user-managed TEXMF directory
(see <http://docs.miktex.org/manual/localadditions.html>).


shaney-1.5-py2.6.egg
--------------------

The code, written in Python, which does all the automatic parts of generating
the unified policy document.

shaney-1.5.win32.exe
--------------------

The Windows installer for the same code. Must be run after the Python 2.6.x or
2.7.x installer.
