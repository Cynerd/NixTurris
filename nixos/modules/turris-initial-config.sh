#!/usr/bin/env bash
set -eu

board="$1"


if ! [ -f /etc/nixos/flake.nix ]; then
	mkdir -p /etc/nixos
	cat >/etc/nixos/flake.nix <<-EOF
		{
		  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
		  inputs.nixturris.url = "git+https://git.cynerd.cz/nixturris";
		  outputs = { self, nixpkgs-stable, nixturris }: {
			nixosConfigurations.nixturris = nixturris.lib.nixturrisSystem {
			  nixpkgs = nixpkgs-stable;
			  board = "$board";
			  modules = [({ config, lib, pkgs, ... }: {
				# Optionally place your configuration here
			  })];
			};
		  };
		}
	EOF
	chmod 0600 /etc/nixos/flake.nix
	# TODO detect hardware and generate hardware specific file
fi
