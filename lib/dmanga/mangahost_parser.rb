require 'dmanga/site_parser_base'
require 'dmanga/zip_file_generator'

module DManga
  class MangaHostParser < SiteParserBase

    # url used to search in the site
    # SEARCH_URL = "https://mangahost.net/find/"
    SEARCH_URL = "https://mangahost.cc/find/"

    # regex to extract url of found mangas
    SEARCH_LINK_REGEX = /entry-title">\s*<a\s*href="(.*)?"\s*title="(.*)"/

    # Regex to extract chapters' url from manga page.
    # Manga host has two diferent manga pages.
    # One to medium/short mangas and one to big mangas
    CHAPTER_LINK_REGEX = [
      /capitulo.*?Ler\s+Online\s+-\s+(.*?)['"]\s+href=['"](.*?)['"]/, # for short/medium mangas
      /<a\s+href=['"](.*?)['"]\s+title=['"]Ler\s+Online\s+-\s+(.*?)\s+\[\]/ # for big mangas
    ]

    # regex to extract images' url from chapter page
    IMG_LINK_REGEX = [/img_\d+['"]\s+src=['"](.*?)['"]/,
    /url['"]:['"](.*?)['"]\}/]

    def download

      # white space is not allowed in the search url.
      guess_manga_name = @options.manga.gsub(/\s/, '+') # Replace ' ' by  '+'

      search("#{SEARCH_URL}#{guess_manga_name}", SEARCH_LINK_REGEX)

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
        end
        resul
      end

      # correct utf-8 errors
      correct_chapters_name

      # prompt user to select chapters to download
      select_chapters

      # remove simbols that cannot be used in folder's name on windows
      remove_invalid_simbols(@manga_name)
      # create manga directory
      remove_invalid_simbols(@manga_name)
      create_dir(@manga_name)

      # download selected chapters
      @chapters.reverse_each do |chapter|
        imgs_url = parse(chapter[1], IMG_LINK_REGEX[0]) do |resul, page|
          # use second pattern if the first returns a empty
          # array
          if resul.empty?
            page.scan(IMG_LINK_REGEX[1]) do |img|
              resul << img[0]
            end
          end

          resul.each do |img|
            # some images urls are incorrect and need to be corrected. For exemple:
            # img.mangahost.net/br/images/img.png.webp => img.mangahost.net/br/mangas_files/img.png
            img.sub!(/images/, "mangas_files")
            img.sub!(/\.webp/, "")

            #correct créditos img problem
            correct_image_uri(img)

            img.gsub!(%r{\\}, "")
          end
          resul
        end

        # create chapter directory relative to manga directory
        chapter_name = "#{chapter[0]}"
        # remove simbols that cannot be used in folder's name on windows
        remove_invalid_simbols chapter_name
        chapter_dir = "#{@manga_name}/#{chapter_name}"
        create_dir(chapter_dir)

        DManga::display_feedback "\nBaixando #{chapter_name}"
        imgs_download(chapter_dir, imgs_url)
      end
    end

    private
    # Due to problems with open-uri and unicode
    # some chapters' name need to be corrected.
    # substitute Cap$amptulo for capitulo.
    def correct_chapters_name
      @chapters.each {|chapter| chapter[0].sub!(/[cC]ap.*?tulo/, "capitulo")}
    end

    UNICODE_TABLE = {
      "\\u00e1" => "\u00e1",
      "\\u00e9" => "\u00e9",
      "\\u00ed" => "\u00ed"
    }

    # Due to problems with open-uri and utf-8
    # some images uris need to be corrected.
    # substitute Cru00e9ditos for Créditos.
    # one url at a time
    def correct_image_uri(img_uri)
      result = img_uri.scan(/\\u..../i)
      result.each do |r|
        img_uri.sub!(r, UNICODE_TABLE[r.downcase])
      end
    end
  end
end
