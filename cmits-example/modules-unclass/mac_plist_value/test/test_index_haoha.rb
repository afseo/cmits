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
require 'index_haoha'
require 'test/unit'

class TestIndexHaoha < Test::Unit::TestCase
    def test_not_array_nor_hash
        x = 3
        value = nil
        index_haoha(x, ['foo']) do |p|
            value = p
        end
        assert_equal(nil, value)
    end

    def test_not_array_nor_hash_fail
        x = 3
        value = nil
        assert_raise(IndexError) do
            index_haoha_or_fail(x, ['foo']) do |p|
                value = p
            end
        end
    end

    def test_one_level_hash
        x = {'foo' => 4}
        value = nil
        index_haoha(x, ['foo']) do |p|
            value = p
        end
        assert_equal(4, value)
    end

    def test_one_level_array
        x = [4,5,6]
        value = nil
        index_haoha(x, [1]) do |p|
            value = p
        end
        assert_equal(5, value)
    end

    def test_two_levels_hashes
        x = {'foo' => {'bar' => 'baz', 'bletch' => 'quux'}}
        value = nil
        index_haoha(x, ['foo', 'bletch']) do |p|
            value = p
        end
        assert_equal('quux', value)
    end

    def test_two_levels_arrays
        x = [4,5,[7,8,9]]
        value = nil
        index_haoha(x, [2,2]) do |p|
            value = p
        end
        assert_equal(9, value)
    end

    def test_two_levels_a_h
        x = [{'foo' => 'bar'}, 9]
        value = nil
        index_haoha(x, [0, 'foo']) do |p|
            value = p
        end
        assert_equal('bar', value)
    end

    def test_two_levels_a_h_fail
        x = [{'foo' => 'bar'}, 9]
        value = nil
        index_haoha_or_fail(x, [0, 'foo']) do |p|
            value = p
        end
        assert_equal('bar', value)
    end

    def test_two_levels_h_a
        x = {'foo' => [4,5,6], 'bar' => 9}
        value = nil
        index_haoha(x, ['foo', 2]) do |p|
            value = p
        end
        assert_equal(6, value)
    end

    def test_not_found_h
        x = {'foo' => 3}
        value = nil
        index_haoha(x, ['bar']) do |p|
            value = p
        end
        assert_equal(nil, value)
    end

    def test_not_found_a
        x = [1,2,3]
        value = nil
        index_haoha(x, [8]) do |p|
            value = p
        end
        assert_equal(nil, value)
    end

    def test_set_fail
        x = {'foo' => {'bar' => 3}}
        index_haoha_or_fail(x, ['foo']) do |p|
            p['bar'] = 8
        end
        assert_equal({'foo' => {'bar' => 8}}, x)
    end

    def test_set_wildcard_fail
        x = { 'foo' => { 'bar' => { 'baz' => 3 },
                         'bletch' => { 'baz' => 4 }}}
        value = nil
        index_haoha_or_fail(x, ['foo', '*']) do |p|
            p['baz'] = 8
        end
        assert_equal(
            { 'foo' => { 'bar' => { 'baz' => 8 },
                         'bletch' => { 'baz' => 8 }}},
            x)
    end
end

