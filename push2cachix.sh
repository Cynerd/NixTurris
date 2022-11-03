#!/usr/bin/env bash
set -eu

system="$(nix eval --impure --raw --expr 'builtins.currentSystem')"

nix_build() {
	# Note: the dependencies can be garbage collected in the meantime. Thus do
	# not run GC when running this script.
	nix build --no-link ".#packages.$system.$1"
	nix eval --json ".#outPaths.$system.$1" | jq -r '.[]'
}

{
	#nix_build 'tarballMox'
	#nix_build 'tarballOmnia'
	nix_build 'crossTarballMox'
	nix_build 'crossTarballOmnia'
} | cachix push nixturris
