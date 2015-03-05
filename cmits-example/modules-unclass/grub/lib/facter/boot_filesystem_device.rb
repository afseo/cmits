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
Facter.add("boot_filesystem_device") do
  confine :kernel => "Linux"
  setcode do
    # http://stackoverflow.com/questions/7718411
    st = File.stat('/boot')
    expected = "#{st.dev_major}:#{st.dev_minor}\n"
    boot_devdir = Dir['/sys/class/block/*'].find do |devdir|
      File.read(File.join(devdir, 'dev')) == expected
    end
    dev_now = File.join('/dev', File.basename(boot_devdir))
    # Now, as per
    # https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/chap-Federal_Standards_and_Regulations.html
    # we should take care because the device name at the next boot may
    # be different than it is now: perhaps the drives were shuffled
    # around or some such. By getting and returning the filesystem
    # UUID instead, the kernel can locate the filesystem in the future
    # boot environment, no matter what device it may be on then.
    Facter::Util::Resolution.exec("/sbin/blkid -o export #{dev_now}").split("\n")[0]
  end
end

