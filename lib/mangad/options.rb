require 'optparse'
module Mangad
  class Options
    DEFAULT_DOWNLOAD_DIR = "#{ENV['HOME']}/Downloads"
    attr_reader :download_dir, :verbose, :site, :manga
    def initialize(argv)
      @download_dir = DEFAULT_DOWNLOAD_DIR
      @verbose = false
      @site = "mangahost.net"
      parse(argv)
      @manga = argv[0]
    end

    def parse(argv)
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Uso: mangad [opção] <nome do manga>"
        opts.separator   ""
        opts.separator   "Opções:"

        opts.on('-v', '--verbose', 
                'Exibe informações detalhadas da execução do programa.') do
          @verbose = true
        end
        opts.on('-d', '--directory DOWNLOADDIRETORIO', 
                'O diretorio de destino do download. Padrão é Downloads.') do |path|
          @download_dir = path
        end
        opts.on('-h', '--help', 'Exibe esta tela.') do
          puts opt_parser
          exit
        end

        argv = ['-h'] if argv.empty?
        opts.parse!(argv)
      end
    end
  end
end
