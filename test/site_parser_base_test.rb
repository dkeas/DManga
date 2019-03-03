require 'webmock/minitest'
require 'dmanga/site_parser_base'
require 'dmanga/mangahost_parser'
require 'dmanga/util'
require_relative 'test_helper'

class TestSiteParserBase < Minitest::Test
    SEARCH_PAGE = [ File.dirname(__FILE__), "files",
                    "onepunch-search.html"].join("/")
    CHAPTER_PAGE = [
        [File.dirname(__FILE__), "files",
         "onepunch-chapters.html"].join("/"),
    [File.dirname(__FILE__), "files",
     "tomo-chapters.html"].join("/")
    ]
    IMGS_PAGE = [ " ",
                  [File.dirname(__FILE__), "files",
                   "tokyoghoul-imgs.html"].join("/")]

    def setup
        @site_parser = DManga::SiteParserBase.new(["manga name"])
    end

    def test_parse_search_page
        mangas = [
            ["https://mangahost.net/manga/db-x-saitama-doujinshi",
             "DB X Saitama (Doujinshi)"],
        ["https://mangahost.net/manga/fire-punch",
         "Fire Punch"],
         ["https://mangahost.net/manga/one-punch-man",
          "One Punch-Man"],
          ["https://mangahost.net/manga/one-punch-man-one",
           "One Punch-Man (One)"],
        ["https://mangahost.net/manga/punch",
         "Punch!"],
         ["https://mangahost.net/manga/short-program-girls-type",
          "Short Program - Girl's Type"]
        ]

        page = File.open(SEARCH_PAGE).read
        stub_request(:get, "http://mangahost.net/find/one-punch").
            to_return(status:[200, "OK"], body: page)

        result = @site_parser.parse("http://mangahost.net/find/one-punch",
                                    DManga::MangaHostParser::SEARCH_LINK_REGEX)
        assert_equal mangas, result
    end

    def test_parse_chapters_page_for_long_mangas
        # test only the first threes and last threes
        firsts = [['https://mangahost.net/manga/one-punch-man/3',
                   'Cap&iacute;tulo #3 - One Punch-Man'],
                   ['https://mangahost.net/manga/one-punch-man/2',
                    'Cap&iacute;tulo #2 - One Punch-Man'],
                    ['https://mangahost.net/manga/one-punch-man/1',
                     'Cap&iacute;tulo #1 - One Punch-Man']]

        lasts = [['https://mangahost.net/manga/one-punch-man/108',
                  'Cap&iacute;tulo #108 - One Punch-Man'],
                  ['https://mangahost.net/manga/one-punch-man/107.2',
                   'Cap&iacute;tulo #107.2 - One Punch-Man'],
                   ['https://mangahost.net/manga/one-punch-man/107.1',
                    'Cap&iacute;tulo #107.1 - One Punch-Man']]

        page = File.open(CHAPTER_PAGE[0]).read
        stub_request(:get, "https://mangahost.net/manga/one-punch-man").
            to_return(status:[200, "OK"], body: page,
                      headers: { "Content-Type" => "text/html; charset=UTF-8"})

        result = @site_parser.parse("https://mangahost.net/manga/one-punch-man",
                                    DManga::MangaHostParser::CHAPTER_LINK_REGEX[1])
        assert_equal firsts, result[-3..-1]
        assert_equal lasts, result[0..2]
    end

    def test_parse_chapters_page_for_short_mangas
        # test the first threes and last threes
        firsts = [["Capítulo #21-30 - Capítulos do 21 ao 30!",
                   "http://mangahost.net/manga/tomo-chan-wa-onna-no-ko/21-30"],
                   ["Capítulo #11-20 - Capítulos do 11 ao 20!",
                    "http://mangahost.net/manga/tomo-chan-wa-onna-no-ko/11-20"],
                    ["Capítulo #1-10 - Capítulos do 01 ao 10!",
                     "http://mangahost.net/manga/tomo-chan-wa-onna-no-ko/1-10"]]

        lasts = [["Capítulo #491-500 - Tomo-chan wa Onna no ko!",
                  "http://mangahost.net/manga/tomo-chan-wa-onna-no-ko/491-500"],
                  ["Capítulo #481-490 - Tomo-chan wa Onna no ko!",
                   "http://mangahost.net/manga/tomo-chan-wa-onna-no-ko/481-490"],
                   ["Capítulo #471-480 - Tomo-chan wa Onna no ko!",
                    "http://mangahost.net/manga/tomo-chan-wa-onna-no-ko/471-480"]]
        page = File.open(CHAPTER_PAGE[1]).read
        stub_request(:get, "https://mangahost.net/manga/tomo-chan").
            to_return(status:[200, "OK"], body: page,
                      headers: { "Content-Type" => "text/html; charset=UTF-8"})

        result = @site_parser.parse("https://mangahost.net/manga/tomo-chan",
                                    DManga::MangaHostParser::CHAPTER_LINK_REGEX[0])
        assert_equal firsts, result[-3..-1]
        assert_equal lasts, result[0..2]
    end

    def test_parse_imgs_page_alt_regex
        firsts = ["https:\\/\\/img.mangahost.me\\/br\\/images\\/tokyo-ghoulre\\/99\\/00.jpg.webp",
                  "https:\\/\\/img.mangahost.me\\/br\\/images\\/tokyo-ghoulre\\/99\\/01.png.webp",
                  "https:\\/\\/img.mangahost.me\\/br\\/images\\/tokyo-ghoulre\\/99\\/02.png.webp"]

        lasts = ["https:\\/\\/img.mangahost.me\\/br\\/images\\/tokyo-ghoulre\\/99\\/16.png.webp",
                 "https:\\/\\/img.mangahost.me\\/br\\/images\\/tokyo-ghoulre\\/99\\/17.png.webp",
                 "https:\\/\\/img.mangahost.me\\/br\\/images\\/tokyo-ghoulre\\/99\\/18.png.webp"]

        page = File.open(IMGS_PAGE[1]).read
        stub_request(:get, 'https://mangahost.net/manga/tokyo-ghoulre/99').
            to_return(status:[200, "OK"], body: page)

        result = @site_parser.parse("https://mangahost.net/manga/tokyo-ghoulre/99",
                                    DManga::MangaHostParser::IMG_LINK_REGEX[1])
        assert_equal firsts, result[0..2]
        assert_equal lasts, result[-3..-1]
    end

    def test_select_manga_when_manga_was_found
        mangas = [["https://mangahost.net/manga/db-x-saitama-doujinshi",
                   "DB X Saitama (Doujinshi)"],
        ["https://mangahost.net/manga/fire-punch",
         "Fire Punch"],
         ["https://mangahost.net/manga/one-punch-man",
          "One Punch-Man"],
          ["https://mangahost.net/manga/one-punch-man-one",
           "One Punch-Man (One)"],
        ["https://mangahost.net/manga/punch",
         "Punch!"],
         ["https://mangahost.net/manga/short-program-girls-type",
          "Short Program - Girl's Type"]]
        $stdin = StringIO.new("n\nn\ns\n") #simulate user input
        @site_parser.select_manga(mangas)
        $stdin = STDIN
        assert_equal @site_parser.manga_url, mangas[2][0]
        assert_equal @site_parser.manga_name, mangas[2][1]
    end

    # test "test select manga when manga was not found" do
    def test_select_manga_when_manga_was_not_found
        mangas = [["https://mangahost.net/manga/db-x-saitama-doujinshi",
                   "DB X Saitama (Doujinshi)"],
        ["https://mangahost.net/manga/fire-punch",
         "Fire Punch"],
         ["https://mangahost.net/manga/one-punch-man-one",
          "One Punch-Man (One)"],
        ["https://mangahost.net/manga/punch",
         "Punch!"]]
        $stdin = StringIO.new("n\nn\nn\nn\n") #simulate user input
        assert_raises(DManga::MangaNotFoundError) {@site_parser.select_manga(mangas)}
        $stdin = STDIN
    end

    def test_select_manga_when_search_returns_no_manga
        mangas = []
        assert_raises(DManga::MangaNotFoundError) {@site_parser.select_manga(mangas)}
    end

    def test_select_chapters_with_range
        chapters = [['https://mangahost.net/manga/one-punch-man/10',
                     'Cap&iacute;tulo #10 - One Punch-Man'],
                     ['https://mangahost.net/manga/one-punch-man/9',
                      'Cap&iacute;tulo #9 - One Punch-Man'],
                      ['https://mangahost.net/manga/one-punch-man/8',
                       'Cap&iacute;tulo #8 - One Punch-Man'],
                       ['https://mangahost.net/manga/one-punch-man/7',
                        'Cap&iacute;tulo #7 - One Punch-Man'],
                        ['https://mangahost.net/manga/one-punch-man/6',
                         'Cap&iacute;tulo #6 - One Punch-Man'],
                         ['https://mangahost.net/manga/one-punch-man/5',
                          'Cap&iacute;tulo #5 - One Punch-Man'],
                          ['https://mangahost.net/manga/one-punch-man/4',
                           'Cap&iacute;tulo #4 - One Punch-Man'],
                           ['https://mangahost.net/manga/one-punch-man/3',
                            'Cap&iacute;tulo #3 - One Punch-Man'],
                            ['https://mangahost.net/manga/one-punch-man/2',
                             'Cap&iacute;tulo #2 - One Punch-Man'],
                             ['https://mangahost.net/manga/one-punch-man/1',
                              'Cap&iacute;tulo #1 - One Punch-Man']]
        @site_parser.chapters = chapters
        $stdin = StringIO.new("1-5\n")
        @site_parser.select_chapters
        $stdin = STDIN
        assert_equal @site_parser.chapters, chapters[-5..-1]
    end

    def test_select_chapters_with_specific_number
        chapters = [['https://mangahost.net/manga/one-punch-man/10',
                     'Cap&iacute;tulo #10 - One Punch-Man'],
                     ['https://mangahost.net/manga/one-punch-man/9',
                      'Cap&iacute;tulo #9 - One Punch-Man'],
                      ['https://mangahost.net/manga/one-punch-man/8',
                       'Cap&iacute;tulo #8 - One Punch-Man'],
                       ['https://mangahost.net/manga/one-punch-man/7',
                        'Cap&iacute;tulo #7 - One Punch-Man'],
                        ['https://mangahost.net/manga/one-punch-man/6',
                         'Cap&iacute;tulo #6 - One Punch-Man'],
                         ['https://mangahost.net/manga/one-punch-man/5',
                          'Cap&iacute;tulo #5 - One Punch-Man'],
                          ['https://mangahost.net/manga/one-punch-man/4',
                           'Cap&iacute;tulo #4 - One Punch-Man'],
                           ['https://mangahost.net/manga/one-punch-man/3',
                            'Cap&iacute;tulo #3 - One Punch-Man'],
                            ['https://mangahost.net/manga/one-punch-man/2',
                             'Cap&iacute;tulo #2 - One Punch-Man'],
                             ['https://mangahost.net/manga/one-punch-man/1',
                              'Cap&iacute;tulo #1 - One Punch-Man']]
        @site_parser.chapters = chapters
        $stdin = StringIO.new("1,3,4\n")
        @site_parser.select_chapters
        $stdin = STDIN
        assert_equal(@site_parser.chapters,
                     [chapters[4 * -1], chapters[3 * -1], chapters[1 * -1]])
    end

    def test_select_all_chapters
        chapters = [['https://mangahost.net/manga/one-punch-man/10',
                     'Cap&iacute;tulo #10 - One Punch-Man'],
                     ['https://mangahost.net/manga/one-punch-man/9',
                      'Cap&iacute;tulo #9 - One Punch-Man'],
                      ['https://mangahost.net/manga/one-punch-man/8',
                       'Cap&iacute;tulo #8 - One Punch-Man'],
                       ['https://mangahost.net/manga/one-punch-man/7',
                        'Cap&iacute;tulo #7 - One Punch-Man'],
                        ['https://mangahost.net/manga/one-punch-man/6',
                         'Cap&iacute;tulo #6 - One Punch-Man'],
                         ['https://mangahost.net/manga/one-punch-man/5',
                          'Cap&iacute;tulo #5 - One Punch-Man'],
                          ['https://mangahost.net/manga/one-punch-man/4',
                           'Cap&iacute;tulo #4 - One Punch-Man'],
                           ['https://mangahost.net/manga/one-punch-man/3',
                            'Cap&iacute;tulo #3 - One Punch-Man'],
                            ['https://mangahost.net/manga/one-punch-man/2',
                             'Cap&iacute;tulo #2 - One Punch-Man'],
                             ['https://mangahost.net/manga/one-punch-man/1',
                              'Cap&iacute;tulo #1 - One Punch-Man']]
        @site_parser.chapters = chapters
        $stdin = StringIO.new("todos\n")
        @site_parser.select_chapters
        $stdin = STDIN
        assert_equal @site_parser.chapters, chapters
    end

    def test_create_dir
        dir_name = "test_dir"
        @site_parser.create_dir dir_name
        dir_path = [@site_parser.download_dir, dir_name].join(File::SEPARATOR)
        assert File.exist? dir_path
        Dir.rmdir dir_path
    end

    def test_remove_invlid_simbols
        invalid_names = ["Tokyo Ghoul:Re", "Tokyo Ghoul\\Re", "Tokyo Ghoul/Re", "Tokyo Ghoul*Re",
                         "should\\remove/any:invalid*character?in<that>string|end"]

        corrected_names = ["Tokyo Ghoul_Re", "Tokyo Ghoul_Re", "Tokyo Ghoul_Re", "Tokyo Ghoul_Re",
                           "should_remove_any_invalid_character_in_that_string_end"]
        invalid_names.each{ |n| @site_parser.remove_invalid_simbols(n) }
        assert_equal corrected_names, invalid_names
    end

    def test_remove_dot_from_folder_name
      # remove dots if they are in the end or in the start of the name
      invalid_names = ['narimashita......', 'lllllll...', '...mmmmm', '...........jjjjjjjjjj']
      corrected_names = ['narimashita_', 'lllllll_', '_mmmmm', '_jjjjjjjjjj']
      invalid_names.each{ |n| @site_parser.remove_invalid_simbols(n) }
      assert_equal corrected_names, invalid_names

      # don't remove dots that are in the middle of the name
      valid_names = ['name.of.manga', 'name...........manga']
      expect_result = ['name.of.manga', 'name...........manga']
      valid_names.each { |n| @site_parser.remove_invalid_simbols(n) }
      assert_equal expect_result, valid_names
    end

    def test_imgs_download_normal_uri
        test_uri = "https://img.mangahost.me/br/mangas_files/shokugeki-no-souma/1/r002.jpg"
        stub_request(:get, test_uri).
            to_return(status:[200, "OK"], body: "stub for images file")
        chp_path = ""
        original_img_name = "r002.jpg"
        @site_parser.imgs_download(chp_path, [test_uri])
        img_path = [@site_parser.download_dir, original_img_name].join(File::SEPARATOR)
        assert(File.exist?(img_path), "File r002.jpg should exist")
        File.delete img_path
    end

    def test_imgs_download_with_uri_that_contains_white_space
        stub_request(:get, "https://img.mangahost.me/br/mangas_files/elfen-lied/1" +
                     "/%5BChrono%5D%20Elfen%20Lied%20-%20Volume%2001%20-%20Capitulo%" +
                     "20001/EL-v01-ch01-001.jpg").
                     to_return(status:[200, "OK"], body: "stub for images file")
        chp_path = ""
        img_uri = ["https://img.mangahost.me/br/mangas_files/elfen-lied/" + 
                   "1/[Chrono] Elfen Lied - Volume 01 - Capitulo 001/EL-v01-ch01-001.jpg"]
        original_img_name = "EL-v01-ch01-001.jpg"
        @site_parser.imgs_download(chp_path, img_uri)
        img_path = [@site_parser.download_dir, original_img_name].join(File::SEPARATOR)
        assert(File.exist?(img_path), "File EL-v01-ch01-001.jpg should exist")
        File.delete img_path
    end

    def test_imgs_download_with_uri_that_contains_utf8_chars
        test_uri = "https://img.mangahost.me/br/mangas_files/shokugeki-no-souma/1/Créditos.jpg"
        stub_request(:get, test_uri).
            to_return(status:[200, "OK"], body: "stub for images file")
        chp_path = ""
        original_img_name = "Créditos.jpg"
        @site_parser.imgs_download(chp_path, [test_uri])
        img_path = [@site_parser.download_dir, original_img_name].join(File::SEPARATOR)
        assert(File.exist?(img_path), "File Créditos.jpg should exist")
        File.delete img_path
    end
end
