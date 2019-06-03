---
title: "building a blog part 1.5: what is the envoy proxy?"
date: 2019-06-02T01:01:19-07:00
draft: false
tags: ["technology"]
---

>This post began as part 2 but after crossing several pages just explaining why envoy was special, it was obvious that the answer to “why envoy?” deserved to stand on its own, giving us part 1.5.

In part 1 of this series we deployed a very simple blog with a site generation app called Hugo. We did things quick and dirty and used Hugo's built-in development server to serve the content so we were live in less than 15 minutes. Calling it a blog at this point in time would be super generous, but thank you anyways! What we have right now is a bicycle, but what we want is an Airbus A380 (on an open source bicycle budget) . We want a production-grade web service and getting there will be a journey. 

I’m starting the journey by introducing out a few important production characteristics through proxying and load balancing. This addition will already make the site much more reliable. It’ll give us the following goodies:

- High availability through redundancy
- Resiliency through health checking 
- Operational data such as health metrics and client access logging
- Less risky deployments through gradual proxy reconfiguration

These capabilities could be provided through a lot of different tools, so I’ll tell you my real goal: _to learn more about the envoy proxy_. The envoy proxy is a fairly new open source project and has already received fast adoption (for good reasons). You might be asking, why should I even care about envoy? Well I’m very glad you asked - let me tell you!

## Why Envoy?

Envoy is yet another web proxy, but it does not focus on being a more performant version of its predecessors (like its predecessors were to theirs). Instead, envoy focuses on improving other operational areas. The improvements have opened up entirely new ways of running a proxy, bringing innovative ways to do all kinds of seemingly unrelated things like monitoring, deployment, security, and service discovery. 

### API Driven Configuration

This is one of the most powerful features of envoy. The state of the envoy configuration, from routing rules, to backend ip:ports, to load balancing algorithms, is configurable through an API rather than text config files (although text is possible). This makes the operation of envoy very different from traditional proxies.

- Configuration semantics are tightly defined and segmented so different elements can be updated without touching an entire config
- API versioning and schema reduces disruption from future enhancements to envoy
- The API is native to envoy without external components and designed to be the primary way in which its configured
- The API uses gRPC to communicate with a centralized management server that makes applying config across many proxies more scalable

Nowadays web backends are very dynamic resources themselves. They will scale up and down, change IP addresses, and run across multiple datacenters concurrently. Web proxy configurations must change frequently to handle this and text-based configuration is just not automatable enough. 

To give an example for why this has been difficult in the past, just take a look at the number of different kubernetes [nginx](https://github.com/kubernetes/ingress-nginx) [ingress](https://github.com/nginxinc/kubernetes-ingress) [controllers](https://github.com/ehazlett/interlock) that exist to solve the fundamentally the same problem. same problem. They are taking a standard API (the K8s ingress API) and translating it to a templated text file for the web proxy to consume. Templating and applying these config files turns out to be cumbersome which reduces the scale that it can be done at.  (No dig against nginx - these controllers were solving for dynamic configuration long before envoy even existed).

With envoy’s API, dynamic control of the proxy is straightforward, standardized, and scalable. The ability to fully automate a control-plane across a fleet of proxies (i.e. service mesh) is much more realistic thanks to this. 

Machine friendly configuration has opened up a whole list of projects that are now building around envoy, in no small part because it’s easy to build around. This includes projects like Istio, Gloo, Ambassador, Contour, and Consul Connect - all designed as control-planes for Envoy. Administrators, orchestration tools (like Consul or K8s), and potentially applications themselves can have the capability to easily manipulate routing.

<div align="center">
<img style="max-width:100%" src="/images/envoy-config.png">
</div>

### Hot Restart / Live Reload
Hot restart allows the envoy process to restart or without dropping any connections. This enables configuration changes without impacting any traffic. Envoy actually takes this to an extreme and is capable of restarting the entire envoy process without dropping any connections. In a nutshell it runs two envoy processes in parallel as they communicate running state to each other. New connections are taken by the new process while old connections are drained by the old process while retaining all state (including metrics).

While API-based configuration is rad, hot restarts are also a requirement to run a truly dynamic proxy. Together these two features are what make envoy great for dynamic networking.

### Modern Protocols & Other Cool Stuff
The list is long, but by virtue of being the new kid on the block, envoy natively supports tons of modern protocols including HTTP2 and gRPC. Envoy shows its youth by using a lot of modern day standards. The load balancing is also very configurable. Envoy can be zone-aware and load balance based on customizable combinations of factors such as locality, priority, and health. Then there are also the little conveniences like access logs output in JSON that are nice. 

Okay that’s enough gushing for now. In part 2 we’ll deploy envoy as a proxy for this site and start using some of its features. Here are some final thoughts.

- Web proxying and load balancing are critical aspects of making environments production-ready
- Environments are only getting more dynamic and ephemeral so proxies are adapting to become more dynamic and automatable
- Envoy is great at both of these ^^


Here are some resources I read through while writing this:

- [Envoy project docs](https://www.envoyproxy.io/docs/envoy/latest/)
- [Envoy hot restart blog post](https://blog.envoyproxy.io/envoy-hot-restart-1d16b14555b5)
- [Learning Envoy](https://www.envoyproxy.io/learn/)
- [Envoy API “hello world”](https://medium.com/@salmaan.rashid/envoy-discovery-hello-world-d3e44d19603d)