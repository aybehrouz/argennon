Consensus
=========

Estimating A User’s Stake
-------------------------

In a proof of stake system the influence of a user in the consensus
protocol should be proportional to the amount of stake the user has in
the system. Conventionally in these systems, for estimating a user’s
stake, we use the amount of native system tokens the user is holding.
Unfortunately, one problem with this approach is that a strong attacker
may be able to obtain a considerable amount of system tokens, for
example by borrowing from a DEFI application, and use this stake to
attack the system.

To mitigate this problem, for calculating a user’s stake, instead of
using the raw ALGO balance, we use the minimum of a *trust value* that
the system has calculated for the user and the user’s ALGO balance:

*Stake*<sub>*user*</sub> = min (*Balance*<sub>*user*</sub>, *Trust*<sub>*user*</sub>)

For estimating the value of *Trust*<sub>*user*</sub> we
use the exponential moving average of the user’s ALGO balance.
Therefore, in our system a user who held ALGOs and participated in the
consensus for a long time is more trusted than a new user with a higher
balance. An attacker who has obtained a large amount of ALGOs, also
needs to hold them for a long period of time before being able to attack
our system.

For calculating the exponential moving average of a time series at the
time step *t*, we can use the following recursive formula:

*M*<sub>*t*</sub> = (1 − *α*)*M*<sub>*t* − 1</sub> + *αX*<sub>*t*</sub> = *M*<sub>*t* − 1</sub> + *α*(*X*<sub>*t*</sub> − *M*<sub>*t* − 1</sub>)

Where:

-   The coefficient *α* is a constant smoothing factor between 0 and 1
    which represents the degree of weighting decrease, A higher *α*
    discounts older observations faster.

-   *X*<sub>*t*</sub> is the value of the time series at the time step
    *t*.

-   *M*<sub>*t*</sub> is the value of the EMA at the time step *t*.

Usually an account balance will not change in every time step, and we
can use older values of EMA for calculating *M*<sub>*t*</sub>:

*M*<sub>*t*</sub> = (1 − *α*)<sup>*t* − *k*</sup>*M*<sub>*k*</sub> + \[1 − (1 − *α*)<sup>*t* − *k*</sup>\]*X*

Where:

*X* = *X*<sub>*k* + 1</sub> = *X*<sub>*k* + 2</sub> = … = *X*<sub>*t*</sub>

When |*nx*| ≪ 1 we can use the binomial approximation
(1 + *x*)<sup>*n*</sup> ≈ 1 + *nx* to further simplify this formula:

*M*<sub>*t*</sub> = *M*<sub>*k*</sub> + (*t* − *k*)*α*(*X* − *M*<sub>*k*</sub>)

For choosing the value of *α* we can consider the number of time steps
that the trust value of a user needs for reaching a specified fraction
of his account balance. We know that for large *n* and |*x*| &lt; 1 we
have (1 + *x*)<sup>*n*</sup> ≈ *e*<sup>*nx*</sup>, so by letting
*M*<sub>*k*</sub> = 0 and *n* = *t* − *k* we can write:

$$\\alpha =- \\frac{\\ln\\left(1 - \\frac{M\_{n+k}}{X}\\right)}{n}$$

The value of *α* for a desired configuration can be calculated by this
equation. For instance, we could calculate the *α* for a relatively good
configuration in which *M*<sub>*n* + *k*</sub> = 0.8*X* and *n* equals
to the number of time steps of 10 years.
