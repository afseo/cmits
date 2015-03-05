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
require 'tmpdir'
require 'spec_helper'

describe 'sudo_user_1', :with_tmpdir => true do
  let(:sudoers_d) { '/etc/sudoers.d' }

  shared_examples_for "proper sudoers.d file creation" do
    it "should define the EDITORS Cmnd_Alias" do
      should create_file("#{sudoers_d}/30EDITORS").with_content("
Cmnd_Alias EDITORS = \\
    /usr/bin/vim, /usr/bin/emacs
")
      should create_datacat_fragment('command_alias EDITORS'
                                     ).with_data({'noexec' => ['EDITORS']})
    end

    it "should define the SINGLE_MEMBER_ARRAY Cmnd_Alias" do
      should create_file("#{sudoers_d}/30SINGLE_MEMBER_ARRAY").with_content("
Cmnd_Alias SINGLE_MEMBER_ARRAY = \\
    /bin/true
")
      should create_datacat_fragment('command_alias SINGLE_MEMBER_ARRAY'
                                     ).with_data({'setenv_exec' => ['SINGLE_MEMBER_ARRAY']})
    end

    it "should define the SINGLE_ITEM Cmnd_Alias" do
      should create_file("#{sudoers_d}/30SINGLE_ITEM").with_content("
Cmnd_Alias SINGLE_ITEM = \\
    /bin/false
")
      should create_datacat_fragment('command_alias SINGLE_ITEM'
                                     ).with_data({'noexec' => ['SINGLE_ITEM']})
    end

    it "should define the BAD_STUFF Cmnd_Alias" do
      should create_file("#{sudoers_d}/30BAD_STUFF").with_content("
Cmnd_Alias BAD_STUFF = \\
    /sbin/fdisk
")
      should create_datacat_fragment('command_alias BAD_STUFF'
                                     ).with_data({'DISALLOW_noexec' => ['BAD_STUFF']})
    end

    it "should bind the parts into a whole" do
      should create_file('sudoers.d/90auditable_whole').with_path("#{sudoers_d}/90auditable_whole")
      should create_datacat('sudoers.d/90auditable_whole').with_template('sudo/auditable/whole.erb')
    end

    it "should allow the luckygroup to run things" do
      should create_file("#{sudoers_d}/99_luckygroup").with_content(
"%luckygroup ALL=(ALL) \\
    NOPASSWD:NOEXEC:        AUDITABLE_NOEXEC, \\
    NOPASSWD:EXEC:          AUDITABLE_EXEC,   \\
    NOPASSWD:SETENV:NOEXEC: AUDITABLE_SETENV_NOEXEC, \\
    NOPASSWD:SETENV:EXEC:   AUDITABLE_SETENV_EXEC
")
    end
  end

  describe "on a Mac" do
    let(:facts) {{ :osfamily => 'Darwin' }}
    include_examples "proper sudoers.d file creation"
    it "should add include statements to the sudoers file" do
      should create_augeas('sudoers_include_90auditable_whole')
    end
  end

  describe "on a RHEL box" do
    let(:facts) {{ :osfamily => 'RedHat' }}
    include_examples "proper sudoers.d file creation"
  end

  
  # I guess we don't get to test the actual contents of the files
  # here: if we wanted to, we would have to write an acceptance spec
  # using Beaker, which would spin up a VM or container, run the
  # catalog inside it, and let us make assertions about the resultant
  # system state.

end
