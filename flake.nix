{
  description = "Don't Risk It! project page — static site + media tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # miniserve rather than `python3 -m http.server`: the latter answers a
        # Range request with a full 200, so seeking inside the page's videos
        # silently does nothing when previewing locally.
        serve = pkgs.writeShellScriptBin "serve" ''
          port="''${1:-8000}"
          echo "Serving project page on http://localhost:$port"
          exec ${pkgs.miniserve}/bin/miniserve --index index.html --port "$port" .
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            poppler-utils   # pdftoppm / pdftotext — pull figures out of paper.pdf
            ffmpeg          # transcode and poster-frame the videos
            imagemagick     # crop and resize the extracted figures
            miniserve       # static file server used by `serve`, supports byte ranges
            serve
          ];

          shellHook = ''
            echo "dont-risk-it-planner.github.io dev shell"
            echo "  serve [port]   → preview the page (default http://localhost:8000)"
          '';
        };
      });
}
