---
layout: post
title:  "Relating Service Utilisation to Latency"
date:   2016-02-20 17:00:00 +0000
categories: maths performance
---

At [Skipjaq](https://www.skipjaq.com), we are interested in how applications
perform as they approach the maximum sustainable load. We don't want to
complete saturate an application so it falls over, but we also don't want to
under-load the application and miss out on true performance numbers.

In a recent conversation with the team, I mentioned that, as a general rule,
we should expect service latencies to degrade sharply once the service hits
around 80% utilisation. More specifically, we should expect the __wait__ time
of the service to degrade, which will cause the latency to degrade in turn.

John D. Cook wrote [a great explanation][1] of why this is the case, but
I wanted to write a slightly deeper explanation for those who have no prior
experience with queuing theory.

[1]: http://www.johndcook.com/blog/2009/01/30/server-utilization-joel-on-queuing/
