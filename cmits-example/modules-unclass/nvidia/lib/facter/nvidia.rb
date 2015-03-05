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
require 'find'
#
# See
# https://afseo.eglin.af.mil/projects/admin/browser/branches/production/cf/modules/module:nvidia
# for how to also detect legacy nVidia cards.
#

NVIDIA_PCI_VENDOR_ID = "0x10de"
VIDEO_CARD_CLASS = "0x030000"
PCI_DEVICES = '/sys/bus/pci/devices'

def nvidia_graphics_card_device_dirs
    Dir.glob(File.join(PCI_DEVICES,'*')).select do |device_dir|
        vendor = File.read(File.join(device_dir, 'vendor')).strip
        class_ = File.read(File.join(device_dir, 'class')).strip
        vendor == NVIDIA_PCI_VENDOR_ID and class_ == VIDEO_CARD_CLASS
    end
end

Facter.add("has_nvidia_graphics_card") do
    confine :kernel => "Linux"
    setcode do
        nvidia_graphics_card_device_dirs.any?
    end
end

Facter.add("has_nvidia_legacy_304_graphics_card") do
    confine :kernel => "Linux"
    setcode do
        # list is at http://www.nvidia.com/object/IO_32667.html
        legacy_304_product_ids = %w{0x0040 0x0041 0x0042 0x0043 0x0044 0x0045 0x0046 0x0047 0x0048 0x004e 0x0090 0x0091 0x0092 0x0093 0x0095 0x0098 0x0099 0x009d 0x00c0 0x00c1 0x00c2 0x00c3 0x00c8 0x00c9 0x00cc 0x00cd 0x00ce 0x00f1 0x00f2 0x00f3 0x00f4 0x00f5 0x00f6 0x00f8 0x00f9 0x0140 0x0141 0x0142 0x0143 0x0144 0x0145 0x0146 0x0147 0x0148 0x0149 0x014a 0x014c 0x014d 0x014e 0x014f 0x0160 0x0161 0x0162 0x0163 0x0164 0x0165 0x0166 0x0167 0x0168 0x0169 0x016a 0x01d0 0x01d1 0x01d2 0x01d3 0x01d6 0x01d7 0x01d8 0x01da 0x01db 0x01dc 0x01dd 0x01de 0x01df 0x0211 0x0212 0x0215 0x0218 0x0221 0x0222 0x0240 0x0241 0x0242 0x0244 0x0245 0x0247 0x0290 0x0291 0x0292 0x0293 0x0294 0x0295 0x0297 0x0298 0x0299 0x029a 0x029b 0x029c 0x029d 0x029e 0x029f 0x02e0 0x02e1 0x02e2 0x02e3 0x02e4 0x038b 0x0390 0x0391 0x0392 0x0393 0x0394 0x0395 0x0397 0x0398 0x0399 0x039c 0x039e 0x03d0 0x03d1 0x03d2 0x03d5 0x03d6 0x0531 0x0533 0x053a 0x053b 0x053e 0x07e0 0x07e1 0x07e2 0x07e3 0x07e5}
        installed_product_ids = nvidia_graphics_card_device_dirs.collect {|d|
            File.read(File.join(d, 'device')).strip
        }
        installed_product_ids.any? {|id| legacy_304_product_ids.member? id }
    end
end

Facter.add("has_nvidia_legacy_17314_graphics_card") do
    confine :kernel => "Linux"
    setcode do
        # list is at http://www.nvidia.com/object/IO_32667.html
        legacy_17314_product_ids = %w{0x00fa 0x00fb 0x00fc 0x00fd 0x00fe 0x0301 0x0302 0x0308 0x0309 0x0311 0x0312 0x0314 0x031a 0x031b 0x031c 0x0320 0x0321 0x0322 0x0323 0x0324 0x0325 0x0326 0x0327 0x0328 0x032a 0x032b 0x032c 0x032d 0x0330 0x0331 0x0332 0x0333 0x0334 0x0338 0x033f 0x0341 0x0342 0x0343 0x0344 0x0347 0x0348 0x034c 0x034e}
        installed_product_ids = nvidia_graphics_card_device_dirs.collect {|d|
            File.read(File.join(d, 'device')).strip
        }
        installed_product_ids.any? {|id| legacy_17314_product_ids.member? id }
    end
end


Facter.add("using_nouveau_driver") do
    confine :kernel => "Linux"
    setcode do
        drivers = nvidia_graphics_card_device_dirs.collect {|d|
            driver = File.join(d, 'driver')
            if File.exists?(driver)
                File.readlink(driver)
            else
                ''
            end
        }
        drivers.any? {|x| x.end_with? "/nouveau" }
    end
end

Facter.add("nvidia_ko_exists") do
    confine :kernel => "Linux"
    setcode do
        kernel_version = %x{uname -r}.strip
        ko = File.join('/lib', 'modules', kernel_version,
                       'kernel', 'drivers', 'video', 'nvidia.ko')
        File.exists?(ko)
    end
end

Facter.add("nvidia_libGL_installed") do
    confine :kernel => "Linux"
    setcode do
        oldcwd = Dir.pwd
        Dir.chdir('/usr/lib64')
        filename = 'libGL.so'
        seen = ['libGL.so']
        # Follow symlinks until we reach a loop, a non-symlink
        # (EINVAL), or a broken link (ENOENT); final destination will
        # be in filename.
        while true
          begin
            filename = File.readlink(filename)
            break if seen.include? filename
            seen << filename
          rescue Errno::EINVAL, Errno::ENOENT
            break
          end
        end
        Dir.chdir(oldcwd)
        # filename should now be something like 'libGL.so.319.23'
        # the oldest legacy driver we may have is 173.x
        if filename =~ /libGL\.so\.([0-9]+)(\.[0-9]+)*/
          major = $1
          major.to_i >= 150
        else
          # what is this thing pointing to? doesn't look right, better
          # reinstall the driver.
          false
        end
    end
end

Facter.add("nvidia_glx_extension_installed") do
    confine :kernel => "Linux"
    setcode do
        # stub
        # Something in /usr/lib{,64}/xorg.
        true
    end
end
