require 'dmanga/options'
require 'dmanga/os'
require 'ruby-progressbar'
require 'open-uri'
require 'addressable/uri'

module DManga
  class SiteParserBase
    USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0"

    attr_accessor :manga_name, :manga_url,
      :chapters, :verbose

    def initialize(argv)
      @options = Options.new(argv)
      @manga_url = nil
      # manga_name is also used as manga directory name
      @manga_name = nil
      @chapters = nil
    end

    # Parse the html and extract links that match the pattern.
    # Can receive a block.
    def parse(url, regex)
      DManga::display_feedback "\nfetching #{url}" if @options.verbose
      result = []
      URI.open(url, "User-Agent" => USER_AGENT) do |response|
        if response.status[1] == "OK"
          DManga::display_feedback "parsing #{url}" if @options.verbose
          page = response.read
          page.scan(regex) do |r| # => try first regex
            if r.length < 2
              result << r[0]
            else
              result << r
            end
          end
          result = yield(result, page) if block_given?
        else
          DManga::display_error("ERRO: Servidor respondeu: #{response.status.inpect}")
        end
      end
      result
    end

    def search(url, regex)
      DManga::display_feedback "Iniciando busca em #{@options.site}"
      search_result = parse(url, regex)
      select_manga(search_result)
    end

    def select_manga(mangas)
      puts # just a new line for better output
      unless mangas.empty?
        mangas.each do |manga|
          DManga::display_prompt("Você quer baixar #{manga[1]} [s/n]? ")
          res = $stdin.gets.chomp
          if res == 's'
            @manga_url = manga[0]
            @manga_name = manga[1]
            break
          elsif res != 'n'
            DManga::display_warn("\tOpção invalida")
            DManga::display_feedback("\tSaindo")
            exit(true)
          end
        end
      else
        raise MangaNotFoundError, "manga não encontrado"
      end
      raise MangaNotFoundError, "manga não encontrado" if @manga_url.nil?
    end

    def select_chapters
      DManga::display_feedback "\nCapítulos:"
      @chapters.reverse_each.with_index do |chapter, index|
        DManga::display_feedback "(#{index + 1})\t#{chapter[0]}"
      end
      answer = nil
      DManga::display_feedback "\n#{@chapters.length} capitulos encontrados\n"
      loop do
        DManga::display_prompt("Quais capitulos você quer baixar? ")
        answer = $stdin.gets.chomp
        if answer == "o" || answer.empty?
          DManga::display_feedback(
            <<-EOS
  o                         - exibe opções.
    c                         - cancelar.
    todos                     - baixar todos os capítulos.
    inicio-fim                - baixar intervalo selecionado.
                                    Ex: 0-10 - baixa do 0 ao 10.
    capNum,capNum,capNum      - baixar capitulos selecionados.
                                    Ex: 29,499,1 - baixa capitulos 29, 499 e 1.
            EOS
          )
        elsif answer == "c"
          DManga::display_feedback("Saindo")
          exit true
        elsif answer == "todos"
          DManga::display_feedback "Baixando todos os capítulos" if @options.verbose
          break
        elsif answer =~ /(\d+)-(\d+)/
          b = Integer($2) <= @chapters.length ? Integer($2) * -1 : @chapters.length * -1
          e = Integer($1) * -1
          @chapters = @chapters[b..e]
          DManga::display_feedback "Baixando capítulos do #{$1} ao #{$2}" if @options.verbose
          break
        elsif answer =~ /^(\d+,?)+$/
          answer = answer.split(',')
          aux = []
          # downloads are processed in reverse order (to make
          # it in crescent order)so the answer is reversed too
          answer.reverse_each do |c|
            chp = @chapters[Integer(c) * -1]
            aux << chp unless chp.nil?
          end
          @chapters = aux
          DManga::display_feedback "Baixando capítulos #{answer.to_s}" if @options.verbose
          break
        else
          DManga::display_warn("\tOpção invalida")
        end
      end
    end

    # return a progressbar suitable to the user operating system
    def get_progressbar
      if DManga::OS.windows?
        return  ProgressBar.create(:title => 'Baixando',
                                   :starting_at => 20,
                                   :length => 70,
                                   :total => nil)
      else
        return  ProgressBar.create(:title => 'Baixando',
                                   :starting_at => 20,
                                   :total => nil)
      end
    end

    # download images to path relative to Downloads directory
    def imgs_download(chp_path, imgs_urls)
      imgs_urls.each do |url|
        original_filename =  url.slice(/(?u)(\w|[_-])+\.(png|jpg)/i)

        img_path = [@options.download_dir,
                    chp_path,
                    original_filename].join(File::SEPARATOR)
        unless File.exist? img_path
          encoded_url = Addressable::URI.encode(url)
          DManga::display_feedback "\n#{encoded_url}"
          pbar = get_progressbar
          URI.open(
            encoded_url, "User-Agent" => USER_AGENT,
            :progress_proc => lambda {|s| pbar.increment }
          ) do |response|
            if response.status[1] == "OK"
              DManga::display_feedback "Salvando imagem em:'#{img_path}'" if @options.verbose
              File.open(img_path, "wb") do |img|
                img.puts response.read
              end
            else
              puts "Error #{reponse.status}"
            end
          end
          puts
        end
      end
    end

    # check if the directory exists and
    # create a directory relative to downlaod directory
    def create_dir(relative_path)
      absolute_path = [@options.download_dir, relative_path].join(File::SEPARATOR)
      DManga::display_feedback "\nCriando diretorio '#{relative_path}' em '#{@options.download_dir}'" if @options.verbose
      unless Dir.exist? absolute_path
        Dir.mkdir(absolute_path)
        puts if @options.verbose ## just a blank line for prettier output
      else
        DManga::display_feedback "'#{relative_path}' directorio ja existe" if @options.verbose
      end
    end

    #def zip_chapter
    ## TODO
    #end

    # Returns the download destination directory
    def download_dir
      @options.download_dir
    end

    def remove_invalid_simbols(name)
      # windows OS dont accept these simbols in folder name
      name.gsub!(%r{[/\\:*?"<>|]|(\.+$)|(^\.+)}, '_')
    end
  end
end
