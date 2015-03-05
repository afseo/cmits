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
# \subsection{Pylons In SEEK EAGLE (PISE)}
#
# RHEL 6 includes Pylons 1.0, and the many other Python packages which it
# requires and uses. It appears that this forms a good foundation for building
# new web applications in Python, where `good' means these things:
#
# \begin{itemize}
# \item Supported with security updates
# \item Easy to install on RHEL 6
# \item Already works for lots of people in the industry
# \item Good documentation is available
# \item Training may be available
# \item Short write--manual test--modify cycle
# \item It's easy to write and run unit and functional tests
# \item Debuggable (\emph{i.e.}, runnable using a debugger)
# \item Deployment is well-defined
# \item Authentication methods can be changed
# \end{itemize}
#
# ``Pylons'' is mostly a collective term for many pieces which are bound
# together into a platform on which to write a web application. PISE denotes
# all the conventions, common pieces of configuration, and procedures involved
# in making and deploying Pylons applications under this \CMITSPolicy .
#
# Colophon: a \emph{pylon} is the entrance to an Egyptian temple. \emph{Pis\'e
# de terre} (pee-ZAY deuh TAIR) is a technique of building walls or large
# bricks using rammed earth.
