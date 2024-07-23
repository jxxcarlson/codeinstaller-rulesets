.PHONY: install uninstall deps

base:
	echo "Replacing demo/src/ with original/demo/src/..."
	cp -r original/demo/src/. demo/src/

app:
	echo "Replacing demo/src/ with original/demo/src/..."
	git checkout demo/
	cp -r original/demo/src/. demo/src/
	cp vendor-secret/Env.elm demo/src
	echo "Running elm-review rule in preview/src/ReviewConfig.elm ..."
	npx elm-review --config preview demo/src --fix-all





