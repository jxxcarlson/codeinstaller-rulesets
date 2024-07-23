.PHONY: install uninstall deps

base:
	echo "Replacing project-pages/src/ with original/project-pages/src/..."
	cp -r original/demo/src/. demo/src/

add-pages:
	echo "Adding pages..."
	cp -r original/demo/src/. demo/src/
	npx elm-review project-pages/src/ --fix-all

auth:
	git checkout demo/
	cp -r original/demo/src/. demo/src/
	cp vendor-secret/Env.elm demo/src
	npx elm-review --config preview demolam/src --fix-all


magic-link-auth:
	echo "Adding magic-link-auth..."
	cp -r original/project-magic-link/src/. project-magic-link/src/
	npx elm-review project-magic-link/src/ --fix-all




