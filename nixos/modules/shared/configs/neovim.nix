{ pkgs, neovim-src }:

let
  lib = pkgs.lib;

  deps = lib.pipe "${neovim-src}/cmake.deps/deps.txt" [
    builtins.readFile
    (lib.splitString "\n")
    (map (builtins.match "([A-Z0-9_]+)_(URL|SHA256)[[:space:]]+([^[:space:]]+)[[:space:]]*"))
    (lib.remove null)
    (lib.flip builtins.foldl' { } (
      acc: matches:
      let
        name = lib.toLower (builtins.elemAt matches 0);
        key = lib.toLower (builtins.elemAt matches 1);
        value = lib.toLower (builtins.elemAt matches 2);
      in
      acc
      // {
        ${name} = acc.${name} or { } // {
          ${key} = value;
        };
      }
    ))
    (builtins.mapAttrs (lib.const pkgs.fetchurl))
  ];

  # The following overrides will only take effect for linux hosts
  linuxOnlyOverrides = lib.optionalAttrs pkgs.stdenv.isLinux {
    gettext = pkgs.gettext.overrideAttrs {
      # FIXME: nixpkgs' gettext is now at version 0.22.5 whereas neovim's is pinned at 0.20.5
      # Overriding the source leads to a build error of gettext.
      # Neovim seems to build fine with nixpkgs' gettext, so we use that in the meantime.
      # src = deps.gettext;
    };
  };

  overrides = {
    libuv = pkgs.libuv.overrideAttrs {
      # FIXME: overriding libuv causes high CPU usage on darwin
      # https://github.com/nix-community/neovim-nightly-overlay/issues/538
      # src = deps.libuv;
    };

    lua = pkgs.luajit;

    tree-sitter =
      let
        cargoHash = "sha256-kHYLaiCHyKG+DL+T2s8yumNHFfndrB5aWs7ept0X4CM=";
      in
      (pkgs.tree-sitter.overrideAttrs (oa: {
        src = deps.treesitter;
        version = "bundled";
        inherit cargoHash;
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          name = "${oa.pname}-cargo-deps";
          src = deps.treesitter;
          hash = cargoHash;
        };
        # Disable patches applied by the nixpkgs tree-sitter derivation as they clash with this revision of TS.
        # The equivalent patching is done below in `postPatch`
        patches = [ ];

        # clang is needed by the quickjs-sys crate to compile quickjs
        nativeBuildInputs = [
          pkgs.clang
        ]
        ++ oa.nativeBuildInputs;
        env.LIBCLANG_PATH = "${lib.getLib pkgs.libclang}/lib";

        postPatch = ''
          ${oa.postPatch}
          sed -e 's/playground::serve(.*$/println!("ERROR: web-ui is not available in this nixpkgs build; enable the webUISupport"); std::process::exit(1);/' \
              -i crates/cli/src/main.rs
        '';
      }));

    treesitter-parsers =
      let
        grammars = lib.filterAttrs (name: _: lib.hasPrefix "treesitter_" name) deps;
      in
      lib.mapAttrs' (
        name: value: lib.nameValuePair (lib.removePrefix "treesitter_" name) { src = value; }
      ) grammars;
  }
  // linuxOnlyOverrides;
in
{
  enable = true;

  package = (pkgs.neovim-unwrapped.override overrides).overrideAttrs (oldAttrs: {
    version = "nightly";
    src = neovim-src;

    preConfigure = ''
      ${oldAttrs.preConfigure}
      substituteInPlace cmake.config/versiondef.h.in \
        --replace-fail '@NVIM_VERSION_PRERELEASE@' '-nightly+${neovim-src.shortRev or "dirty"}'
    '';
  });

  vimAlias = true;
  defaultEditor = true;

  withNodeJs = true;
  withPython3 = true;

  extraPackages = with pkgs; [
    imagemagick
  ];
}
