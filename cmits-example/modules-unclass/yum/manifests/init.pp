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
# \section{YUM (Yellowdog Updater, Modified)}
#
# GPG signatures are not checked on package install during kickstart, but they
# are checked weekly after that (see~\S\ref{module_rpm}). The mitigation is
# that the kickstart network is more trusted than the production network.
# See~\S\ref{Kickstarting}.
#
# \subsection{Admin guidance about yum}
#
# \doneby{admins}{unixsrg}{GEN008800}%
# Do not deploy any YUM repository configuration with \verb!gpgcheck=0!. Do
# sign packages. See~\S\ref{Packaging}.
