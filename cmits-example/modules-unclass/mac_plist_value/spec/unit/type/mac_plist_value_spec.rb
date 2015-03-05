#!/usr/bin/env/rspec
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

mac_plist_value = Puppet::Type.type(:mac_plist_value)
describe Puppet::Type.type(:mac_plist_value) do

    it "requires absolute file paths" do
        expect {
            resource = mac_plist_value.new(:title => 'file:key')
        }.to raise_error(Puppet::Error, /Invalid value "file"/)
    end

    it "should split the file and key apart when used as the resource name" do
        resource = mac_plist_value.new(:title => '/file:key')
        resource[:file].should == '/file'
        resource[:key].should == ['key']
    end

    it "doesn't support colons in file names" do
        resource = mac_plist_value.new(:title => '/file:name:key')
        resource[:file].should == '/file'
        resource[:key].should == ['name:key']

        expect {
            resource2 = mac_plist_value.new(
                :title => 'do not care',
                :file => '/file:name',
                :key => 'key')
        }.to raise_error(Puppet::Error, /Invalid value "\/file:name"/)
    end

    it "supports multilevel keys" do
        resource = mac_plist_value.new(:title => '/file:foo/bar/baz')
        resource[:file].should == '/file'
        resource[:key].should == ['foo', 'bar', 'baz']
    end

end
