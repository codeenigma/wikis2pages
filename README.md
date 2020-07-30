# wiki2pages

[![Build Status](https://api.travis-ci.com/codeenigma/wikis2pages.svg?branch=master)](https://api.travis-ci.com/codeenigma/wikis2pages.svg?branch=master)

This is a static generator using Hugo to transform github/gitlab's wiki pages (or any similar markdown) into HTML.

# Dependencies
You will need https://github.com/codeenigma/ce-dev (which relies on Docker and Docker Compose).

# Initial setup

Clone this repository, and run the following steps from the repo root.

```
git clone git@git.codeenigma.com:code-enigma/wikis2pages.git
cd wikis2pages
```

# Initialising a wiki

1. Create the needed configuration from a repository: `/bin/sh init.sh <my repo> [my branch]`. This expects the repository to contain a .wikis2pages.yml file.
2. Pick the project you want to work on: `/bin/sh set-current.sh`
3. Access the result with `ce-dev browse`

## Known issues and limitations
Gitlab wikis lets you references pages in relative link by name instead of file path, and interpolates them at rendering time.
Eg:

```
[We are Code Enigma](We are Code Enigma)
```
Is a valid link in Gitlab's wiki syntax and will "magically" be transformed to /we-are-code-enigma in the href (and we-are-code-enigma.md in the background).

However, this is not possible with Hugo, and all links need to be standardized:

```
[We are Code Enigma](we-are-code-enigma)
```
This ensures they will work in both places.