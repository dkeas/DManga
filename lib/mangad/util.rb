module Mangad
  VERSION = "0.0.1"
  class MangaNotFoundError < RuntimeError
  end

  def self.print_error(message, error)
    puts "\t" + Rainbow("ERRO: #{message}").bold.white.bg(:darkred)
    puts "\t" + Rainbow("ERROR: #{error.message}").bold.white.bg(:darkred)
  end

  def self.print_feedback(str)
    puts Rainbow(str).magenta.bright
  end

end
