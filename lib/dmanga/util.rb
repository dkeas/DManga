require 'formatador'
module DManga
    class MangaNotFoundError < RuntimeError
    end

    def self.display_error(message, error)
        Formatador.display_line("\t[_red_][white][bold]ERRO: #{message}.[/]")
        Formatador.display_line("\t[_red_][white][bold]ERROR: #{error.message}.[/]")
    end

    def self.display_feedback(str)
        Formatador.display_line("[magenta][bold]#{str}[/]")
    end

    def self.display_prompt(str)
        Formatador.display("[white][bold]#{str}[/]")
    end

    def self.display_warn(str)
        Formatador.display_line("[red][bold]#{str}[/]")
    end
end
