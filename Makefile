# Neovim config. Lua is formatted with stylua (.stylua.toml).
# Plugin installs (lazy.nvim) are deliberately not part of any target.

.PHONY: setup dev test lint fmt typecheck build clean ci

setup:
	lefthook install

dev:
	@echo "dev: no-op, the config is loaded by running nvim itself"

test:
	@echo "test: no-op, no automated tests for the config"

lint:
	stylua --check .

fmt:
	stylua .

typecheck:
	@echo "typecheck: no-op, Lua has no type check configured here"

build:
	@echo "build: no-op, nothing to build"

clean:
	@echo "clean: no-op, no generated files"

ci: lint typecheck test build
