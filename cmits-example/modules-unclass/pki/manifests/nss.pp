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
# \subsection{NSS and FIPS}
# \label{nss_fips}
#
# Each NSS database has a FIPS-compliance switch, which can be on or off. The
# most visible effect of FIPS compliance is that a passphrase is required
# before any cryptographical work can be done using the contents of the NSS
# database. Some programs (e.g., Apache with \verb!mod_nss!) have their own
# FIPS compliance setting, which may use the database in FIPS mode even if its
# FIPS setting is off.
#
# In order for the FIPS mode to work, a passphrase must be set. The above
# defined resource type does not set a passphrase, so any freshly made database
# will be unusable in FIPS mode.
#
# To make it usable:
# \begin{enumerate}
# \item Turn off FIPS mode if necessary: {\tt modutil -fips false -dbdir
# \emph{directory}}.
# \item Set a passphrase on it: {\tt modutil -changepw "NSS Certificate DB"
# -dbdir \emph{directory}}.
# \item Turn on FIPS mode if necessary: {\tt modutil -fips true -dbdir
# \emph{directory}}.
# \item You will need to type that passphrase every time you start the server.
# \item Do not write the passphrase in a file. This would enable services that
# need to use NSS for encryption, like Apache with \verb!mod_nss!, to do so
# without prompting for the passphrase. It would also enable a remote attacker
# who compromised such a service to get at the private keys immediately,
# without needing to brute-force the passphrase. 
# \item Such a file has the following format: Each line of the file should look
# like {\tt \emph{module}:\emph{password}}. The modules of interest are
# ``internal'', ``NSS Certificate DB'' and
# ``NSS FIPS 140-2 Certificate DB''.
# \end{enumerate}
#
# \doneby{admins}{unixsrg}{GEN000740}%
# You should change the passphrase at least once every year, because it's
# analogous to a non-interactive account password.
#
#
#
# % No Puppet code is in this file.
