{pkgs, ...}:
let 
  add-pkg-to-shell = pkgs.writeShellScriptBin "pkg" ''
    if [ -z "$1" ]; then
      echo "Usage: pkg <package-name>"
      return 1
    fi
    echo "Adding package $1 to shell environment..."
    nix shell "nixpkgs#$1"

  '';

in 
{
  home.packages = with pkgs; [
    add-pkg-to-shell
  ];
}

