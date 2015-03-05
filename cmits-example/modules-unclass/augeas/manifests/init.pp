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
# \section{Augeas config file editor}
# \label{augeas}
#
# Many parts of this policy use the Augeas system for editing all sorts of
# configuration files. Make sure it's properly installed.

class augeas {

# We would normally just need to ensure that ruby-augeas is present; but 0.4.1
# has some changes that are important for us in this Puppet manifest. And you
# have to specify an entire version, I think. But the entire version, with
# release number, varies between OS releases. Ergo, this big long nest of curly
# braces:
    case $osfamily {
        RedHat: {
            package { "augeas":
                ensure => present,
            }
            case $operatingsystemrelease {
                /^6\..*/: {
                    package { "ruby-augeas":
                        ensure => '0.4.1-1.el6',
                    }
                }
                /^5\..*/: {
                    package { "apscl-rubygem-ruby-augeas":
                        ensure => '0.5.0-6',
                    }
                }
                default: { unimplemented() }
            }
        }
        'Darwin': {
            case $::macosx_productversion_major {
                '10.6': {
                    mac_package { 'libxml2-2.9.0-1.pkg': } ->
                    mac_package { 'augeas-1.0.0-1.pkg': } ->
                    mac_package { 'ruby-augeas-0.4.1-1.pkg': }
                }
                '10.9': { warning 'augeas install unimplemented on mavericks' }
                default: { unimplemented() }
            }
        }
    }


    $lenses_dir = $::osfamily ? {
        'RedHat' => '/usr/share/augeas/lenses',
        'Darwin' => $::macosx_productversion_major ? {
            '10.9'  => '/usr/share/augeas/lenses',
            '10.6'  => '/usr/local/share/augeas/lenses',
        },
    }

    $lenses_source = $::augeasversion ? {
        '0.9.0' => 'puppet:///modules/augeas/0.9.0/lenses',
        '1.0.0' => 'puppet:///modules/augeas/1.0.0/lenses',
        '1.2.0' => 'puppet:///modules/augeas/1.2.0/lenses',
        '' => '',
    }

# Install our custom Augeas lenses.
    if $lenses_source != '' {
        file { $lenses_dir:
            source => $lenses_source,
            ignore => ".svn",
            recurse => true, recurselimit => 1,
            owner => root, group => 0, mode => 0644,
        }

# Remove the ones which are no longer valid. (We can't make the copy remove
# unknown files because the Augeas lenses distributed in the Augeas package are
# also under that directory.)
        file { [
            "${lenses_dir}/logindefs.aug",
            "${lenses_dir}/tcp_wrappers.aug",
            "${lenses_dir}/ssh_config.aug",
            ]:
                ensure => absent,
        }
    }

# Remove lenses no longer valid specifically for Augeas version 1.0.0.
    if $::augeasversion =~ /1\..*/ {
        file { [
# Auditdconf has been superseded by the distributed Simplevars.
            "${lenses_dir}/auditdconf.aug",
            "${lenses_dir}/someautomountmaps.aug",
            ]:
                ensure => absent,
        }
    }
}
