require 'mangad/options'
require 'ruby-progressbar'
require 'open-uri'
require 'pry'
require 'rainbow'

module Mangad
  class SiteParserBase
    USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0"

    attr_accessor :manga_name, :manga_url, :download_path, 
      :chapters, :verbose

    def initialize(argv)
      @options = Options.new(argv)
      @manga_url = nil
      @manga_name = nil
      @chapters = nil
    end

    # Parse the html and colect the links that match the pattern.
    # Can receive a block.
    def parse(url, regex)
      Mangad::print_feedback "\nbuscando #{url}" if @options.verbose
      result = []
      open(url, "User-Agent" => USER_AGENT) do |response|
        if response.status[1] == "OK"
          page = response.read
          page.scan(regex) do |r| # => try first regex
            if r.length < 2
              result << r[0]
            else
              result << r
            end
          end
          # binding.pry # DEBUG
          result = yield(result, page) if block_given?
        else
          puts Rainbow("ERRO: Servidor respondeu: #{response.status.inpect}").red
        end
      end
      result
    end

    def search(url, regex)
      Mangad::print_feedback "Iniciando busca em #{@options.site}"
      search_result = parse(url, regex)
      select_manga(search_result)
    end

    def select_manga(mangas)
      puts # just a new line for better output
      unless mangas.empty?
        mangas.each do |manga|
          print Rainbow("Você quer baixar #{manga[1]} [s/n]? ").bold.white
          res = $stdin.gets.chomp
          if res == 's'
            @manga_url = manga[0]
            @manga_name = manga[1]
            break
          elsif res != 'n'
            puts Rainbow("\tOpção invalida").lightcoral
            puts Rainbow("\tSaindo").blue
            exit(true)
          end
        end
      else
        raise MangaNotFoundError, "manga não encontrado"
      end
      raise MangaNotFoundError, "manga não encontrado" if @manga_url.nil?
    end

    def select_chapters
      Mangad::print_feedback "\nCapítulos:"
      @chapters.reverse_each.with_index do |chapter, index|
        Mangad::print_feedback "(#{index + 1})\t#{chapter[0]}"
      end
      answer = nil
      Mangad::print_feedback "\n#{@chapters.length} capitulos encontrados"
      loop do
        print Rainbow("\nQuais capitulos você quer baixar (o para opções)? ").bold.white
        answer = $stdin.gets.chomp
        if answer == "o" || answer.empty?
          puts Rainbow("\ttodos \t\t\t\t- baixar todos os capítulos").bold.white,
            Rainbow("\n\to \t\t\t\t- exibe opções").bold.white,
            Rainbow("\n\tinicio-fim \t\t\t- baixar intervalo selecionado").bold.white +
            Rainbow("\n\t\t\tEx: 0-10 - baixa do 0 ao 10").bold.white,
            Rainbow("\n\tcapitulo,capitulo,capitulo \t- baixar capitulos selecionados").bold.white +
            Rainbow("\n\t\t\tEx: 29,499,1 - ").bold.white +
            Rainbow("baixa capitulos 29, 499 e 1").bold.white
        elsif answer == "todos"
          Mangad::print_feedback "Baixando todos os capítulos" if @options.verbose
          break
        elsif answer =~ /(\d+)-(\d+)/
          b = Integer($2) <= @chapters.length ? Integer($2) * -1 : @chapters.length * -1
          e = Integer($1) * -1
          @chapters = @chapters[b..e]
          Mangad::print_feedback "Baixando capítulos do #{$1} ao #{$2}" if @options.verbose
          break
        elsif answer =~ /^(\d+,?)+$/
          answer = answer.split(',')
          aux = []
          # due the downloads being processed in reverse order (to make
          # it in crescent order) need reverse the choices
          answer.reverse_each do |c| 
            chp = @chapters[Integer(c) * -1]
            aux << chp unless chp.nil?
          end
          @chapters = aux
          Mangad::print_feedback "Baixando capítulos #{answer.to_s}" if @options.verbose
          break
        else
          puts Rainbow("\tOpção invalida").lightcoral
        end
      end
    end

    def imgs_donwload(chp_path, imgs_urls)
      imgs_urls.each do |url|
        original_filename =  url.slice(/(\w|[_-])+\.(png|jpg)/)
        img_path = "#{@options.download_dir}/#{chp_path}/#{original_filename}"
        unless File.exist? img_path
          Mangad::print_feedback "\n#{url}"
          pbar = nil
          open(url, 
               :content_length_proc => lambda {|size|
            if size.nil?
              pbar =  ProgressBar.create(:title => 'Baixando', 
                                         :starting_at => 20,
                                         :total => nil)
            else
              pbar =  ProgressBar.create(:total => size / Integer(16384), 
                                         :format => '%a %B %p%% %r KB/sec',
                                         :rate_scale => lambda { |rate| rate / 1024 })
            end
          },
          :progress_proc => lambda {|s|
            pbar.increment
          }) do |response|
            if response.status[1] == "OK"
              Mangad::print_feedback "Salvando imagem em:'#{img_path}'" if @options.verbose
              File.open(img_path, "wb") do |img| 
                img.puts response.read
              end
            end
          end
        end
      end
    end

    # check if the directory exists and 
    # create a directory relative to download dir
    def create_dir(name)
      dir_path = "#{@options.download_dir}/#{name}"
      Mangad::print_feedback "\nCriando diretorio '#{name}' em '#{dir_path}'" if @options.verbose
      unless Dir.exist? dir_path
        Dir.mkdir(dir_path) 
        puts if @options.verbose ## just a blank line for prettier output
      else
        Mangad::print_feedback "'#{name}' directorio ja existe" if @options.verbose
      end
    end
  end
end
