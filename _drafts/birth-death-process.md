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

A Markov chain is a random process described by states and transitions
between those states. Transitions between states are probabilistic and
exhibit a property called *memorylessness*. The memorylessness property
ensures that probability distribution for the next state depends only on
the current state. Put another way, the history of a Markov process is
unimportant when considering what the next transition will be.

The diagram above shows a simple Markov chain with three states: *in bed*,
*at the gym* and *at work*. The transitions between each state to the next
state are labelled with the respective probabilities. For example, the
probability of going from *in bed* to *at work* is 30%. Note also, that
the probability of remaining *in bed* is 20%: there's no requirement that
we actually leave the current state.

We can represent the transition probabilities using a transition
probability matrix $$P$$:

$$
\begin{bmatrix}
0.2 & 0.5 & 0.3 \\
0.1 & 0.2 & 0.7 \\
0.4 & 0.1 & 0.5 \\
\end{bmatrix}
$$

The probability of moving from state $$i$$ to state $$j$$ is given by
$$P_{ij}$$. Each row in the matrix must sum to $$1$$ indicating that there
is no uncertainty about the transition probabilities.

This kind of Markov chain is a *discrete-time Markov chain*, where the
time parameter is discrete and the state changes randomly between each
discrete step in the process. The models we've seen so far have
a continuous time parameter resulting in *continuous-time Markov chains*.

We can recast our discrete-time process as a continuous-time process. We
use a slightly different representation for our continous-time chains.
Rather than modelling the transition probabilities, we model the
*transition rates*:

Note that we're omitting rates for staying in the same state. Just as we
used a transition probability matrix for the discrete-time chain, we use
a transition rate matrix for the continuous-time chain:

$$

\begin{bmatrix}
-0.8 & 0.5 & 0.3 \\
0.1 & -0.8 & 0.7 \\
0.4 & -0.9 & 0.5 \\
\end{bmatrix}

$$

Transition rate matrices have a subtly different construction to
transition probability matrices: the diagonals are constructed such that
rows sum to $$0$$ and not $$1$$. We can see here that our continuous-time chain
moves from the *in bed* state to the *at the gym* state with rate $$0.5$$.

## Poisson Processes

Now we understand how to construct continuous-time Markov chains we can
explore Markovian queues in more detail. Recall that for an $$M/M/c$$
queue, both arrivals and service times are Poisson processes, that is they
are both stochastic processes with Poisson distribution.

We can model a Poisson process, and thus the arrivals and service
processes, as a CTMC where each state in the chain corresponds to a given
population size. Consider the arrivals process in an $$M/M/1$$ queue. We
know that arrivals are a Poisson process with rate $$\lambda$$. At the
start of the process, there have been no arrivals. With rate $$\lambda$$,
the first arrival occurs, then the second, the third and so on for as long
as the process continues. We can model this as a Markov chain where the
states correspond to the arrivals count:


When we translate this into a transition rate matrix we get:

$$
\begin{bmatrix}
-\lambda & \lambda & 0 & 0 \\
0 & -\lambda & \lambda & 0 \\
0 & 0 & -\lambda & \lambda \\
& & & & \ddots \\
\end{bmatrix}
$$

This matrix continues unbounded since the number of arrivals is effectively
unbounded.

## Birth-Death Processes

An $$M/M/c$$ queue is composed of two Poisson processes working in tandem: the
arrivals process and the service process. As we saw, each of these
processes can be described by a Markov chain. We can go further and
describe the queue as whole using a special kind of Markov chain process
called a **birth-death process**. Birth-death processes are processes
where the states represent the population count and transitions correspond
to either **births**, which increment the population count by one, or
**deaths** which decrease the population count by one. Note that Poisson
processes are themselves birth-death processes, just with zero deaths.


This diagram shows the Markov chain for an $$M/M/1$$ queue with arrival
rate $$\lambda$$ and service rate $$\mu$$. As you can see, the population
state increases as customers arrive at the queue and decreases as
customers are served. We can translate this simple diagram into
a transition rate matrix for the queue:

$$
\begin{bmatrix}
-\lambda & \lambda & 0 & 0 \\
\mu & -(\mu + \lambda) & \lambda & 0 \\
\end{bmatrix}
$$



[1]: /maths/performance/2016/02/20/service-latency-and-utilisation.html
[2]: /maths/performance/2016/02/27/finite-queue-latency.html
[3]: /maths/performance/2016/03/07/multi-server-queues.html
[4]: /maths/performance/2016/03/15/queue-networks.html
[5]: http://www.reactivemanifesto.org/
[6]: https://en.wikipedia.org/wiki/Continuous-time_Markov_chain
