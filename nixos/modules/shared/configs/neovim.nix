{ pkgs, package }:

{
  enable = true;

  inherit package;

  vimAlias = true;
  defaultEditor = true;

  withNodeJs = true;
  withPython3 = true;

  extraPackages = with pkgs; [
    imagemagick
  ];
}
