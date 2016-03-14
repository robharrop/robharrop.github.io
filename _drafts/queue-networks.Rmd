---
layout: post
title: Queue Networks
---

In my [previous post][1] I presented the $$M/M/c$$ queue as a model for
multi-server architectures. As discussed at the end of that post, the
$$M/M/c$$ model has two main drawbacks: each server must have the same
service rate, and there's no mechanism for modelling the overhead of
routing between servers. A model that has a single queue for what is in
reality multiple queues isn't sufficient. In this post, I'll explain how
queues can be arranged in networks that capture the cost of routing and
allow for servers with different service rates.

## Open Jackson Networks

We're going to concern ourselves with a particular class of queue network
called **open Jackson networks**. The 'open' portion of the name refers to
the fact that customers arrive from outside the system much like the
queues we've seen so far. In a closed Jackson network, there are no
arrivals from the outside and customers never leave the system; in other
words the amount of work in the system is fixed.

The most interesting characteristic of Jackson networks is that they have
a product form solution for the steady-state distribution. This is
a rather grand way of saying that we can calculate the overall
steady-state distribution by treating each component as if it were
operating independently. For a network to behave in this manner, all
routing between queues in the network must be _Markovian_, that is
customers are routed from one queue to the network _probabilistically_.

At first glance, the requirement to route probabilistically might seem
rather restrictive, but in reality it requires only a small change in
mindset. If our real world system routes traffic between $$n$$ servers in
a round-robin fashion, then our model can route between $$n$$ queues with
probability $$1/n$$.

## Modelling Load Balanced Servers

To get a better understanding for Jackson networks, let's consider
a concrete example of two servers operating behind a load balancer:


Here you can see that traffic arrives at the load balancer ($$s_{1}$$)
from the outside with rate  $$\lambda = 500$$ and is then routed between
each of the servers ($$s_{2}$$ and $$s_{3}$$) with probability $$1/2$$.

The probability that a customer leaves queue $$i$$ and enters queue $$j$$
is $$p_{ij}$$. We use the index $$0$$ to represent the outside world, so
$$p_{0j}$$ is the probability that a job enters queue $$j$$ from the
outside world and $$p_{j0}$$ is the probability that a job leaves queue
$$j$$ for the outside world. 

We can represent these routing probabilities as a matrix:

$$
\begin{bmatrix}
0 & 1 & 0 & 0 \\
0 & 0 & 1/2 & 1/2 \\
1 & 0 & 0 & 0 \\
1 & 0 & 0 & 0 \\
\end{bmatrix}
$$

We see from the matrix that $$p_{01}$$, the probability that a job enters
queue $$1$$ from outside the system is $$1$$ and the probability that jobs move
from queue $$1$$ to either queue $$2$$ or queue $$3$$ is $$1/2$$.

Jackson's theorem tells us that, provided we have Markovian routing, and
that each queue has it's own well-defined steady-state, then the whole
network has a well-defined steady-state distribution. Furthermore, we know
that the network's steady-state distribution is simply:

$$
p(\mathbf{n}) = \prod_{i=1}^{J} p_{i}(n_{i})
$$

The important point here is that each queue must have a well-defined
steady state. If not, then the product form rule does not apply. So then,
how do we determine if each queue in a network has a well-defined steady
state? For that we need to calculate the flow balance equations.

### Flow Balance

The flow balance equations for a network with $$J$$ queues is a set of
$$J$$ equations that can be solved to find the effective arrival rate
$$\lambda_{i}$$ at each queue $$i$$.

Looking back at our matrix of routing probabilities, it should be apparent
that any queue can receive customers from the outside world, but also that
customers can flow in cycles through the network. Nothing in the Jackson
model requires that the network is acyclic.

More formally, the flow balance equations for a Jackson network with $$J$$
nodes is given by:

$$
\lambda_j = \lambda_{0j} + \sum_{i=1}^{J} \lambda_i \cdot p_{ij}
$$

Working through this we see that the effective arrival rate at each queue
$$j$$ is $$\lambda_j$$, the sum of all arrivals from other queues,
adjusted by the corresponding routing probability, plus the arrivals from
outside the system.

Our sample network is a special case network: a feed-forward network. In
a feed forward network, the network must be acyclic and customers cannot
appear in the same queue more than once. Calculating flow balance for such
networks is greatly simplified as we can see by working through the flow
balance for each queue:

$$
\begin{align}
\lambda_1 &= \lambda \\
\lambda_2 &= 1/2 \lambda \\
\lambda_3 &= 1/2 \lambda
\end{align}
$$


[1]: /maths/performance/2016/03/07/multi-server-queues.html
