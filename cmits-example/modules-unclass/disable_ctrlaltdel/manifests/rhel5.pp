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
class disable_ctrlaltdel::rhel5 {
    augeas { 'disable_ctrlaltdel':
        context => '/files/etc/inittab',
        changes => [
# Remove the comment before \verb!ca! as well as \verb!ca! itself.
            'rm #comment[following-sibling::*[1][self::ca]]',
            'rm ca',
        ],
        notify => Exec['reread_init'],
    }
    exec { 'reread_init':
        command => '/sbin/telinit q',
        refreshonly => true,
    }
}
