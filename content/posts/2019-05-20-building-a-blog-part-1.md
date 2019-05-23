---
title: "building a blog part 1: deploying hugo"
date: 2019-05-20T01:01:19-07:00
draft: false
tags: ["technology"]
---


There are more than a few options out there to host a blog these days. But this is a technical blog and as one of my first posts, I wanted to provide a technical tutorial on how it was deployed and what I learned. 

For this site, I wanted to own the full technical stack, for two reaons:

1. to have full control over every functional and design aspect of the site
2. to fully understand how the site software stack works from the operating system on up

The site is only made from open source software so if I wanted to edit some miniscule detail, I have full power to do that. Welcome to the first post using this stack!

The words you’re reading are sent to you through software that’s deployed in this guide. I’m [hosting all the code](https://github.com/mark-church/site) that makes up the site so if you want to copy and deploy a similar stack, go right ahead.

This post will be one of a few in a series. I’ll tackle topics common for all production web services such as load balancing, service discovery, high availability, and security. 

- Deploying a server part 1: deploying hugo
- Deploying a server part 2: envoy as a frontend proxy
- Deploying a server part 3: envoy with consul service discovery
- Deploying a server part 4: web server metrics
- ... TBD

## Hugo - A static site generator
After reading ["switching to Hugo"](https://jvns.ca/blog/2016/10/09/switching-to-hugo/), I fancied the idea of using a static site generator instead of something more complex like Wordpress. What is a static site generator? To explain let’s think about Wordpress, which is a dynamic site. It has the capability to generate and insert dynamic content into the files that are returned to clients. This could be dynamic content such as article comments or an on-the-fly generated list of the most popular posts.

Static site generators pre-compile all of the web content (HTML, CSS) so it only changes when the content actually changes. This comes at the sacrifice of dynamic content, but is an acceptable trade off for me, because I want this site to be super simple.

Here are some things I like about [Hugo](https://gohugo.io/) (an open source static site generator):

- Its architecture simple and easy to understand
- The content is hosted as flat files that can be version controlled
- It has powerful but simple control for organizing articles
- It’s written in golang (which I’m in the process of learning)
- It’s fast (this is not a requirement, but if it becomes one, then great!)

Because the entire site is version controlled, all the code and content that runs this blog is [right here](https://github.com/mark-church/site)!

## Deploying Hugo
Deploying Hugo has a couple steps to it, first of which was learning how Hugo works. After that I wanted to customize its structure and how it looks. When I was happy with the customization I went ahead and deployed it all. You can edit and deploy this site as well just by using the code from the github repo.

### Understanding How Hugo Works

Hugo runs as a single binary that binds to an interface and port to serve content from the local filesystem. [This tutorial](https://gohugo.io/getting-started/quick-start/) got me started in running Hugo on my mac to start my learning.

With the tutorial, the hugo server can be started easily and accessed on your local browser.

```
$ hugo server
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
        │   │   ├── ...
        │   ├── index.html
        │   ├── partials
        │   │   ├── comments.html
        │   │   ├── footer.html
        │   │   ├── head.html
        │   │   ├── header.html
        │   │   ├── ...
        ├── static
        │   ├── css
        │   │   ├── zozo.css
        │   └── js
        │       ├── fancybox.min.js
        │       ├── ...
        └── theme.toml
```

- `config.toml` defines the top-level web pages and other global configurations such as the theme that’s used
- `content` folder holds all of the content for the posts as `.md` files
- `layouts/_default` holds the structure of the primary page types within the site such as the article listing page, individual post, and static single page.
- `layouts/partials` holds the structure of elements that are common on every page such as the header and footer
- `layouts/index.html` is the home page (the one that has the list of all the articles)

It took awhile to understand how the directory structure influences site structure, but once this clicked it was easy to see how I could customize the theme for my own use. Most of this customization occured in the `zozo.css` file and the within the `layouts` folder. 


### getting infrastructure
There are at least [10 different ways](https://gohugo.io/hosting-and-deployment/) to host a Hugo server in less than 5 minutes, but that would be too easy. Netlify will provide deployments, load balancing, HTTPS, monitoring and way more, but those are all the things that I want to learn and write about. Where would the fun be in getting those things for free?? Because I want to own all of the software infra services, I’m using a very minimal f1-micro instance running Ubuntu on GCP. The rest of the software infra I’ll be deploying in future posts.

### deploying hugo

#### 1 - install Hugo

Hugo has install instructions for different platforms. I'm running the site on Ubuntu Linux.

```
$ wget https://github.com/gohugoio/hugo/releases/download/v0.55.5/hugo_0.55.5_Linux-64bit.deb
$ sudo apt-get install /home/markchurch/hugo_0.55.5_Linux-64bit.deb
$ hugo version
Hugo Static Site Generator v0.55.5-A83256B9 linux/amd64 BuildDate: 2019-05-02T13:03:36Z

```

#### 2 - configure Hugo

This step will be unique for everybody but here are the things that I customized.

- Editing the top-level page structure in the config.toml
- Changing the theme.css file to update the style of the site
- Edit the html in the layouts folder to change the site structure

#### 3 - deploy Hugo

Hugo serves files from the local filesystem. With the source hosted on github, it can be pulled to the local filesystem and deployed. I'll automate this step in the future so that any updates to the remote git repository will result in a live site update.

```
$ git clone https://github.com/mark-church/site.git
$ cd site
$ hugo server --bind "0.0.0.0" -p 80 -b "markchur.ch"
```

While the above deploys Hugo, it doesn't do so in a very fault tolerant way. I want Hugo to survive server restarts or process failures so I’m using systemd and a very basic [unit file](https://github.com/mark-church/site/blob/master/deploy/hugo.service). Systemd will do basic process management as well as logging for the hugo server.


```
$ systemctl enable hugo
$ systemctl start hugo
$ systemctl status hugo
● hugo.service - Hugo Server
   Loaded: loaded (/etc/systemd/system/hugo.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2019-05-20 16:53:28 UTC; 1h 51min ago
 Main PID: 474 (hugo)
    Tasks: 9 (limit: 667)
   CGroup: /system.slice/hugo.service
           └─474 /usr/local/bin/hugo server --bind 0.0.0.0 -p 80 -b markchur.ch --source /site
```


### fin
That’s it! Kind of.

Realistically speaking, there are still a lot of missing things that would make this a production-grade web service. All we have right now are the basics. We have no user access logging, no encryption, zero redundancy, no automated site updates, no caching, and nonexistent metrics. 

Hugo is also not designed to be a high-performance web server and so a web serving proxy would be a good idea. I've been wanting to go deeper in to Envoy for a while and so in the next post we’ll deploy [Envoy](https://www.envoyproxy.io/) to act as our frontend proxy. Thanks for reading!
