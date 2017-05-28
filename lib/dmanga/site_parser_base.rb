require 'dmanga/options'
require 'dmanga/os'
require 'ruby-progressbar'
require 'open-uri'
# require 'pry'
# require 'formatador'

module DManga
    class SiteParserBase
        USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0"

        attr_accessor :manga_name, :manga_url,
            :chapters, :verbose

        def initialize(argv)
            @options = Options.new(argv)
            @manga_url = nil
            @manga_name = nil
            @chapters = nil
        end

        # Parse the html and colect links that match the pattern.
        # Can receive a block.
        def parse(url, regex)
            DManga::display_feedback "\nfetching #{url}" if @options.verbose
            result = []
            open(url, "User-Agent" => USER_AGENT) do |response|
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

        def imgs_donwload(chp_path, imgs_urls)
            imgs_urls.each do |url|
                original_filename =  url.slice(/(\w|[_-])+\.(png|jpg)/)
                img_path = "#{@options.download_dir}/#{chp_path}/#{original_filename}"
                unless File.exist? img_path
                    DManga::display_feedback "\n#{url}"
                    pbar = nil
                    open(url, 
                         :content_length_proc => lambda {|size|
                        if size.nil?
                            if DManga::OS.windows?
                                pbar =  ProgressBar.create(:title => 'Baixando', 
                                                           :starting_at => 20,
                                                           :length => 70,
                                                           :total => nil)
                            else
                                pbar =  ProgressBar.create(:title => 'Baixando', 
                                                           :starting_at => 20,
                                                           :total => nil)
                            end
                        else
                            if DManga::OS.windows?
                                pbar =  ProgressBar.create(:total => size / Integer(16384), 
                                                           :format => '%a %B %p%% %r KB/sec',
                                                           :rate_scale => lambda { |rate| 
                                                               rate / 1024 },
                                                                   length: 70)
                            else
                                pbar =  ProgressBar.create(:total => size / Integer(16384), 
                                                           :format => '%a %B %p%% %r KB/sec',
                                                           :rate_scale => lambda { |rate| 
                                                               rate / 1024 })
                            end
                        end
                    },
                    :progress_proc => lambda {|s|
                        pbar.increment
                    }) do |response|
                        if response.status[1] == "OK"
                            DManga::display_feedback "Salvando imagem em:'#{img_path}'" if @options.verbose
                            File.open(img_path, "wb") do |img| 
                                img.puts response.read
                            end
                        end
                    end
                    puts
                end
            end
        end

        # check if the directory exists and 
        # create a directory relative to download dir
        def create_dir(name)
            dir_path = [@options.download_dir, name].join(File::SEPARATOR)
            DManga::display_feedback "\nCriando diretorio '#{name}' em '#{dir_path}'" if @options.verbose
            unless Dir.exist? dir_path
                Dir.mkdir(dir_path) 
                puts if @options.verbose ## just a blank line for prettier output
            else
                DManga::display_feedback "'#{name}' directorio ja existe" if @options.verbose
            end
        end

        def zip_chapter
            
        end

        def download_dir
            @options.download_dir
        end
    end
end
