---
layout: post
title:  "Inside Queue Models: Markov Chains"
date:   2016-04-27 15:00:00 +0000
categories: maths performance
---

So far in this series on queueing theory, we've seen [single server queues][1],
[bounded queues][2], [multi-server queues][3], and most recently [queue
networks][4]. A fascinating result from queueing theory is that wait time
degrades significantly as utilisation tends towards 100%. We saw that $$M/M/c$$
queues, which are unbounded, have degenerate behaviour under heavy load when
utilisation hits dangerous levels.

Perhaps more interestingly, we saw that bounded $$M/M/c/k$$ queues limit
customer ingress to prevent this undesirable behaviour; in essence we learned
that we can reject some customers to ensure good service for those who _do_ make
it into the system. Those customers who get rejected might not be entirely
happy with this arrangement, so the question is: can we do better?

Over the course of the next two entries, I want to dig deeper into the internals
of queuing models so that we can explore sophisticated ways to better capture
how modern systems behave. The ultimate goal of this series is to learn how we
can build models of [reactive systems][5], paying particular attention to how we
model **back pressure** in those systems.

A reactive system, using back pressure, signals to its source of traffic when
it's ready for more customers. At first glance, this might sound incredibly
impractical, but in practice back pressure works for any system that is
completely in control of both the traffic source and the processing service.

For a typical service-based architecture, back pressure is the perfect mechanism
for regulating traffic flow between services. One can imagine that as services
_pull_ more traffic in from their upstream provider, this _pull_ propagates
towards the outside of the system until finally it hits the boundary where
traffic is coming from the outside world. Even here, back pressure can be
applied to some level. Both TCP and HTTP traffic can be limited to a certain
degree with back-pressure. Eventually though, back pressure will no longer
suffice to limit resource usage and we'll need to start dropping customers.

