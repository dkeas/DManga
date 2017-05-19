require 'mangad'
require_relative 'test_helper'

class MangadTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Mangad::VERSION
  end
end
