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
require 'puppet/file_serving/content'
require 'puppet/file_serving/metadata'

Puppet::Type.newtype(:nss_cert) do
    @doc = "Deal with certificates in an NSS database."
    ensurable do
        defaultvalues
        defaultto :present
    end
    newparam(:name) do
        desc "Database directory and nickname of the certificate,
separated by a colon. Directories with colons in their names are not allowed."
        newvalues /.+:.+/
    end
    newparam(:trustargs) do
        desc "Certificate trust attributes; see /usr/bin/certutil -H. For
root CA certificates, should be 'CT,C,C'."
        defaultto ",,"
    end
    newparam(:pwfile) do
        desc "Pathname of file containing the password for the NSS database.
              Must already be on the host. Corresponds to the -f switch to
              certutil. Format of the pwfile is like so:

                  module name:password
              
              Module names of interest are 'NSS Certificate DB' and 
              'NSS FIPS 140-2 Certificate DB'."
    end
    newparam(:sqlite) do
        desc "Whether to tell NSS to use SQLite when accessing the database.
See https://blogs.oracle.com/meena/entry/what_s_new_in_nss1 for a summary, or
https://wiki.mozilla.org/NSS_Shared_DB for the full story.
"
        newvalues :true, :false
        defaultto :true
    end
    newparam(:source) do
        desc "Source of the certificate data. If it ends with a slash, 
              it is treated as a directory which should contain <name>.crt.
              For instance:

                class foo {
                    nss_cert { \"/db/dir:c1\":
                        source => \"puppet:///modules/foo/\"
                    }
                }

              is equivalent to

                class foo {
                    nss_cert { \"/db/dir:c1\": 
                        source => \"puppet:///modules/foo/c1.crt\"
                    }
                }

            "
        # this parameter's code comes from puppet's type/file/source.rb
        validate do |sources|
            sources = [sources] unless sources.is_a?(Array)
            sources.each do |source|
                begin
                    uri = URI.parse(URI.escape(source))
                rescue => detail
                    self.fail "Could not understand source #{source}: #{detail}"
                end
                self.fail "Cannot use URLs of type '#{uri.scheme}' as source for fileserving" unless uri.scheme.nil? or %w{file puppet}.include?(uri.scheme)
            end
        end

        munge do |sources|
            sources = [sources] unless sources.is_a?(Array)
            # the resource name is of dbdir:nickname format, where nickname may
            # have colons in it; strip off the dbdir:, keep the nickname
            nickname = @resource[:name].split(':')[1..-1].join(':')
            sources.collect { |source| source.sub(/\/$/, "/#{nickname}.crt") }
        end

        # Look up (if necessary) and return remote content.
        def content
          return @content if @content
          raise Puppet::DevError, "No source for content was stored with the metadata" unless metadata.source

          unless tmp = Puppet::FileServing::Content.indirection.find(metadata.source)
            fail "Could not find any content at %s" % metadata.source
          end
          @content = tmp.content
        end

        # Provide, and retrieve if necessary, the metadata for this file.  Fail
        # if we can't find data about this host, and fail if there are any
        # problems in our query.
        def metadata
          return @metadata if @metadata
          return nil unless value
          value.each do |source|
            begin
              if data = Puppet::FileServing::Metadata.indirection.find(source)
                @metadata = data
                @metadata.source = source
                break
              end
            rescue => detail
              fail detail, "Could not retrieve file metadata for #{source}: #{detail}"
            end
          end
          fail "Could not retrieve information from environment #{Puppet[:environment]} source(s) #{value.join(", ")}" unless @metadata
          @metadata
        end

    end
end
