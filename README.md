# wiki2pages
This is a static generator using Hugo to transform GitHub/GitLab's wiki pages (or any similar markdown) into HTML to create documentation websites.

## Dependencies
You will need to install [`ce-dev`](https://github.com/codeenigma/ce-dev) (which relies on Docker and Docker Compose).

## Initial setup and first wiki
There is an example wiki here you can copy:

* https://github.com/codeenigma/wikis2pages-demo

Note in particular [the `.wikis2pages.yml` file in the repo root](https://github.com/codeenigma/wikis2pages-demo/blob/master/.wikis2pages.yml). Any repository that contains markdown files you wish to turn into HTML must have a `.wikis2pages.yml` file like this in the root. [See the `ce-provision` wiki config for another example.](https://github.com/codeenigma/ce-provision/blob/2.x/.wikis2pages.yml)

So assuming you have installed `ce-dev` *and* you have created a suitable `.wiki2pages.yml` config file in your target repository, you can fetch `wiki2pages` itself. In a suitable location on your computer:

```sh
git clone git@git.codeenigma.com:code-enigma/wikis2pages.git
cd wikis2pages
/bin/sh init.sh <my repo> [my branch]
```

For example, to build the documentation for `ce-provision` at version `2.x` you should use this command to initialise the documentation:

```sh
/bin/sh init.sh git@github.com:codeenigma/ce-provision.git 2.x
```

You can now run the included set-up script that configures and allows you to manage multiple `wiki2pages` projects at once. It is a simple command:

```sh
/bin/sh set-current.sh
```

If you want to just run Hugo again you can run `ce-dev deploy` any time.

## Where is my HTML?
There will be a `public` directory that gets generated in the repository root and this is the root of the Hugo web server. To understand where your code will be published you need to look at your `.wiki2pages.yml` file in the target repo. For example, the name of the project in [the file for `ce-deploy` is `ce-deploy-1.x-travis`](https://github.com/codeenigma/ce-deploy/blob/1.x/.wikis2pages.yml#L1) so that will be the directory name in `public`, because this is the value that will get copied into Hugo's `config.toml` file at runtime.

*However*, this will not necesarily be the URL in Hugo to access the files. That will be set according to the `base_url` variable in the same `.wiki2pages.yml` file, which is `https://codeenigma.github.io/ce-deploy-docs/1.x` in the `ce-deploy` example. The templated `hugo-daemon.sh` script, which you will find at `/opt/hugo-daemon.sh` on your `ce-dev` container, is recreated every time you run `set-current.sh` or the `ce-dev deploy` command, as you can see here:
* https://github.com/codeenigma/wikis2pages/blob/master/ce-dev/ansible/deploy.yml

And [we can see in the template for the Hugo daemon script](https://github.com/codeenigma/wikis2pages/blob/master/ce-dev/ansible/hugo-daemon.sh.j2#L23) that it uses the Jinja2 `urlsplit()` function to build the path Hugo will serve on, based on the contents of the `base_url` Ansible variable for the wiki, in this case `ce-deploy-docs/1.x`.

So to recap, the `ce-deploy` config file in the repo root, `.wiki2pages.yml`, looks like this:

```yaml
ce-deploy-1.x-travis:
  # other vars here...
  base_url: https://codeenigma.github.io/ce-deploy-docs/1.x
```

Which means the code will be built in the `wiki2pages` repo under the path `public/ce-deploy-1.x-travis/1.x` and will be served by Hugo on the URL http://wikis2pages-hugo:4000/ce-deploy-docs/1.x/

## Configuring ce-dev for easy browsing
It's possible to make it easier to browse your generated docs by adding URLs to your `ce-dev` configuration. By default this is configured for our `ce-deploy` and `ce-provision` projects, as we have not yet devised a means to automate it:

```yaml
  urls:
    - http://wikis2pages-hugo:4000/ce-deploy-docs/1.x
    - http://wikis2pages-hugo:4000/ce-provision-docs/2.x
```

But you can edit the file at [`wiki2pages/ce-dev/ce-dev.compose.yml`](https://github.com/codeenigma/wikis2pages/blob/master/ce-dev/ce-dev.compose.yml) and change the list of URLs there. Once that list is correct, run the following to rebuild `ce-dev`:

```sh
ce-dev destroy
ce-dev init
/bin/sh set-current.sh
ce-dev browse
```

The last command there, `ce-dev browse` should open the URLs defined automatically in your default browser.

## Adding another wiki
If you want to add a second wiki, just run the `init.sh` script again. For example, if I want to add a docs project for our `ce-deploy` product at version `1.x` I can just execute this command in the `wiki2pages` repo root:

```
/bin/sh init.sh git@github.com:codeenigma/ce-deploy.git 1.x
```

Once I have run that command, if I run `set-current.sh` again, as above, I will have my `ce-deploy` docs in the list of options.

# Known issues and limitations
GitLab wikis lets you reference pages in relative link by name instead of file path, and interpolates them at rendering time.
E.g.

```
[We are Code Enigma](We are Code Enigma)
```

This is a valid link in GitLab's wiki syntax and will "magically" be transformed to `/we-are-code-enigma` in the href (and `we-are-code-enigma.md` in the background).

However, this is not possible with Hugo, and all links need to be standardised:

```
[We are Code Enigma](we-are-code-enigma)
```

This ensures they will work in both places.
