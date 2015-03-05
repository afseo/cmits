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
require 'rspec-puppet'
require 'pathname'
dir = Pathname.new(__FILE__).parent

# grab the mac_plist_* types and the unimplemented function
# thanks to Dominic Cleal for this workaround
$LOAD_PATH.unshift(dir,
                   File.join(dir, '..', '..', 'mac_plist_value', 'lib'),
                   File.join(dir, '..', '..', 'unimplemented', 'lib'))

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end

