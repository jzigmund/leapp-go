#!/bin/bash

echo "TRIGGER DOCS"
changed_files=`git diff --name-only HEAD^`
echo "$changed_files"

if [[ $changed_files =~ .*api.yaml ]]; then
	echo "It's there"
	request_update_doc
else
	echo "Not there"
	exit 0
fi

request_update_doc() {
	echo "Init update doc"
	git init
	git config user.name "Ghost"
	git clone https://github.com/jzigmund/jzigmund.github.io.git
	cd jzigmund.github.io
	echo "$(pwd)"
	git checkout master
	echo "GIT STATUS: $(git status)"
	touch index.md
	git add -A .
	git commit -m "rebuild pages"
	git push -q origin HEAD:master
}
