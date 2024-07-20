.PHONY: install uninstall deps

base-pages:
	echo "Replacing project-pages/src/ with original/project-pages/src/..."
	cp -r original/project-pages/src/. project-pages/src/

add-pages:
	echo "Adding pages..."
	cp -r original/project-pages/src/. project-pages/src/
	npx elm-review project-pages/src/ --fix-all

deps-pages:
	echo "Installing dependencies..."
	lamdera install elm/json
	lamdera install elm/time
	lamdera install mdgriffith/elm-ui
	lamdera install elmcraft/core-extra

base-magic-link:
	echo "Replacing project-magic-link/src/ with project-original/src/..."
	cp -r original/project-magic-link/src/. project-magic-link/src/

deps-magic-link-auth:
	echo "Installing dependencies for magic-link-auth..."
	lamdera install elm/bytes
	lamdera install elm/http


magic-link-auth:
	echo "Adding magic-link-auth..."
	cp -r original/project-magic-link/src/. project-magic-link/src/
	npx elm-review project-magic-link/src/ --fix-all




