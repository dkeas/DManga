require 'dmanga'
require_relative 'test_helper'

class DMangaTest < Minitest::Test
    def test_that_it_has_a_version_number
        refute_nil ::DManga::VERSION
    end
end
