# require 'mangad/site_parser_base'
require 'mangad/site_parser_base'
module Mangad
  class MangaHostParser < SiteParserBase

    # url used to search in the site
    SEARCH_URL = "http://mangahost.net/find/"

    # regex to extract url of found mangas
    SEARCH_LINK_REGEX = /entry-title">\s*<a\s*href="(.*)?"\s*title="(.*)"/

    # Regex to extract chapters' url from manga page.
    # Manga host has two diferent manga pages.
    # One to medium/short mangas and one to big mangas
    # /capitulo['"]\stitle=['"]Ler Online\s+-\s+(.*?)['"]\s+href=['"](.*?)['"]/, # for short/medium mangas
    CHAPTER_LINK_REGEX = [
      /capitulo.*?Ler\s+Online\s+-\s+(.*?)['"]\s+href=['"](.*?)['"]/, # for short/medium mangas
      /<a\s+href=['"](.*?)['"]\s+title=['"]Ler\s+Online\s+-\s+(.*?)\s+\[\]/ # for big mangas
    ]

    # regex to extract images' url from chapter page
    IMG_LINK_REGEX = /img_\d+['"]\s+src=['"](.*?)['"]/

    def download

      # white space is not allowed in the search url. 
      guess_manga_name = @options.manga.gsub(/\s/, '+') # Replace ' ' by  '+'

      search("#{SEARCH_URL}#{guess_manga_name}", SEARCH_LINK_REGEX)

      # puts "executing chapters".green ## DEBUG
      # Due the organazation of the chapters page the chapters are
      # extracted in reverse order
      @chapters = parse(@manga_url, CHAPTER_LINK_REGEX[0]) do |resul, page|

        # use long mangas regex if short mangas regex
        # returns empty array
        if resul.empty?
          # Extract chapters name and url and
          # swap chapter[0](name) with chapter[1](url)
          # to conform with result from CHAPTER_LINK_REGEX[0]
          page.scan(CHAPTER_LINK_REGEX[1]) {|chapter| resul << chapter.rotate}
=begin
          # resul = page.scan(CHAPTER_LINK_REGEX[1])
          page.scan(CHAPTER_LINK_REGEX[1]) do |c|

            result << [c[1], c[0]]
            result << c.rotate
          end
=end
        end
=begin
        page.scan(CHAPTER_LINK_REGEX[1]) do |r| # => try first regex
          if r.length < 2
            resul << r[0]
          else
            resul << r
          end
        end
=end
        resul
      end

      # correct utf-8 errors
      correct_chapters_name

      # prompt user to select chapters to download
      select_chapters

      # create manga directory
      create_dir(@manga_name)

      # download selected chapters
      @chapters.reverse_each do |chapter|
        imgs_url = parse(chapter[1], IMG_LINK_REGEX) do |resul, page|
          resul.each do |img|
            # some images urls are incorrect and need to be corrected. For exemple:
            # img.mangahost.net/br/images/img.png.webp => img.mangahost.net/br/mangas_files/img.png
            img.sub!(/images/, "mangas_files")
            img.sub!(/\.webp/, "")
          end
          resul
        end

        # create chapter directory relative to manga directory
        chapter_name = "#{chapter[0]}"
        chapter_dir = "#{@manga_name}/#{chapter_name}"
        create_dir(chapter_dir)

        Mangad::print_feedback "\nBaixando #{chapter_name}"
        imgs_donwload(chapter_dir, imgs_url)
      end
    end

    private
    # Due to problems with open-uri and utf-8
    # some chapters name need to be corrected
    def correct_chapters_name
      @chapters.each {|chapter| chapter[0].sub!(/[cC]ap.*?tulo/, "capitulo")}
    end
  end
end
