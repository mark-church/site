---
title: "building a blog part 2: envoy as an ingress proxy"
date: 2019-06-03T01:01:19-07:00
draft: false
tags: ["technology"]
---

In part 1 of this series we deployed a very simple blog with an app called Hugo. Hugo nicely generates static group of folders and files from markdown  that can be served as a full website. We did things quick and dirty and used Hugo's built-in dev server to serve the content and we were up in less than 15 minutes. Calling it a blog at this point in time would be super generous (but thank you anyways) - what we have right now is a bicycle, but what we want is an Airbus 380. We want a production-grade web service and it's going to take some work to get there.

In this post we're going to get through a few items on our production-grade checklist that will accomplish the following goals:

- Swap our Hugo dev server with a more robust web server
- Implement a web proxy using Envoy in front of our server 
- Configure access logging to get visibility over our clients
- Implement high availability in our stack so that we could survive a server or a process crash

We'll do this in a couple steps:

1) Deploy nginx as our web server
2) Deploy envoy as a front proxy (more on nginx vs envoy in a bit)
3) Deploy all pieces as redundant components across redundant machines
4) Configure envoy endpoints and health checking

First though, let's talk about some of these components that we're using.

## the envoy proxy

Envoy is one of the newest kids on the block. Envoy is a fully open source web proxy written in C++ that originated at Lyft primarily by a guy named Matt Klein. Here are the things that I find most interesting about envoy:

- It's fully open source and there is no de facto company that retains ownership. At the time of writing, the project founder Matt Klein remains at Lyft and has not created a company around the Envoy project. There are a host of companies that use and contribute to Envoy, but there is no one company that has a majority stewardship over the project at this time. This makes the project interesting because many projects and companies have decided to use envoy as a base and central component of their architectures. 


## web proxy vs web server

Envoy is a web proxy while nginx is (primarily) a web server. Nginx can also be used as a proxy because the functionalities are similar, but I'm using each component for their primary functionality. L7 terminology is chronically ill-defined and misused - "web server" and "proxy" fall in to this category.

- **web server** - The final destination of a L7 request that serves content from persistent data (usually a filesystem) via some L7 protocol. 
- **web proxy** - An intermediate hop of a L7 request that terminates and originates L7 requests between frontends and backends. Also known as: reverse proxy, load balancer, ingress

Both speak L7 (HTTP), but one is terminating client connections while the other is managing both frontend and backend connections. This leads to a very overlapping set of requirements, but optimization for one use or the other has lead to solutions that differ from each other. For example, proxies load balance requests amongst backend servers which requires sophisticated load balancing and health checking algorithms. On the other hand, servers <something about serving content>.

    





