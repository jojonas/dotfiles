if status is-interactive
    # Commands to run in interactive sessions can go here

    if test "$TERM" = "xterm-kitty"
        alias ssh="kitty +kitten ssh"
    end

    function mkcd -d "Create a directory and set CWD"
        command mkdir $argv
        if test $status = 0
            switch $argv[(count $argv)]
                case '-*'

                case '*'
                    cd $argv[(count $argv)]
                    return
            end
        end
    end
end
