# wiki2pages

This is a static generator using Hugo to transform Gitlab's wiki pages into a static website.

# Dependencies
You will need https://github.com/codeenigma/ce-dev (which relies on Docker and Docker Compose).

# Initial setup

Clone this repository, and run the following steps from the repo root.

```
git clone git@git.codeenigma.com:code-enigma/wikis2pages.git
cd wikis2pages
```


- Create the initial configuration: `ce-dev init`
- Start the containers: `ce-dev start`
- Install: `ce-dev provision`

# Initialising a wiki

Look in the the ce-dev/ansible/wikis for a list of available wikis.
Example, targetting the "design-and-frontend-reference" wiki.

## 1. Create a symlink
From the root of the repo:
```
cd ce-dev/ansible/wikis
ln -s ./design-and-frontend-reference.yml current.yml
```

**The symlink MUST be relative, to function within the container**


## 2. Clone the wiki content

You'll need to manually clone the wiki to the location specified as the "dest" in the matching .yml file, under content. *Due to SSH access restrictions from within the container, this can't yet be automated.*

From the root of the repo:
```
cd content
git clone git@git.codeenigma.com:code-enigma/documentation/design-and-frontend-reference.wiki.git
```

## 3. Initialize the wiki configuration.

Simply call `ce-dev deploy`. You can then access the generated content with `ce-dev browse`

## Adding a new wiki
Simply create a matching .yml file under ce-dev/ansible/wikis

## Known issues and limitations
Gitlab wikis lets you references pages in relative link by name instead of file path, and interpolates them at rendering time.
Eg:

```
[We are Code Enigma](We are Code Enigma)
```
Is a valid link in Gitlab's wiki syntax and will "magically" be transformed to /we-are-code-enigma in the href (and we-are-code-enigma.md in the background).

However, this is not possible with Hugo, and all links need to be standardized:

```
[We are...](we-are-code-enigma)
```
This ensures they will work in both places.