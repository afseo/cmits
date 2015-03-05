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
# Follow a path of indices through a hash or array of hashes or arrays.
# (Pronounced "IN dex HOW huh.")
# 
# When Mac property lists are read as NSDictionaries and converted using the
# to_ruby method, as far as I know they are composed only of boring collection
# types, like Hash and Array. Furthermore, numbers and strings are indexable in
# Ruby 1.8.7, but it's most likely that if you are modifying a Mac property
# list, you want to change a whole number or string, not a bit or character
# inside it. So, we'll violate the principle of duck typing by refusing to
# index something that is neither a Hash nor an Array. 
def index_haoha tree, path, &block
    if path.empty?
        yield tree
    else
# Since we're supporting wildcards here, therefore multiple paths and possibly
# multiple matches, we don't want one failure to halt the traversal, so we just
# do nothing rather than error out.
      if tree.is_a?(Hash) or tree.is_a?(Array)
            if path[0] == '*'
                tree.each do |thing|
                    # for Hashes, thing is like [key, value]
                    thing = thing[-1] if thing.is_a? Array
                    index_haoha thing, path[1..-1], &block
                end
            else
                index_haoha tree[path[0]], path[1..-1], &block
            end
        end
    end
end

def index_haoha_or_fail tree, path, &block
    arrived_at_least_once = false
    index_haoha(tree, path) do |x|
        yield x
        arrived_at_least_once = true
    end
    raise IndexError, "Could not find any matches " \
            "for path #{path.inspect}" unless arrived_at_least_once
end

def mkhashp hash, path
    if path.any?
        hash[path[0]] ||= {}
        mkhashp hash[path[0]], path[1..-1]
    end
end
