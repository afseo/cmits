# % --- BEGIN DISCLAIMER ---
# % Those who use this do so at their own risk;
# % AFSEO does not provide maintenance nor support.
# % --- END DISCLAIMER ---
# % --- BEGIN AFSEO_DATA_RIGHTS ---
# % This is a work of the U.S. Government and is placed
# % into the public domain in accordance with 17 USC Sec.
# % 105. Those who redistribute or derive from this work
# % are requested to include a reference to the original,
# % at <https://github.com/afseo/cmits>, for example by
# % including this notice in its entirety in derived works.
# % --- END AFSEO_DATA_RIGHTS ---
# \section{Common packages}
#
# You only get to declare a package once in the whole manifest. But
# some packages are depended on by many modules. According to a
# googling done in Fall 2013, options for this are:
#
# \begin{enumerate}
# \item Surround every package resource with
# \verb+if # !defined(Package[bla]) {...}+.
# \item Write every possible package resource as a virtual resource in
# one place; realize packages where they are needed.
# \item Wherever class A and class B both want to install package X,
# write a new class C that installs package X, and make A and B depend
# on C.
# \end{enumerate}
#
# Here we implement the third approach.
