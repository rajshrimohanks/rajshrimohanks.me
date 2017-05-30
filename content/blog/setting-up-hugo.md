---
date: 2017-05-30T18:08:44.000Z
title: Setting up a slick new blog - 2 - Setting up Hugo
draft: false
---

Alright now! Let's continue from where I [last left]({{< relref "discovering-hugo.md" >}}).

So having decided on Hugo to be the backbone for the blog, the next step is to set it up. Since Hugo is built using Go and since Go is a statically typed _compiled_ language, Hugo comes in a nice little `.exe` zipped into an archive for Windows users. Just rename the file to `hugo.exe` for ease of use, throw it into a folder and add the folder to the `PATH` in environment variables. Linux users have their life easier as always due to their package managers. So in Ubuntu and derivatives, it's as simple as `sudo apt-get install hugo`. There are other ways to install too. And you can find all about it [here](https://gohugo.io/overview/installing/).

Once that is done, the next step is to restart the terminal (not really necessary in Linux) or command prompt and we are good to go. To be additionally sure, we can type `hugo version` in the command prompt/terminal and it should print something like this:

```bash
$ hugo version
Hugo Static Site Generator v0.20.7 windows/amd64 BuildDate: 2017-05-15T19:57:13+05:30
```

Moving on, the next step is to set up the project directory.

## Scaffolding a project directory

Hugo includes a built in tool to scaffold out a project directory which we can use to set up our project right away. All we've to do is run `hugo new site <your-site-name>` to let Hugo generate a project structure:

```
$ hugo new site first-hugo-site
Congratulations! Your new Hugo site is created in F:\my-works\first-hugo-site.

Just a few more steps and you're ready to go:

1. Download a theme into the same-named folder.
   Choose a theme from https://themes.gohugo.io/, or
   create your own with the "hugo new theme <THEMENAME>" command.
2. Perhaps you want to add some content. You can add single files
   with "hugo new <SECTIONNAME>\<FILENAME>.<FORMAT>".
3. Start the built-in live server via "hugo server".

Visit https://gohugo.io/ for quickstart guide and full documentation.
```

This creates a directory structure like so:

```
$ cd first-hugo-site\

$ tree /F
Folder PATH listing for volume HDD-Works
Volume serial number is 603C-2E4B
F:.
│   config.toml
│
├───archetypes
├───content
├───data
├───layouts
├───static
└───themes
```

