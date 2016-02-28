---
layout: post
title:  "Reject Them or Make Them Wait?"
date:   2016-02-27 17:00:00 +0000
categories: maths performance
---

After showing my [previous post][1] around at [work][2], a colleague responded
with [this article][3] in which the author compares the performance of
a Java EE application running on Windows and on Linux. When running on
Linux, the application exhibits the performance characteristics outlined
in my post: at high utilisation, latency grows uncontrollably. What might
be surprising however is that on Windows, latency doesn't change much at
all, even at high utilisation. Does this mean that the results we saw for
$$M/M/1$$ queues are wrong? Not quite! Whereas the Linux results show
increased latency at high utilisation, the Windows results show an
**increased error count**; at high utilisation Windows is simply dropping
open connections and kicking waiting customers out of the queue.

Recall from the discussion on $$M/M/1$$ queues that we assumed the
queue was of infinite size. No matter the load, there's always space for
a new customer in an $$M/M/1$$ queue. The behaviour exhibited by the
Windows system in the article isn't that of an infinite queue, but instead
that of a finite queue. At some limit - the precise details of which are
irrelevant to this discussion - the queue gets full and customers are
rejected.

What's the latency like for a queue that has finite size? If the queue can
reject customers, what's the probability that a potential customer will be
allowed in to the queue? Let's answer these questions by looking at the
$$M/M/1/K$$ model.

An $$M/M/1/K$$ queue behaves much like an $$M/M/1$$, arrivals are
a Poisson process, service times are exponentially-distributed and there
is a single server. However, unlike $$M/M/1$$ queues which allowed an
unbounded number of customers into the system at any time, $$M/M/1/K$$
queues have an upper bound of $$K$$ customers.

## Steady-State Probabilities

All of the interesting calculations for $$M/M/1/K$$ queues depend on the
steady-state probabilities, that is, the probability $$p_{n}$$ that there
are currently $$n$$ customers in the queue:

$$
p_{n} =

\begin{cases}
\frac{(1 - \rho)\rho^{n}}{1 - \rho^{K + 1}} & (\rho \neq 1)\\
\frac{1}{K + 1} & (\rho = 1) \\
\end{cases}
$$

Where $$\rho = \lambda / \mu$$, $$\lambda$$ is the arrival rate and
$$\mu$$ is the service rate. Unlike the steady-state probabilities for
$$M/M/1$$ queues, the probabilities for $$M/M/1/K$$ queues are defined for
$$\rho \geq 1$$ thanks to the limiting factor of $$k$$.

## Average Customers in the System

Using the steady-state probabilities this we can now calculate the average
number of customers in the system $$L$$:

$$

L = \sum_{n=0}^{K} n \cdot p_{n} \\

$$

[1]: /maths/performance/2016/02/20/service-latency-and-utilisation.html

[2]: http://www.skipjaq.com

[3]: http://www.webperformance.com/library/reports/windows_vs_linux_part1/
