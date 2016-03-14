---
layout: post
title: Queue Networks
categories: maths performance

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
model requires that the network is acyclic. Thus the effective arrival rate for
each queue must account for arrivals from outside and for arrivals from all
other queues within the network.

More formally, the flow balance equations for a Jackson network with $$J$$
nodes is given by:

$$
\lambda_j = \lambda_{0j} + \sum_{i=1}^{J} \lambda_i \cdot p_{ij}
$$

Working through this we see that the effective arrival rate at each queue
$$j$$ is $$\lambda_j$$, the sum of all arrivals from other queues,
adjusted by the corresponding routing probability, plus the arrivals from
outside the system.

Our sample network is a special case: a feed forward network. In
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

Recall from [the discussion of $$M/M/1$$][2] queues that the stability
condition for $$M/M/1$$ is that $$\rho = \lambda / \mu < 1$$. If this condition
holds for each of our queues, then we know that our network has a steady state
distribution given by Jackson's theorem. Using the service rates from the
diagram above we can calculate $$\rho$$ for each of our queues:

$$
\begin{align}
\rho_1 &= \lambda_1 / \mu_1 = 500 / 800 = 0.625 \\
\rho_2 &= \lambda_2 / \mu_2 = 250 / 500 = 0.5 \\
\rho_3 &= \lambda_3 / \mu_3 = 250 / 500 = 0.5
\end{align}
$$

Since $$\rho < 1 $$ for all our queues we know that each queue is stable and
thus the network is stable.

### Steady-State Probabilities

With the knowledge that our network has a well-defined steady state, we can
apply Jackson's theorem to calculate the steady-state probabilities for our
network.

The steady-state probability for an $$M/M/1$$ queue is $$p(n) = (1 - \rho)
\rho^n$$. Applying the product rule for Jackson network we get:



$$
\begin{align}
p(\mathbf{n}) &= (1 - \rho_1) (1 - \rho_2) (1 - \rho_3) \rho_1^{n_1} \rho_2^{n_2} \rho_3^{n_3} \\
 &= 0.375 \cdot 0.5 \cdot 0.5 \cdot 0.625^{n_1} \cdot 0.5^{n_2} \cdot 0.5^{n_3} \\
 &= 0.09375 \cdot 0.625^{n_1} \cdot 0.5^{n_2} \cdot 0.5^{n_3} \\
\end{align}
$$

Let's now calculate the probability that we have two customers at each of the
queues, that is let's calculate $$p(\langle 2, 2, 2 \rangle)$$:

$$
\begin{align}
 p(\langle 2, 2, 2 \rangle) &= 0.09375 \cdot 0.625^{n_1} \cdot 0.5^{n_2} \cdot 0.5^{n_3} \\
 &\approx 0.0022888
\end{align}
$$

## Latency of Queue Networks

As with all of the queue models we've seen so far, the steady-state
probabilities are not that interesting on their own. Rather, we are interested
in the results that follow from these probabilities. To determine the average
latency for the network $$W_{net}$$ recall Little's Law:

$$
L = \lambda W
$$

The mean number of customers $$L$$ is equal to the arrival rate $$\lambda$$
multiplied by the mean latency $$W$$. We know the arrival rate for our network,
so we if can calculate the mean number of customers in the network, the latency
will follow. Since we are able to consider each queue in isolation after
solving the flow balance equations, it is enough to calculate the mean number
of customers for each queue and then sum them:

$$
L_{net} = \sum_{i=1}^{J}L_i = \sum_{i=1}^{J} \frac{\rho_i}{1 - \rho_i}
$$

[1]: /maths/performance/2016/03/07/multi-server-queues.html
[2]: /maths/performance/2016/02/20/service-latency-and-utilisation.html
