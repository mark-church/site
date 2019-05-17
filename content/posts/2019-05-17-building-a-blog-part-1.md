---
title: "building a blog part 1: deploying hugo"
date: 2019-05-17T01:35:19-07:00
draft: false
tags: ["technology"]
---


There are more than a few options out there to host your blog these days, many which require zero technical expertise other than using a browser. With this being a technical blog though, I want to own the full stack. I had two goals:
1) have full control over every aspect of the site (from the look to how the content is organized) and also 
2) fully understand how the site software stack works

The site is only made from open source software so if I wanted to edit some miniscule detail, I have the power to do that! I’m not hardcore enough to host my own physical server, but I at least wanted to have control of the software stack, from the OS to the blog server itself.

Welcome to the first post using this stack! The words you’re reading are sent to you through software that’s deployed in this guide. I’m also hosting all the code that makes up the site so if you want to copy and deploy a similar stack, you can totally do that.

This post will be one of a few in a series. I’ll tackle topics common for all production web services such as load balancing, service discovery, high availability, and security. 

Deploying a server part 1: Hugo static site generator
Deploying a server part 2: Envoy as a frontend proxy
Deploying a server part 3: Envoy with Consul service discovery
Deploying a server part 4: Web server metrics
…. TBD

## Hugo - A static site generator
After reading [this post](https://jvns.ca/blog/2016/10/09/switching-to-hugo/), I fancied the idea of using a static site generator instead of something more complex like Wordpress. What is a static site? To explain let’s think about Wordpress which is a dynamic site. It has the capability to generate dynamic content to insert into the web pages that are returned to clients. This could be dynamic content such as article comments or dynamically generated popular posts.

Static site generators pre-compile all of the web content (HTML, CSS) so it only changes when the content actually changes. This comes at the sacrifice of dynamic content, but is an acceptable trade off for me, because I want this site to be super simple.

Here are some things I like about [Hugo](https://gohugo.io/) (an open source static site generator):
Its architecture simple and easy to understand
The content is hosted as flat files that can be version controlled
It has powerful but simple control for organizing articles
It’s written in golang (which I’m in the process of learning)
It’s fast (this is not a requirement, but if it becomes one, then great!)

## Deploying Hugo
Deploying Hugo has a couple steps to it, first of which was learning how Hugo works.

### Understanding How Hugo Works

Hugo runs as a single binary that binds to an interface and port to serve local content from flat files. [This tutorial](https://gohugo.io/getting-started/quick-start/) got me started in running Hugo on my mac to start my learning.

With the tutorial the hugo server can be started easily and accessed on your local browser.

```
hugo server
...
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```

### Finding a theme

There are already a lot of good themes that exist. I was looking for a minimalist theme and settled on [zozo](https://github.com/imzeuk/hugo-theme-zozo). 

Hugo has a prescriptive directory structure that defines how it works. For this site I don’t use most of the directories, but here are some of the files and folders I did spend a lot of time on:

```
├── config.toml
├── content
│   ├── about
│   ├── links
│   └── posts
└── themes
    └── zozo
        ├── layouts
        │   ├── 404.html
        │   ├── _default
        │   │   ├── list.html
        │   │   ├── single.html
        │   │   └── terms.html
        │   ├── index.html
        │   ├── partials
        │   │   ├── comments.html
        │   │   ├── footer.html
        │   │   ├── head.html
        │   │   ├── header.html
        │   │   ├── js.html
        │   │   ├── nav.html
        │   │   └── post.html
        ├── static
        │   ├── css
        │   │   ├── zozo.css
        │   └── js
        │       ├── fancybox.min.js
        │       ├── highlight.pack.js
        │       ├── jquery-3.3.1.min.js
        │       └── zozo.js
        └── theme.toml
```

`config.toml` defines the top-level web pages and other global configurations such as the theme that’s used
`content` folder holds all of the content for the posts as `.md` files
`layouts/_default` holds the structure of the primary page types within the site such as the article listing page, individual post, and static single page.
`layouts/partials` holds the structure of elements that are common on every page such as the header and footer
`layouts/index.html` is the home page (the one that has the list of all the articles)

It took awhile to understand how the directory structure influences site structure, but once this clicked it was easy to see how I could customize the theme for my own use. Most of this customization occured in the `zozo.css` file and the within the `layouts` folder. 


### getting infrastructure
There are at least [10 different ways](https://gohugo.io/hosting-and-deployment/) to host a Hugo server in less than 5 minutes but that would be too easy. Because I want to own all of the software infra services myself, I’m using a very minimal f1-micro instance from GCP. Maybe in the future I’ll serve the blog with something even more minimal such as functions, but for today we are starting with the basics. 





### deploying hugo

On Linux Hugo can easily be downloaded and installed from the [hosted binaries.](https://github.com/gohugoio/hugo/releases) 

```
$ wget https://github.com/gohugoio/hugo/releases/download/v0.55.5/hugo_0.55.5_Linux-64bit.deb
$ sudo apt-get install /home/markchurch/hugo_0.55.5_Linux-64bit.deb
$ hugo version
Hugo Static Site Generator v0.55.5-A83256B9 linux/amd64 BuildDate: 2019-05-02T13:03:36Z


```

< Work in progress > 

