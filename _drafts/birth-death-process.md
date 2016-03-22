---
layout: post
title:  "Understanding Birth-Death Processes"
date:   2016-03-22 17:00:00 +0000
categories: maths performance
---

So far in my series on queueing theory, we've seen [single server
queues][1], [bounded queues][2], [multi-server queues][3], and most
recently [queue networks][4]. A fascinating result from queueing theory is
that wait time degrades significantly as utilisation tends towards 100%.
We saw that $$M/M/c$$ queues, which are unbounded, have degenerate
behaviour under heavy load because utilisation starts to hit dangerous
levels. 

Perhaps more interestingly, we saw that bounded $$M/M/c/k$$ queues can be
limited to prevent this undesirable behaviour; in essence we learned that
we can trade-off rejecting some customers to ensure good service for those
customers who make it into the system. The customers who get rejected to
free up capacity for those inside the system, might not be entirely happy
with this arrangement! So, the question is: is there another way? 

Over the course of the next two entries, I want to move this series
towards it's ultimate goal: a discussion of [reactive systems][5] and, in
particular, of **back pressure**. A reactive system, using back pressure,
signals to it's source of traffic when it is ready to for more customers.
At first glance, this might sound incredibly impractical, but in practice
back pressure works for any system that is completely in control of both
the traffic source and the processing service. 

For a typical service-based architecture, back pressure is the perfect
mechanism for regulating traffic flow between services. One can imagine
that as services _pull_ more traffic in from their upstream provider, this
_pull_ propagates towards the outside of the system until finally it hits
the boundary where traffic is coming from the outside world. Even here,
back pressure can be applied to some level. Both TCP and HTTP traffic can
be limited to a certain degree with back-pressure. Eventually though, back
pressure will no longer suffice to limit resource usage and we'll need to
start dropping customers.

In practice then, a reactive system bounds all in-flight processing, but
uses back pressure to regulate the amount of in-flight work, and thus,
reduce the number of cases where work must be rejected. We can model
queues with back-pressure by replacing our simple Poisson arrival process
with a more sophisticated arrival process. Before we look at other arrival
processes though, we should first ensure that we really understand how
a simple queue like $$M/M/1$$ queue really functions. In particular, we
are interested in analysing our queue as a particular type of [continuous
time Markov chain][6] called a [birth-death process][7].

## Markov Chains in Two Minutes

## Poisson Processes

## Birth-Death Processes

##

[1]: /maths/performance/2016/02/20/service-latency-and-utilisation.html
[2]: /maths/performance/2016/02/27/finite-queue-latency.html
[3]: /maths/performance/2016/03/07/multi-server-queues.html
[4]: /maths/performance/2016/03/15/queue-networks.html
[5]: http://www.reactivemanifesto.org/
