{ ssh-signer }:

{
  enable = true;

  aliases = {
    cm = "commit";
    st = "status";
    ll = "logline";
    logline = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
  };

  userName = "Steve Walker";
  userEmail = "65963536+stevalkr@users.noreply.github.com";

  signing = {
    format = "ssh";
    signer = ssh-signer;
    signByDefault = true;
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+PplmTdhrADgBUxkqPNfYThsEI/5DC48BuCxwjsZw6";
  };

  ignores = [
    ".cache"
    ".vscode"
    "compile_commands.json"

    ".env"
    ".envrc"
    ".direnv"

    "AGENT.md"
    "CLAUDE.md"
    "GEMINI.md"

    ".DS_Store"
    "Icon?"
    "Thumbs.db"
    "ehthumbs.db"
  ];

  extraConfig = {
    core.editor = "nvim";
    init.defaultBranch = "main";
  };
}