(I used Windows. In Linux, you've to use `tree -a` to reflect the same output.)

Here, the `archetypes`, `data` and `layouts` folders are irrelevant for starters. The rest of the stuff is important:

- `content\` : This folder contains all the content for the blog - articles, tutorials, posts, pages, etc.
- `static\` : This folder contains all the static content like css, images, attachments, etc. which are used in the blog. Basically, everything you don't want Hugo to transform should go here.
- `themes\` : Here's where we put in all themes we'd like inside. Each theme should be in an individual folder. Even though, we can put multiple themes inside, we can only compile using one theme at a time (obviously!).
- `config.toml` : This file is super important and contains all the config options to be passed to the Hugo compiler. We can also pass those options as parameters while invoking the Hugo compiler but having them in the file makes it so much easier. The .toml extension indicates that the file uses the [**Tom's Obvious, Minimal Language**](https://github.com/toml-lang/toml) syntax. We can also use YAML (config.yaml) or JSON (config.json) files instead and Hugo would automatically recognize them.

By default, this is what the `config.toml` file contains:

```
baseURL = "http://example.org/"
languageCode = "en-us"
title = "My New Hugo Site"
```

I used the pretty neat looking [Introduction](https://github.com/vickylaiio/hugo-theme-introduction) theme for Hugo.

```bash
$ cd themes
$ git clone https://github.com/vickylaiio/hugo-theme-introduction.git introduction
```

This theme comes with its own set of config variables. So I went ahead and modified my `config.toml` file. I also added some perks of my own :P

```
baseurl             = "https://rajshrimohanks.in/" # Must end with /
languageCode        = "en-us"
title               = "Rajshri Mohan K S"
theme               = "introduction"
enforce_ssl         = "rajshrimohanks.in"
builddrafts         = false
canonifyurls        = true
contentdir          = "content"
layoutdir           = "layouts"
publishdir          = "public"
disqusshortname     = "rajshrimohanks" # Enable Disqus for comments
# googleAnalytics   = "xxx"
metaDataFormat      = "yaml"
enableEmoji         = true # https://www.webpagefx.com/tools/emoji-cheat-sheet/

[permalinks]
fixed = ":title/"
blog  = "blog/:slug/"

[params]
author        = "Rajshri Mohan K S" # Full name shows on blog post pages
firstname     = "Rajshri Mohan" # First name shows in introduction on main page
tagline       = "Programmer. Dreamer. And everything in between. Doing epic shit." # Appears after the introduction
introheight   = "large" # Input either 'medium' or 'large' or 'fullheight'
theme         = "light" # Choose 'light' or 'dark'
avatar        = "images/profile.jpg" # Path to image in static folder eg. img/avatar.png
email         = "rajshrimohanks@gmail.com" # Shows in contact section, or leave blank to omit
localtime     = true # Show your current local time in contact section
timezone      = "Asia/Kolkata" # Your timezone as in the TZ* column of this list: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
dateform      = "Jan 2, 2006"
dateformfull  = "Mon Jan 2 2006 15:04:05 EST"
cachebuster   = true # Add the current unix timestamp in query string for cache busting css assets
description   = "Programmer. Dreamer. And everything in between. Doing epic shit."
faviconfile   = "images/favicon.ico"
highlightjs   = true # Syntax highlighting
lang          = "en"
footertext    = "" # Text to show in footer (overrides default text)
fadein        = true # Turn on/off the fade-in effect

showblog        = true # Show Blog section on home page
showallposts    = true # Set 'true' to list all posts on home page, or set 'false' to link to separate blog list page
showlatest      = true # Show latest blog post summary
sharebuttons    = true # On post pages, show share this social buttons

showprojects    = false # Show Projects section on home page

# This is your projects section. Three images of the same dimensions will look the nicest. If images are omitted, text links will be shown.
project1link    = "#"
project1img     = "img/project1.jpg"
project1title   = "Project 1"

project2link    = "#"
project2img     = "img/project2.jpg"
project2title   = "Project 2"

project3link    = "#"
project3img     = "img/project3.jpg"
project3title   = "Project 3"


# Social icons appear in introduction and contact section. Add as many more as you like.
# Find icon names here: http://fontawesome.io/cheatsheet/

[[params.social]]
url = "https://facebook.com/rajshrimohanks"
icon = "facebook"

[[params.social]]
url = "https://www.linkedin.com/in/rajshrimohanks/"
icon = "linkedin"

[[params.social]]
url = "https://github.com/rajshrimohanks"
icon = "github"

[[params.social]]
url = "https://stackoverflow.com/users/4050218/rajshri-mohan-k-s"
icon = "stack-overflow"

[[params.social]]
url = "https://medium.com/@rajshrimohanks"
icon = "medium"

[[params.social]]
url = "https://www.instagram.com/rajshrimohanks/"
icon = "instagram"
```

This is all I needed to set up Hugo. Now I can write my first post and let Hugo generate my site.

## Writing my first post

Hugo makes this easy too. Every time I want to create a new post, I can simply do:

```bash
$ hugo new blog/hello-world.md
F:\my-works\first-hugo-site\content\blog\hello-world.md created
```

In Hugo, we write content using Markdown syntax, which arguably is much much more easier than writing in native HTML. So we can simply open up the newly created `hello-world.md` file and add our content to it. One thing to notice is that Hugo adds additional metadata on top of the file:

```md
---
date: 2017-05-16T11:12:45.000Z
title: 'Hello, World!'
draft: true
---

As is customary, I start off trying out **Hugo** using the clichéd first post - the _pillayar suzhi_, if you will - of all developers out there:

> Hello, World!
```

By default, the metadata is in TOML format. But since, I've specified `metaDataFormat = "yaml"` in my config, it has generated in the YAML format. I did this mainly because my text editor Atom wouldn't recognize TOML embedded in Markdown but would recognize YAML in Markdown. :confused: Also, we've to change the `draft` property to `false` (or pass the `--buildDrafts` parameter while compiling) or Hugo won't compile this file.

Anyways, once writing the post, all it takes to let Hugo generate the site is to go to the root of the project directory and run `hugo`. That's it!

```bash
$ hugo                       
Started building sites ...   
Built site for language en:  
0 draft content              
0 future content             
0 expired content            
1 regular pages created      
8 other pages created        
0 non-page files copied      
0 paginator pages created    
0 tags created               
0 categories created         
total in 8 ms
```

Hugo generates the output in `public/` folder. We can simply take it up and serve it via web-server to see the results!

But here's the catch with this system. Say I'm serving the page using a webhost, should I compile the contents every time I add a new post and update it on the host? Technically, yes! But we can automate it. Which is what I'm going to do next...! :D

--------------------------------------------------------------------------------

_It's been pretty late for me now. I would continue this tomorrow. Watch this space!_