.PHONY: install uninstall deps

base:
	echo "Replacing project-pages/src/ with original/project-pages/src/..."
	cp -r original/demo/src/. demo/src/

pages:
	echo "Adding pages..."
	cp -r original/demo/src/. demo/src/
	npx elm-review project-pages/src/ --fix-all

auth:
	git checkout demo/
	cp -r original/demo/src/. demo/src/
	cp vendor-secret/Env.elm demo/src
	npx elm-review --config preview demo/src --fix-all





