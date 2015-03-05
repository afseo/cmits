# --- BEGIN DISCLAIMER ---
# Those who use this do so at their own risk;
# AFSEO does not provide maintenance nor support.
# --- END DISCLAIMER ---
# --- BEGIN AFSEO_DATA_RIGHTS ---
# This is a work of the U.S. Government and is placed
# into the public domain in accordance with 17 USC Sec.
# 105. Those who redistribute or derive from this work
# are requested to include a reference to the original,
# at <https://github.com/afseo/cmits>, for example by
# including this notice in its entirety in derived works.
# --- END AFSEO_DATA_RIGHTS ---
Facter.add("broadcast") do
    confine :kernel => :Linux
    setcode do
        my_ip_regex = Regexp.new(Regexp.escape("inet #{Facter.ipaddress}"))
        output = Facter::Util::Resolution.exec('/sbin/ip a')
        if output.nil?
            nil
        else
            lines = output.split("\n")
            rv = nil
            lines.grep(my_ip_regex).each do |bline|
                words = bline.split(' ')
                rv = words[3] if words[2] == 'brd'
            end
            rv
        end
    end
end
