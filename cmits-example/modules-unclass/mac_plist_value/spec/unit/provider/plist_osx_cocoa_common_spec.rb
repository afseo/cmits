#!/usr/bin/env rspec
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

provider_class = Puppet::Type.type(:mac_plist_value).provider(:osx_cocoa)

shared_context "example values" do
    # Values written in the manifest come to us via the Puppet parser through
    # the resource object. All of these values are strings. It's up to us to
    # take things that look like numbers or constants, and coerce them to those
    # values.
    @example_values = {
        # typename => [wrong value as read from plist,
        #              right value as read from plist, 
        #              right value as received from resource type]
        'string' => ['wrong-value', 'string-value', 'string-value'],
        'number' => [0, 42, '42'],
        'true'   => [false, true, 'true'],
        'false'  => [true, false, 'false'],
        'array'  => [[3], [3,4,5], ['3', '4', '5']],
        'hash'   => [{}, {'zart' => 'xyzzy'}, {'zart' => 'xyzzy'}]
    }
end

describe provider_class do
    before :each do
        # Create a mock resource
        @resource = stub 'resource'
        @resource.stubs(:[]).returns(nil)

        @provider = provider_class.new
        @provider.stubs(:resource).returns @resource
    end

    it "should have a create method" do
        @provider.should respond_to(:create)
    end
    it "should have a destroy method" do
        @provider.should respond_to(:destroy)
    end
    it "should have an exists? method" do
        @provider.should respond_to(:exists?)
    end

    context "when checking whether to change things" do
        include_context "example values"
        @example_values.each do |typename, values|
            context "checking #{typename}s" do
                before :each do
                    @resource.stubs(:[]).with(:value).returns(values[2])
                end
                context "at the top level" do
                    before :each do
                        @resource.stubs(:[]).with(:key).returns([typename])
                    end
                    it "should indicate a change when needed" do
                        @provider.stubs(:_load).returns({ typename => values[0] })
                        @provider.exists?.should be_false
                    end
                    it "should not indicate a change when not needed" do
                        @provider.stubs(:_load).returns({ typename => values[1] })
                        @provider.exists?.should be_true
                    end
                end
                context "inside multiple levels" do
                    before :each do
                        @resource.stubs(:[]).with(:key).returns(['one', 'two', typename])
                    end
                    it "should indicate a change when needed" do
                        @provider.stubs(:_load).returns({ 
                            'one' => {
                                'two' => { typename => values[0] },
                                'other_one' => {},
                            'another' => { 'poit' => 'narf' }}})
                        @provider.exists?.should be_false
                    end
                    it "should not indicate a change when not needed" do
                        @provider.stubs(:_load).returns({ 
                            'one' => {
                                'two' => { typename => values[1] },
                                'other_one' => {},
                            'another' => { 'poit' => 'narf' }}})
                        @provider.exists?.should be_true
                    end
                end
            end
        end
        context "checking single-member arrays" do
            context "at the top level" do
                it "should indicate a change when needed" do
                    @resource.stubs(:[]).with(:value).returns(['foo', ''])
                    @resource.stubs(:[]).with(:key).returns(['singletonarraysetting'])
                    @provider.stubs(:_load).returns({ 'singletonarraysetting' => 'foo' })
                    @provider.exists?.should be_false
                end
                it "should not indicate a change when not needed" do
                    @resource.stubs(:[]).with(:value).returns(['foo', ''])
                    @resource.stubs(:[]).with(:key).returns(['singletonarraysetting'])
                    @provider.stubs(:_load).returns({ 'singletonarraysetting' => ['foo'] })
                    @provider.exists?.should be_true
                end

            end
        end
        context "checking multimember arrays with empty string at end" do
            context "at the top level" do
                it "should indicate a change when needed" do
                    @resource.stubs(:[]).with(:value).returns(['foo', '', ''])
                    @resource.stubs(:[]).with(:key).returns(['singletonarraysetting'])
                    @provider.stubs(:_load).returns({ 'singletonarraysetting' => ['foo'] })
                    @provider.exists?.should be_false
                end
                it "should not indicate a change when not needed" do
                    @resource.stubs(:[]).with(:value).returns(['foo', '', ''])
                    @resource.stubs(:[]).with(:key).returns(['singletonarraysetting'])
                    @provider.stubs(:_load).returns({ 'singletonarraysetting' => ['foo', ''] })
                    @provider.exists?.should be_true
                end
            end
        end
    end

    context "when changing things" do
        before :each do
            # there's probably some mocky way to do this but i don't know what
            # it is and this appears to work.
            class << @provider
                attr_reader :saved
                def _save arg
                    @saved = arg
                end
            end
        end
        include_context "example values"
        @example_values.each do |typename, values|
            context "changing #{typename}s" do
                before :each do
                    @resource.stubs(:[]).with(:value).returns(values[2])
                end
                it "should successfully change a single value" do
                    @resource.stubs(:[]).with(:key).returns(['one', 'two', typename])
                    before = {
                        'one' => {
                            'two' => { typename => values[0] },
                            'other_one' => {},
                        'another' => { 'poit' => 'narf' }}}
                    expected = before.clone
                    expected['one']['two'][typename] = values[1]
                    @provider.stubs(:_load).returns(before)
                    @provider.create
                    @provider.saved.should eq(expected)
                end
                it "should successfully delete a single value" do
                    @resource.stubs(:[]).with(:key).returns(['one', 'two', typename])
                    before = {
                        'one' => {
                            'two' => { typename => values[0], 'aaaagh' => 'dictating' },
                            'other_one' => {},
                        'another' => { 'poit' => 'narf' }}}
                    expected = before.clone
                    expected['one']['two'] = {'aaaagh' => 'dictating'}
                    @provider.stubs(:_load).returns(before)
                    @provider.destroy
                    @provider.saved.should eq(expected)
                end
            end
        end
    end
end
