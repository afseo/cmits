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
require 'spec_helper'

describe 'sudo::allow_group' do
  let(:title) { 'fungroup' }


  shared_context 'on any host' do
    it do
      should contain_file('/etc/sudoers.d/fungroup')
      should contain_augeas('remove_direct_sudoers_%fungroup')
      should contain_file('/etc/sudoers.d')
    end
  end

  context 'on a RHEL box' do
    include_context 'on any host'
    let(:facts) {{
        :osfamily => 'RedHat',
      }}
    it do
      should contain_augeas('consult_sudoers_d')
    end
  end

  context 'on a Darwin box' do
    include_context 'on any host'
    let(:facts) {{
        :osfamily => 'Darwin',
      }}
    it do
      should contain_augeas('sudoers_include_99_fungroup')
    end
  end
end
