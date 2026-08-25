{
  description = "Kestrel Linux course toolchain -- pinned package closure for the course image.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.buildEnv {
          name = "kestrel-env";

          # Everything the course needs that is NOT part of Chapter 13's
          # deliberately-missing set (ncdu, ripgrep, tldr, ncal) and NOT part of
          # Debian's user/account plumbing (passwd, adduser, sudo, util-linux,
          # man-db) which stays on apt so chapters 10 and 13 behave as written.
          paths = with pkgs; [
            # Needed before apt can run: the Ubuntu base image ships no CA
            # bundle, and the pinned archive snapshot is HTTPS-only.
            cacert
            coreutils-full
            findutils
            plocate
            gnugrep
            gnused
            gawk
            diffutils
            less
            tree
            file
            procps
            psmisc
            htop
            lsof
            curl
            vim
            nano
            jq
            shellcheck
            gnutar
            gzip
            bzip2
            xz
          ];

          # Pull in the man output of every package above; without this the Dig
          # tier of the lessons has nothing to read.
          extraOutputsToInstall = [ "man" "doc" ];

          # buildEnv only merges directories it is told about.
          pathsToLink = [ "/bin" "/share/man" "/share/info" "/share/doc" "/etc" "/libexec" ];
        };
      });
    };
}
