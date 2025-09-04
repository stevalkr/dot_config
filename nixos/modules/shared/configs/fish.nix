{ pkgs }:

{
  enable = true;

  plugins = [
    {
      name = "fzf-fish";
      src = pkgs.fishPlugins.fzf-fish.src;
    }

    {
      name = "bass";
      src = pkgs.fishPlugins.bass.src;
    }

    {
      name = "ros";
      src = pkgs.runCommand "ros-integration" { } ''
        mkdir -p $out/conf.d/
        mkdir -p $out/completions/

        cat <<EOF > $out/conf.d/ros.fish
        if test "\$ROS_VERSION" = 1 && set -q ROS_PACKAGE_PATH
            set -l complete_file \$ROS_PACKAGE_PATH/rosbash/rosfish
            if test -f \$complete_file
                source \$complete_file
            end
        end
        EOF

        cat <<EOF > $out/completions/ros2.fish
        if test "\$ROS_VERSION" = 2 && type -q register-python-argcomplete
            register-python-argcomplete --shell fish ros2 | source
            register-python-argcomplete --shell fish colcon | source
        end
        EOF
      '';
    }
  ];

  functions = {
    ef = {
      body = ''
        cd $argv
        ls
      '';
      wraps = "cd";
      description = "Change directory and list files";
    };

    mkd = {
      body = ''
        mkdir $argv
        cd $argv[1]
      '';
      wraps = "mkdir";
      description = "Make directory and change into it";
    };

    ws = {
      body = ''
        switch (count $argv)
            case 0
                cd ~/Documents
            case 1
                switch $argv[1]
                    case stu
                        cd ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/STU
                    case play
                        cd ~/Playgrounds
                    case icloud
                        cd ~/Library/Mobile\ Documents
                    case sing-box
                        cd ~/Library/Mobile\ Documents/iCloud\~io\~nekohasekai\~sfavt/Documents
                    case config
                        cd ~/.config
                    case devkit
                        cd ~/.devkit
                    case '*'
                        echo Unknown argument: $argv[1]. Defaulting to ~/Documents.
                        cd ~/Documents
                end
            case '*'
                echo 'Too many arguments. Only one argument is supported.'
                return 1
        end
        ls
      '';
      description = "Change to workspace directory";
    };

    s = {
      body = ''
        __fish_set_user_var IS_SSH true

        command ssh $argv

        __fish_set_user_var IS_SSH false
      '';
      wraps = "ssh";
    };

    t = {
      body = ''
        set -l ori_multiplexer_list $MULTIPLEXER_LIST
        set -gx MULTIPLEXER_LIST "tmux,$ori_multiplexer_list"
        __fish_set_user_var IS_TMUX true

        command tmux $argv

        set -gx MULTIPLEXER_LIST $ori_multiplexer_list
        __fish_set_user_var IS_TMUX false
      '';
      wraps = "tmux";
    };

    z = {
      body = ''
        set -l ori_multiplexer_list $MULTIPLEXER_LIST
        set -gx MULTIPLEXER_LIST "zellij,$ori_multiplexer_list"
        __fish_set_user_var IS_ZELLIJ true

        command zellij $argv

        set -gx MULTIPLEXER_LIST $ori_multiplexer_list
        __fish_set_user_var IS_ZELLIJ false
      '';
      wraps = "zellij";
    };

    prof = {
      body = ''
        if test (count $argv) -lt 2
            echo "Usage: prof [cpu|leaks] <program> [arguments...]" 1>&2
            return 1
        end

        set mode $argv[1]
        if not string match -q -r '^(cpu|leaks)$' -- $mode
            echo "Error: Invalid mode '$mode'. Use 'cpu' or 'leak'." 1>&2
            return 1
        end
        set -e argv[1]

        set program (realpath -q $argv[1])
        if not test -f $program
            set program (which $argv[1])
        end
        if not test -f $program
            echo "Error: $program not found" 1>&2
            return 1
        end
        set -e argv[1]

        switch $mode
            case cpu
                set output "/tmp/cpu_profile_$(whoami)_$(basename $program).trace"
                echo "Profiling $program into $output" 1>&2

                rm -rf $output
                xcrun xctrace record \
                    --template 'CPU Profiler' \
                    --no-prompt \
                    --output $output \
                    --target-stdout - \
                    --launch -- $program $argv
                open $output

            case leaks
                set output "/tmp/leaks_$(whoami)_$(basename $program).trace"
                echo "Profiling $program into $output" 1>&2

                rm -rf $output
                xcrun xctrace record \
                    --template 'Leaks' \
                    --no-prompt \
                    --output $output \
                    --target-stdout - \
                    --launch -- $program $argv
                open $output

            case '*'
                echo "Unknown profiling mode: '$mode'" 1>&2
        end
      '';
    };

    __fish_set_user_var = {
      body = ''
        if type -q base64
            printf "\033]1337;SetUserVar=%s=%s\007" "$argv[1]" (echo -n "$argv[2]" | base64)
        end
      '';
      description = "Set a user variable for the terminal";
    };

    fish_greeting = {
      body = ''
        if set -q IN_NIX_SHELL
            return
        end

        echo Good Enough is Good Enough!

        set -l tmux_info $(tmux ls 2>/dev/null | wc -l | string trim)
        if test $tmux_info -gt 0
            set_color yellow
            echo -n "$tmux_info"
            set_color green
            echo " tmux session(s) running."
            set_color normal
        end
      '';
      description = "Custom greeting for Fish shell";
    };

    fish_prompt = {
      body = ''
        set -l last_pipestatus $pipestatus
        set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
        set -l normal (set_color normal)
        set -q fish_color_status
        or set -g fish_color_status red

        # Color the prompt differently when we're root
        set -l color_cwd $fish_color_cwd
        set -l suffix '~>'
        if functions -q fish_is_root_user; and fish_is_root_user
            if set -q fish_color_cwd_root
                set color_cwd $fish_color_cwd_root
            end
            set suffix '#'
        end

        # Write pipestatus
        # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
        set -l bold_flag --bold
        set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
        if test $__fish_prompt_status_generation = $status_generation
            set bold_flag
        end
        set __fish_prompt_status_generation $status_generation
        set -l status_color (set_color $fish_color_status)
        set -l statusb_color (set_color $bold_flag $fish_color_status)
        set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

        # echo -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "

        # Line 1
        echo
        set_color yellow
        printf '%s' $USER
        set_color normal
        printf ' at '

        set_color magenta
        echo -n (prompt_hostname)
        set_color normal
        printf ' in '

        set_color $color_cwd
        printf '%s' (prompt_pwd -D 3)
        set_color normal

        set -g vcs (fish_vcs_prompt)
        if test "$vcs" != ""
          printf ' on'
          set_color cyan
          printf '%s' $vcs
        end
        set_color normal
        printf ' %s ' $prompt_status


        # Line 2
        printf '\n'
        if test -n "$VIRTUAL_ENV"
            printf "[%s] " (set_color blue)(basename $VIRTUAL_ENV)(set_color normal)
        end
        if test -n "$IN_NIX_SHELL"
            if test -z "$DK_ENV"
                set DK_ENV "shell"
            end
            printf "<%s> " (set_color blue)"nix $DK_ENV"(set_color normal)
        end
        if test -n "$PIXI_PROMPT"
            if test -z "$DK_ENV"
                set DK_ENV "shell"
            end
            printf "<%s>" (set_color blue)"pixi $DK_ENV"(set_color normal)
        end
        if test -n "$CONDA_PROMPT_MODIFIER"
            printf "%s" (set_color blue)"$CONDA_PROMPT_MODIFIER"(set_color normal)
        end

        printf '%s ' $suffix
        set_color normal
      '';
      description = "Write out the prompt";
    };
  };

  interactiveShellInit = ''
    # Set Options for fzf-fish
    set -gx fzf_directory_opts '--bind=ctrl-d:reload(fd --type d --type l --color=always --strip-cwd-prefix)' '--bind=ctrl-f:reload(fd --color=always)'

    # Auto-reload environment variables from tmux
    if set -q TMUX
        function renew_env --on-event fish_focus_in
            set -l vars_to_sync MULTIPLEXER MULTIPLEXAER_LIST \
                I3SOCK \
                ZELLIJ_PANE_ID ZELLIJ \
                KITTY_WINDOW_ID KITTY_LISTEN_ON KITTY_PID \
                WEZTERM_PANE WEZTERM_UNIX_SOCKET WEZTERM_EXECUTABLE

            for var_name in $vars_to_sync
                set -l tmux_output $(command tmux showenv $var_name 2>/dev/null)
                if test -n "$tmux_output"
                    set -l parts $(string split -m 1 '=' -- $tmux_output)

                    if test (count $parts) -eq 2
                        set -gx $var_name $parts[2]
                    end
                end
            end
        end
    end
  '';
}
