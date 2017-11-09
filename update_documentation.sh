#!/bin/bash

request_update_doc() {
	echo "Init update doc"
	git clone https://github.com/jzigmund/jzigmund.github.io.git
	cd jzigmund.github.io
	git init
	git config user.name "Ghost"
	echo "$(pwd)"
	git checkout master
	echo "GIT STATUS: $(git status)"
	touch index.md
	git add -A .
	git commit -m "rebuild pages"
	git push -q origin HEAD:master
}

install_npm_deps() {
	echo "install nodejs"
	sudo apt-get install -y nodejs
	echo "NPM $(npm -v)"
	npm init
	npm install widdershins
}

convert_documentation() {
	node widdershins --harmony -y ./docs/api/api.yaml -o test.md
	if [[ $? -eq 1 ]]; then
		cat test.md
  else
		echo "Ups widdershins failed"
	fi
}

#checks if it's merge action
if [[ $TRAVIS_PULL_REQUEST == "false" && $TRAVIS_BRANCH == "master" ]]; then
	echo "Update documentation has been triggered"
	changed_files=`git diff --name-only HEAD^`
	echo "$changed_files"
	# checks if merged PR contains any changes in api.yaml
	if [[ $changed_files =~ .*api.yaml ]]; then
		install_npm_deps
		convert_documentation
		echo "It's there"
		#request_update_doc
	else
		echo "Not there"
		exit 0
	fi
else
	echo "Update documentation has not been triggered"
fi
