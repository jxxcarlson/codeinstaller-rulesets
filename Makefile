.PHONY: install uninstall deps

base:
	echo "Replacing src with src-original..."
	cp -r project-original/src/. project/src/

add-pages:
	echo "Adding pages..."
	cp -r project-original/src/. project/src/
	sed 's/\(\[ *( *NotesRoute, *"notes" *) *\)\(.*\)\(]\)/\1, ( JokesRoute, "jokes" ), ( QuotesRoute, "quotes" ) \3/' project/src/Route.elm > temp && mv temp project/src/Route.elm
	npx elm-review project/src/ --fix-all


sed:
	echo "Running sed ..."
	# sed 's/\(.*\)\(]\)/\1, (JokesRoute, "jokes"), (QuotesRoute, "quotes") \2/' src/Route.elm > temp && mv temp src/Route.elm
	cp -r project-original/. project/
	sed 's/\(.*\)\(]\)/\1, (JokesRoute, "jokes"), (QuotesRoute, "quotes") \2/' src/Route.elm > temp && mv temp src/Route.elm

deps:
	echo "Installing dependencies..."
	lamdera install elm/json
	lamdera install elm/time
	lamdera install mdgriffith/elm-ui
	lamdera install elmcraft/core-extra

update-original:
	echo "Updating src-original ..."
	cp -r project/. project-original/

copy-src:
	cp -r project/.  project-copy/

