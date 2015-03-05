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

describe 'swap::encrypt' do
    context 'on a Snow Leopard Mac' do
        let(:facts) {{
            :operatingsystem => 'Darwin',
            :osfamily => 'Darwin',
            :operatingsystemrelease => '10.8.0',
            :macosx_productversion_major => '10.6',
        }}

        it { should include_class('swap::encrypt::darwin') }
    end
    context 'on a Linux box' do
        let(:facts) {{
            :operatingsystem => 'RedHat',
            :osfamily => 'RedHat',
            :operatingsystemrelease => '6.4',
        }}
        it do
            expect { 
                should include_class('swap::encrypt::darwin')
            }.to raise_error(Puppet::Error, /Unimplemented on/)
        end
    end
end

