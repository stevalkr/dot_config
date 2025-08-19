{ package }:

{
  enable = true;

  inherit package;

  enableZshIntegration = false;
  enableBashIntegration = false;
  enableFishIntegration = false;

  defaultOptions = [
    "--height 40%"
    "--border"
    "--cycle"
    "--layout=reverse"
    "--tmux=center"
    "--preview-window=wrap"
    "--marker='*'"
    "--bind=alt-j:down"
    "--bind=alt-k:up"
  ];
}
