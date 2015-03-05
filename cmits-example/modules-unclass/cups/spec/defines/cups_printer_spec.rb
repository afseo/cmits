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

describe 'cups::printer' do
  let(:title) { 'fnordprinter' }
  let(:params) { {
      :model => 'foomatic:HP-Color_LaserJet_4700-Postscript.ppd',
      :options => { 'one' => 'two', 'three' => 'four' },
      :uri => 'socket://fnordprinter:9100',
      :description => 'This is the fnord printer.',
      :location => 'Upstairs',
    }}

  context 'when ensure and enable are at their defaults' do
    expected_lpadmin_command = "lpadmin -p 'fnordprinter'\
                     -m 'foomatic:HP-Color_LaserJet_4700-Postscript.ppd'\
                     -o 'one=two' -o 'three=four'\
                     -u allow:all\
                     -v 'socket://fnordprinter:9100'\
                     -D 'This is the fnord printer.'\
                     -L 'Upstairs'"
    it do
      should contain_exec('create_printer_fnordprinter'
                          ).with_command(expected_lpadmin_command)
      should contain_exec('accept_printer_fnordprinter')
      should contain_exec('enable_printer_fnordprinter')
    end
  end
  context 'when ensure but not enable' do
    let(:params) {{
      :model => 'foomatic:HP-Color_LaserJet_4700-Postscript.ppd',
      :options => { 'one' => 'two', 'three' => 'four' },
      :uri => 'socket://fnordprinter:9100',
      :description => 'This is the fnord printer.',
      :location => 'Upstairs',
      :enable => 'false',
    }}
    it do
      should contain_exec('create_printer_fnordprinter')
      should contain_exec('reject_printer_fnordprinter')
      should contain_exec('disable_printer_fnordprinter')
    end
  end
  context 'when ensure\'s value is absent' do
    let(:params) {{
      :model => 'foomatic:HP-Color_LaserJet_4700-Postscript.ppd',
      :options => { 'one' => 'two', 'three' => 'four' },
      :uri => 'socket://fnordprinter:9100',
      :description => 'This is the fnord printer.',
      :location => 'Upstairs',
      :ensure => 'absent',
    }}
    it do
      should contain_exec('remove_printer_fnordprinter')
    end
  end
end
                                                                
