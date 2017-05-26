# module to set operating system
module DManga
    module OS
        def self.windows?
            /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
        end
    end
end
