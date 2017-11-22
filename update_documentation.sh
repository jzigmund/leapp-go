#!/bin/bash

request_update_doc() {
	echo "Init update doc"
	git clone "https://$GH_TOKEN@github.com/jzigmund/jzigmund.github.io.git"
	cd jzigmund.github.io
	git init
	git config user.name "Travis-CI"
	echo "PWD $(pwd)"
	echo "GIT STATUS: $(git status)"
	cp ../index.html.md shins/source/index.html.md
	echo "GIT STATUS: $(git status)"
	cd shins
	node /home/travis/.nvm/versions/node/v7.4.0/bin/shins --minify
	git add -A
	echo "GIT INFO $(git remote -v)"
	echo "GIT STATUS: $(git status)"
	echo "REV $commit"
	git commit -m "rebuild pages at $commit"
	git push origin HEAD:master
}

install_npm_deps() {
	echo "NPM $(npm -v)"
	npm install -g widdershins shins
}

convert_documentation() {
	node /home/travis/.nvm/versions/node/v7.4.0/bin/widdershins -y ./docs/api/api.yaml -o index.html.md
	echo "NVM - $(NVM_PATH) \nNODE - $(NODE_PATH)"
	echo "PRINT ENV $(printenv)"
}

#checks if it's merge action
if [[ $TRAVIS_PULL_REQUEST == "false" && $TRAVIS_BRANCH == "master" ]]; then
	echo "Update documentation has been triggered"
	changed_files=`git diff --name-only HEAD^`
	commit=$(git rev-parse --short HEAD)
	echo "$changed_files"
	# checks if merged PR contains any changes in api.yaml
	if [[ $changed_files =~ .*api.yaml ]]; then
		install_npm_deps
		convert_documentation
		echo "It's there"
		request_update_doc
		exit 0
	else
		echo "Not there"
		exit 0
	fi
else
	echo "Update documentation has not been triggered"
fi
