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
require 'puppet'

Puppet::Type.type(:global_pwpolicy).provide :pwpolicy do
    desc "Manage global password policy on a Mac using the pwpolicy command."

# Patterned on the macauthorization resource type

    commands :pwpolicy => "/usr/bin/pwpolicy"
    confine :operatingsystem => :darwin
    defaultfor :operatingsystem => :darwin

    @parsed_global_pwpolicy = {}

    PolicyItemTypes = {
        'canModifyPasswordforSelf'       => :bool,
        'expirationDateGMT'              => :date,
        'hardExpireDateGMT'              => :date,
        'maxChars'                       => :int,
        'maxFailedLoginAttempts'         => :int,
        'maxMinutesOfNonUse'             => :int,
        'maxMinutesUntilChangePassword'  => :int,
        'maxMinutesUntilDisabled'        => :int,
        'minChars'                       => :int,
        'minutesUntilFailedLoginReset'   => :int,
        'newPasswordRequired'            => :bool,
        'notGuessablePattern'            => :int,
        'passwordCannotBeName'           => :bool,
        'requiresAlpha'                  => :bool,
        'requiresMixedCase'              => :bool,
        'requiresNumeric'                => :bool,
        'requiresSymbol'                 => :bool,
        'usingExpirationDate'            => :bool,
        'usingHardExpirationDate'        => :bool,
        'usingHistory'                   => :int,
    }

    class << self
        attr_accessor :parsed_global_pwpolicy
        
        def prefetch(resources)
            self.populate_parsed_global_pwpolicy
        end

        def instances
            if self.parsed_global_pwpolicy == {}
                self.prefetch(nil)
            end
            self.parsed_global_pwpolicy.collect do |k,v|
                new(:name => k, :value => v)
            end
        end

        def populate_parsed_global_pwpolicy
            # pwpolicy never returns a failure exit code, so we'll never find
            # out if it failed. :( The best we can do is try to avoid turning
            # an error message into an erroneous parsed result.
            out = execute([:pwpolicy, '-getglobalpolicy'], :combine => false)
            items = out.split
            debug items.inspect
            kv = items.collect {|x| x.split('=', 2)}
            parsed = {}
            kv.each do |key, value|
                parsed[key] = case PolicyItemTypes[key]
                    when :bool
                        case value
                            when true; :true
                            when false; :false
                            when 1; :true
                            when 0; :false
                            when :true; :true
                            when :false; :false
                            else; :false
                        end
                    when :int
                        value.to_i
                    else
                        value
                end
            end
            debug "parsed is now #{parsed.inspect}"
            self.parsed_global_pwpolicy = parsed
        end
    end

    # "standard required provider instance methods"
    def initialize(resource)
        if self.class.parsed_global_pwpolicy == {}
            self.class.prefetch(resource)
        end
        super
    end

    def value
        # to_s: avoid spurious changes from, e.g. 86400 to '86400'
        self.class.parsed_global_pwpolicy[name].to_s
    end

    def value= newvalue
        string_value = newvalue
        if PolicyItemTypes[name] == :bool
            int_value = case value
                          when true; 1
                          when false; 0
                          when 1; 1
                          when 0; 0
                          when :true; 1
                          when :false; 0
                          else; 0
                        end
            string_value = int_value.to_s
        end
        pwpolicy '-setglobalpolicy', "#{name}=#{string_value}"
    end

end
