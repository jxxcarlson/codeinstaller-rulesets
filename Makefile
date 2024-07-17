.PHONY: install uninstall deps

base-pages:
	echo "Replacing project-pages/src/ with original/project-pages/src/..."
	cp -r original/project-pages/src/. project-pages/src/

add-pages:
	echo "Adding pages..."
	cp -r original/project-pages/src/. project-pages/src/
	sed 's/\(\[ *( *NotesRoute, *"notes" *) *\)\(.*\)\(]\)/\1, ( JokesRoute, "jokes" ), ( QuotesRoute, "quotes" ) \3/' original/project-pages/src/Route.elm > temp && mv temp project-pages/src/Route.elm
	npx elm-review project-pages/src/ --fix-all

deps-pages:
	echo "Installing dependencies..."
	lamdera install elm/json
	lamdera install elm/time
	lamdera install mdgriffith/elm-ui
	lamdera install elmcraft/core-extra

base-magic-link:
	echo "Replacing project-magic-link/src/ with project-original/src/..."
	cp -r project-original/src/. project-magic-link/src/

add-magic-link:
	echo "Adding pages..."
	cp -r project-original/src/. project-magic-link/src/
	npx elm-review project-magic-link/src/ --fix-all




