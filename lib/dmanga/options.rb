require 'optparse'
require 'dmanga/version'
module DManga
    class Options
        DEFAULT_DOWNLOAD_DIR = "#{ENV['HOME']}/Downloads"
        attr_reader :download_dir, :verbose, :manga
        attr_accessor :site
        def initialize(argv)
            @download_dir = DEFAULT_DOWNLOAD_DIR
            @verbose = false
            @site = "mangahost.cc"
            parse(argv)
            @manga = argv[0]
        end

        def parse(argv)
            OptionParser.new do |opts|
                opts.banner = "Uso: dmanga [opção] <nome do manga>"
                opts.separator   ""
                opts.separator   "Opções:"

                opts.on('--version', 'Exibe o numero de versão do programa.') do
                    puts "version #{DManga::VERSION}"
                    exit
                end

                opts.on('-v', '--verbose',
                        'Exibe informações da execução do programa.') do
                    @verbose = true
                end
                opts.on('-d', '--directory DIRETORIO',
                        'O diretorio de destino do download. Padrão é Downloads.') do |path|
                    @download_dir = path
                end
                opts.on('-h', '--help', 'Exibe esta tela.') do
                    puts opts
                    exit
                end

                argv = ['-h'] if argv.empty?
                opts.parse!(argv)
            end
        end
    end
end
