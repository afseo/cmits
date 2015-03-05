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
# \subsubsection{Creating self-signed certs in an NSS database}
#
# Imitating the \verb!nss_cert! custom resource type, the name of this resource
# is of the form \verb!dbdir:nickname!. This defined resource type will create
# a self-signed certificate in the name of the given subject, with the given
# nickname, if none exists in the database. The subject should not contain
# double-quotes, backslashes, or other such; PKIX standards do not impose these
# limitations but we do here.
#
# The noise file must be a file of length at least 2048 bytes, containing
# random bits. \verb!/dev/random! is such a file, but could take an hour or
# more to cough up the required bits. \verb!/dev/urandom! appears not to work.
# So, if you want your self-signed certificate to be generated in less than an
# hour, make your own file containing random bits, and provide it as the value
# of the \verb!noise_file! parameter.
#
# A password file called pwfile is required to be in the NSS directory being
# used in order for the certificate generation to work.

define pki::nss::self_signed(
        $subject="cn=${::fqdn}",
        $sqlite=true,
        $noise_file='/dev/random') {
    $pieces = split($name, ':')
    $dir  = $pieces[0]
    $nick = $pieces[1]
    $dbdir = $sqlite ? {
        true => "sql:${dir}",
        false => $dir,
    }
    case $noise_file {
        '/dev/random': {
            $timeout = 7200
            notify { '${name} slow cert warning':
                message => 'Generating this certificate could take hours.',
                loglevel => warning,
            }
        }
        default: {
            $timeout = 30
        }
    }
# Under virtual machine environments without mature means to pass host entropy
# to guest machines (I'm looking at you, VirtualBox circa 2013),
# \verb!/dev/random! is \emph{glacially slow}. NSS reads 2048 bytes from the
# given noise file; the entropy pool on a Vagrant virtual machine using
# VirtualBox fills at something like 5 bits per second. That's an hour or two
# to generate a certificate. So if security isn't a big priority---and if we're
# making a self-signed certificate it's not---any file with at least 2048 bytes
# of stuff in it will do.
    exec { "create_self_signed_${nick}_in_${dbdir}":
        command => "certutil -S -d ${dbdir} \
            -x -s \"${subject}\" -n \"${nick}\" \
            -t ,, -f ${dir}/pwfile -z ${noise_file}",
        unless => "certutil -L -d ${dbdir} -n \"${nick}\"",
        timeout => $timeout,
        require => [
            Pki::Nss::Db[$dir],
            Pki::Nss::Pwfile[$dir],
            ],
        path => ['/bin', '/usr/bin'],
    }
}
