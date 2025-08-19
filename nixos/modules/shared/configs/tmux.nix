{
  enable = true;

  mouse = true;
  keyMode = "vi";
  clock24 = true;
  focusEvents = true;
  historyLimit = 4096;

  extraConfig = ''
    set -s  extended-keys on
    set -g  visual-activity off
    set -gq allow-passthrough on
    set -g default-terminal   'tmux-256color'
    set -as terminal-features 'xterm*:extkeys'
    set -a  terminal-features 'xterm-256color:RGB'

    set -g update-environment "MULTIPLEXER MULTIPLEXAER_LIST \
                              I3SOCK \
                              ZELLIJ_PANE_ID ZELLIJ \
                              KITTY_WINDOW_ID KITTY_LISTEN_ON KITTY_PID \
                              WEZTERM_PANE WEZTERM_UNIX_SOCKET WEZTERM_EXECUTABLE"

    bind-key -n C-h if -F '#{@pane-is-vim}' { send-keys C-h } { run-shell 'multiplexer activate_pane left' }
    bind-key -n C-j if -F '#{@pane-is-vim}' { send-keys C-j } { run-shell 'multiplexer activate_pane down' }
    bind-key -n C-k if -F '#{@pane-is-vim}' { send-keys C-k } { run-shell 'multiplexer activate_pane up' }
    bind-key -n C-l if -F '#{@pane-is-vim}' { send-keys C-l } { run-shell 'multiplexer activate_pane right' }

    bind-key -n C-H if -F '#{@pane-is-vim}' { send-keys C-S-h } { run-shell 'multiplexer resize_pane left' }
    bind-key -n C-J if -F '#{@pane-is-vim}' { send-keys C-S-j } { run-shell 'multiplexer resize_pane down' }
    bind-key -n C-K if -F '#{@pane-is-vim}' { send-keys C-S-k } { run-shell 'multiplexer resize_pane up' }
    bind-key -n C-L if -F '#{@pane-is-vim}' { send-keys C-S-l } { run-shell 'multiplexer resize_pane right' }

    bind-key -n C-S-h if -F '#{@pane-is-vim}' { send-keys C-S-h } { run-shell 'multiplexer resize_pane left' }
    bind-key -n C-S-j if -F '#{@pane-is-vim}' { send-keys C-S-j } { run-shell 'multiplexer resize_pane down' }
    bind-key -n C-S-k if -F '#{@pane-is-vim}' { send-keys C-S-k } { run-shell 'multiplexer resize_pane up' }
    bind-key -n C-S-l if -F '#{@pane-is-vim}' { send-keys C-S-l } { run-shell 'multiplexer resize_pane right' }

    bind-key -T copy-mode-vi C-h if -F '#{@pane-is-vim}' { send-keys C-h } { run-shell 'multiplexer activate_pane left' }
    bind-key -T copy-mode-vi C-j if -F '#{@pane-is-vim}' { send-keys C-j } { run-shell 'multiplexer activate_pane down' }
    bind-key -T copy-mode-vi C-k if -F '#{@pane-is-vim}' { send-keys C-k } { run-shell 'multiplexer activate_pane up' }
    bind-key -T copy-mode-vi C-l if -F '#{@pane-is-vim}' { send-keys C-l } { run-shell 'multiplexer activate_pane right' }

    bind-key -T copy-mode-vi C-H if -F '#{@pane-is-vim}' { send-keys C-S-h } { run-shell 'multiplexer resize_pane left' }
    bind-key -T copy-mode-vi C-J if -F '#{@pane-is-vim}' { send-keys C-S-j } { run-shell 'multiplexer resize_pane down' }
    bind-key -T copy-mode-vi C-K if -F '#{@pane-is-vim}' { send-keys C-S-k } { run-shell 'multiplexer resize_pane up' }
    bind-key -T copy-mode-vi C-L if -F '#{@pane-is-vim}' { send-keys C-S-l } { run-shell 'multiplexer resize_pane right' }

    bind-key -T copy-mode-vi C-S-h if -F '#{@pane-is-vim}' { send-keys C-S-h } { run-shell 'multiplexer resize_pane left' }
    bind-key -T copy-mode-vi C-S-j if -F '#{@pane-is-vim}' { send-keys C-S-j } { run-shell 'multiplexer resize_pane down' }
    bind-key -T copy-mode-vi C-S-k if -F '#{@pane-is-vim}' { send-keys C-S-k } { run-shell 'multiplexer resize_pane up' }
    bind-key -T copy-mode-vi C-S-l if -F '#{@pane-is-vim}' { send-keys C-S-l } { run-shell 'multiplexer resize_pane right' }

    unbind-key -T copy-mode-vi MouseDragEnd1Pane
    bind-key   -T copy-mode-vi Escape 'send-keys -X cancel'
    bind-key   -T copy-mode-vi v      'send-keys -X begin-selection'
    bind-key   -T copy-mode-vi y      'send-keys -X copy-pipe-and-cancel "pbcopy"'
    bind-key   -T copy-mode-vi C-v    'send-keys -X rectangle-toggle ; send-keys -X begin-selection'
  '';
}
