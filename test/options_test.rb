# require 'minitest/autorun'
require 'dmanga/options'
require_relative 'test_helper'

class TestOption < Minitest::Test

    def test_options_manga_name
        opt = DManga::Options.new(['manga name'])
        assert_equal opt.manga, 'manga name'
    end

    def test_options_without_download_path
        opt = DManga::Options.new(['-v', 'manga name'])
        assert_equal DManga::Options::DEFAULT_DOWNLOAD_DIR, opt.download_dir
    end

    def test_options_all
        opt = DManga::Options.new(['-v', '-d', '/path/to/directory', 'manga another name'])
        assert_equal '/path/to/directory', opt.download_dir
        assert opt.verbose, 'verbose must be true'
        assert_equal opt.manga, 'manga another name'
    end

    def test_options_without_verbose
        opt = DManga::Options.new(['-d', '/path/to/directory', 'manga name'])
        refute opt.verbose, 'verbose must be false'
    end

end