In practice then, a reactive system bounds all in-flight processing, but uses
back pressure to regulate the amount of in-flight work, and thus, reduce the
number of cases where work must be rejected. We can model queues with
back-pressure by replacing the Poisson arrival process used by all $$M/*/*$$
queues with something more sophisticated.

Before we look at other arrival processes though, we should first ensure that we
really understand how a simple queue, like an $$M/M/1$$ queue, really functions.
In particular, we are interested in analysing our queue as a particular type of
[continuous time Markov chain][6] called a [birth-death process][7].

## A Quick Recap

Before we proceed, let's remind ourselves of the basics of $$M/M/c$$ queue
models. Arrivals into the queue are modelled as a Poisson process where the
arrival rate is designated $$\lambda$$. Service times have rate $$\mu$$ and
are exponentially-distributed with mean service time of $$1 / \mu$$.

The ratio of arrival to service completion $$\lambda / \mu$$ is denoted
$$\rho$$. For unbounded $$M/M/c$$ queues, $$\rho < c$$ ensures that the queue is
stable, if $$\rho \geq c$$, then both queue size and latency tend towards
infinity.

## Markov Chains in Two Minutes

A Markov chain is a random process described by states and the transitions
between those states. Transitions between states are probabilistic and exhibit a
property called *memorylessness*. The memorylessness property ensures that the
probability distribution for the next state depends only on the current state.
Put another way, the history of a Markov process is unimportant when considering
what the next transition will be.

![Simple Markov chain example](/assets/markov-chains/dtmc.png)

The diagram above shows a simple Markov chain with three states: *in bed*, *at
the gym* and *at work*. The transitions between each state to the next state are
labelled with the respective probabilities. For example, the probability of
going from *in bed* to *at work* is 30%. Note also, that the probability of
remaining *in bed* is 20%; there's no requirement that we actually leave the
current state.

We can represent these transition probabilities using a transition probability
matrix $$P$$:

$$
\begin{bmatrix}
0.2 & 0.5 & 0.3 \\
0.1 & 0.2 & 0.7 \\
0.4 & 0.1 & 0.5 \\
\end{bmatrix}
$$

The probability of moving from state $$i$$ to state $$j$$ is given by
$$P_{ij}$$. Each row in the matrix must sum to $$1$$ indicating that the
probability of doing _something_ when in a given state is always $$100%$$.

This kind of Markov chain is called a *discrete-time Markov chain* (DTMC), where
the time parameter is discrete and the state changes randomly between each
discrete step in the process. The models we've seen so far have a continuous
time parameter resulting in *continuous-time Markov chains* (CTMC).

We can recast our discrete-time process as a continuous-time process. We use a
slightly different representation for our continous-time chains. Rather than
modelling the transition probabilities, we model the *transition rates*:

![Continuous-time Markov chain example](/assets/markov-chains/ctmc.png)

Note that we omit rates for staying in the same state: it makes little sense to
talk about the rate at which a process remains stationary. Just as we used a
transition probability matrix for the discrete-time chain, we use a transition
rate matrix $$Q$$ for the continuous-time chain:

$$

\begin{bmatrix}
-0.8 & 0.5 & 0.3 \\
0.1 & -0.8 & 0.7 \\
0.4 & -0.9 & 0.5 \\
\end{bmatrix}

$$

Here, $$Q_{ij}$$ is the _rate_ of transition from state $$i$$ to state $$j$$.
Diagonals ($$Q_{ii}$$) are constructed such that each row equals $$0$$ unlike
the diagonals for the transition probability matrix, which ensure that each row
equals $$1$$. The diagram and the matrix show that our continuous-time chain
moves from the *in bed* state to the *at the gym* state ($$Q_{01}$$) with rate
$$0.5$$.

## Poisson Processes

Now we understand how to construct continuous-time Markov chains we can explore
Markovian queues in more detail. Recall that for an $$M/M/c$$ queue, both
arrivals and service times are Poisson processes, that is they are both
stochastic processes with Poisson distribution.

We can model a Poisson process, and thus the arrivals and service processes, as
a CTMC where each state in the chain corresponds to a given population size.
Consider the arrivals process in an $$M/M/1$$ queue. We know that arrivals are a
Poisson process with rate $$\lambda$$. At the start of the process, there have
been no arrivals. Thi first arrival occurs with rate $$\lambda$$, so to second,
the third and so on for as long as the process continues. We can model this as a
Markov chain where the states correspond to the arrivals count:

![Markov chain of birth-death process](/assets/markov-chains/birth-death.png)

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
arrivals process and the service process. As we saw, each of these processes can
be described by a Markov chain. We can go further and describe the queue as a
whole using a special kind of Markov chain process called a **birth-death
process**. Birth-death processes are processes where the states represent the
population count and transitions correspond to either **births**, which
increment the population count by one, or **deaths** which decrease the
population count by one. Note that Poisson processes are themselves birth-death
processes, just with zero deaths.


This diagram shows the Markov chain for an $$M/M/1$$ queue with arrival rate
$$\lambda$$ and service rate $$\mu$$. As you can see, the population state
increases as customers arrive at the queue and decreases as customers are
served. We can translate this simple diagram into a transition rate matrix for
the queue:

$$
\begin{bmatrix}
-\lambda & \lambda & 0 & 0 \\
\mu & -(\mu + \lambda) & \lambda & 0 \\
0 & \mu & -(\mu + \lambda) & \lambda \\
& & & & \ddots \\
\end{bmatrix}
$$

When the process starts, the only possible transition is from zero customers to
one with rate $$\lambda$$ ($$Q_{01} = \lambda$$). After this, at each state, the
process can transition to having one more customer, again at rate $$\lambda$$ or
to having one fewer customer with rate $$\mu$$.

## Steady-State Probabilities

With the transition rate matrix in hand, we can calculate the steady-state
probabilities $$p_k$$ for the $$M/M/1$$ queue. Recall that the steady-state
probabilities $$p_k$$ tell us the probability of the queue being in state $$k$$,
that is the probability of having $$k$$ customers in the system. More formally:

$$
p_k = \lim_{t \to \infty} P_k(t)
$$

Where $$P_k(t)$$ is the probability of having $$k$$ customers in the system at
time $$t$$. Note that the steady-state probabilities are time-independent and,
as the name implies, steady. More precisely, we expect that:

$$
\lim_{t \to \infty} P'_{k}(t) = 0
$$

That is, we expect the rate of change of the probabilities to be zero in the
limit. Let's think about $$P'_k(t)$$ for a while. The transition rate matrix
tells us how the process flows between states. We can see that each state $$k$$
can be entered from states $$k-1$$ and state $$k+1$$. Entry from state $$k-1$$
corresponds to a customer arriving in the system and has rate $$\lambda$$. Entry
from state $$k+1$$ corresponds to a customer completing service and leaving the
system with rate $$\mu$$.

Each state $$k$$ can also exit to states $$k-1$$ and $$k+1$$ as customers are
served (with rate $$\mu$$) and arrive (with rate $$\lambda$$). This gives us:

$$
P'_k(t) = \lambda P_{k-1}(t) + \mu P_{k+1}(t) - \lambda P_k(t) - \mu P_k(t)
$$

Using our limit condition $$\lim_{t \to \infty} P'_{k}(t) = 0$$ we find these
steady-state flow equations:

$$
\begin{align}
0 &= p_0 = \mu p_1 - \lambda p_0 \\
0 &= p_k = \lambda p_{k-1} + \mu p_{k+1} - \lambda p_k - \mu p_k
\end{align}
$$

Solving this recurrence relation with dependence on $$p_0$$ gives us:

$$
p_k = \Big( \frac{\lambda}{\mu} \Big)^k p_0
$$

Since we know that all probabilites must sum to $$1$$ we can derive $$p_0$$:

$$
\begin{align}
1 &= p_0 + \sum_{k=1}^{\infty} p_k \\
1 &= p_0 + \sum_{k=1}^{\infty} \Big( \frac{\lambda}{\mu} \Big)^k p_0 \\
1 &= p_0 \Bigg(\sum_{k=1}^{\infty} \Big( \frac{\lambda}{\mu} \Big)^k \Bigg) \\
1 &= p_0 \frac{1}{1 - \frac{\lambda}{\mu}} \\
p_0 &= 1 - \frac{\lambda}{\mu} \\
p_0 &= 1 - \rho \\
\end{align}
$$

## Coming full circle

You might recall that, in my first post in this series, I mentioned that the
equation for the mean number of customers in an $$M/M/1$$ queue follows from
the steady-state probabilities. Let's see how that works. The mean number
of customers $$L$$ for an $$M/M/1$$ queue is:

$$
L = \frac{\rho}{1 - \rho}
$$

To get here from the steady-state probabilities let's start by simply defining
$$L$$ in terms of $$p_k$$:

$$
L = \sum_{k = 0}^{\infty}k \cdot p_k
$$

We're saying that the mean numbers of customers is simply the sum of each
possible value adjusted by its probability. Let's expand on this:

$$
\begin{align}
L &= \sum_{k = 0}^{\infty}k \cdot \Big( \frac{\lambda}{\mu} \Big)^k p_0 \\
L &= \sum_{k = 0}^{\infty}k \cdot \rho^k p_0 \\
L &= \sum_{k = 0}^{\infty}k \cdot \rho^k \cdot (1 - \rho) \\
L &= (1 - \rho) \cdot \sum_{k = 0}^{\infty}k \rho^k \\
\end{align}
$$

We know that $$M/M/1$$ queues have divergent behaviour if $$\rho \geq 1$$, and
indeed the series $$\sum_{k = 0}^{\infty}k \rho^k$$, only converges
for $$\rho < 1$$. So, assuming we have $$\rho < 1$$
(otherwise $$L$$ is undefined):

$$
\begin{align}
L &= (1 - \rho) \frac{\rho}{(\rho - 1)^2} \\
L &= \frac{\rho - \rho^2}{(\rho - 1)^2} \\
L &= \frac{-\rho(\rho - 1)}{(\rho - 1)^2} \\
L &= \frac{-\rho}{\rho - 1} \\
L &= \frac{\rho}{1 - \rho} \\
\end{align}
$$

And thus we arrive at the definition for $$L$$, the mean customers in the
queue for $$M/M/1$$ queues.

## What's next?

With an understanding of how Markov chains are used to construct queue models,
we can start looking at some more complex models. In particular, the next  post
in this series will introduce Markov-modulated Arrival Processes (MMAP). An MMAP
composes two or more Markov arrival processes and switches between them. The
switching is itself modelled as a Markov chain. MMAPs are a great way of
creating a rudimentary model of how back-pressure works.

[1]: /maths/performance/2016/02/20/service-latency-and-utilisation.html
[2]: /maths/performance/2016/02/27/finite-queue-latency.html
[3]: /maths/performance/2016/03/07/multi-server-queues.html
[4]: /maths/performance/2016/03/15/queue-networks.html
[5]: http://www.reactivemanifesto.org/
[6]: https://en.wikipedia.org/wiki/Continuous-time_Markov_chain
[7]: https://en.wikipedia.org/wiki/Birth%E2%80%93death_process
