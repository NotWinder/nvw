-- Nix Language Server configuration
return {
	"nixd",
	enabled = nixCats("lsps.nix") or false,
	lsp = {
		filetypes = { "nix" },
		settings = {
			nixd = {
				nixpkgs = {
					expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
				},
				options = {
					nixos = {
						expr = nixCats.extra("nixdExtras.nixos_options"),
					},
					["home-manager"] = {
						expr = nixCats.extra("nixdExtras.home_manager_options"),
					},
				},
				formatting = {
					command = { "alejandra" },
				},
				diagnostic = {
					suppress = {
						"sema-escaping-with",
					},
				},
			},
		},
	},
}
