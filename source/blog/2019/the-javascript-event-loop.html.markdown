---

title: The JavaScript Event Loop
date: 2019-03-22 00:00 UTC
tags: javascript, callbacks, series, gcj

---

A wild JavaScript code snippet appears!

```javascript
const log = (output) => { console.log(`--${output}--`); };

log("first");

setTimeout(function fifth() { log("fifth"); }, 500);
setTimeout(function third() { log("third"); }, 0);
setTimeout(function fourth() { log("fourth"); }, 0);

log("second");
```

For a boss-fight JavaScript code snippet that has more use cases, please
[check out this
gist](https://gist.github.com/machuga/e0dae53637be1ed6b3a97923cfadc775#file-eventloop-boss-fight-js)

## Spoiler Alert / TL;DR

I have the order of execution given out as `first` through `fifth` for clarity
and to make it so readers can skim this and be on their way when they need a
reference.

### Slightly More TL;DR

JavaScript will run a function until completion (ignoring iterators), so there
is no JS-level function interleaving. This means that you will not run into the
same race conditions you may hit in C, C++, or other languages with threading.
The JS engine under the hood is indeed using threads and waiting for
asynchronous actions concurrently; however, JS-level code will run top-down
sequentially in the current stack frame.

# Order Matters

JavaScript, as mentioned in previous blog posts (and above in the second TL;DR
section), executes from top to bottom. That means that in our above snippet,
every line is going to get executed before any other JavaScript in the same
process is executed. So on line 1, we define a function that we assign to the
variable `log` that adds some extra formatting to a standard `console.log`
call. Great! Now we can use that throughout our code.

So we proceed to line 3, which invokes this new function and passes along the
string `first` to be output to the console. Because both `log` and `console.log` are
synchronous functions, meaning they do not escape the event loop, this code will
first evaluate `log`, enter the function, evaluate `console.log` which is
native code, and then return `undefined` from both function because we do not
specify a return value.

The JS runtime does not move onto anything else during this time, it only
evaluates this code. After it returns it is free to move on to line 5:

```javascript
setTimeout(function fifth() { log("fifth"); }, 500);
```

This is where things start to break down the 4th wall and start reaching
into asynchronous territory. `setTimeout` is a magical function (no, not
really) that sets a timer with the JS runtime. The JS runtime effectively sets
an eggtimer for `500` milliseconds, puts it down on a counter, and then returns
back to the calling function. Unlike my `log` function, `setTimeout` actually
does have a return value - an identifier of the timer it just set. It's outside
of the scope of this demo, but if you wanted to cancel your timer, you could
run `clearTimeout(idOfTimeout)`, and the callback you passed would never be
executed. But I digress.

Anyway, now we've returned from the first `setTimeout` and proceed to the next.
It is largely the same as the last call, except for one notable difference:

```javascript
setTimeout(function third() { log("third"); }, 0);
```

The timeout is set to `0`. What does your gut tell you will happen here? The
timeout is set to `0` milliseconds, so hypothetically that could mean `run
right now`. However, that is not the case. `setTimeout` sets a timer in the
background, and those timers cannot be executed until the current block of
JavaScript code has completed execution. So, the same metaphorical eggtimer
gets set, with a time of `0`. So even if the timer goes off by the time we
return from this timeout, our friendly runtime can't do anything about it
because we are blocking the runloop with our pesky code. Well let's carry on
then.

The next line is the same as the one before, I just wanted to make a point of
it to show that these messages get stacked up on a queue and will get executed
in the order they're dropped into the timer. So in this situation, these
functions will be run in their respective numerical order. Perfect.

Finally we run into our last line:

```javascript
log("second");
```

This call says `second`, but is the last line of the file. And it is even
correct! When this program runs, it will be the second line of code to write
text to the console because it is synchronous, like the first call to `log`. So
it's going to execute, write code to your console, return, and then this block
of JavaScript has completed execution!

The console output at this point will look like this:

```
--first--
--second--
```

If this was run with NodeJS, and there
were no timers or other event listeners configured, your program would now
exit because its work is done.

However, we setup three different timers, so its work is not yet complete.
Since there was a `0` millisecond delay (remembering from previous posts that
in JavaScript this means *at least* `0`, not exactly `0`) from our second and
third `setTimeout` calls, our runtime can finally put those eggtimers away
and will run the functions we passed into those `setTimeout` calls. Our output
will now look like this:

```
--first--
--second--
--third--
--fourth--
```

Our runtime is just going to hang out for a bit, waiting for something else to
happen. In this sitation, there is nothing else waiting to run except for tour
timer. So after a grueling `500` milliseconds (at least `500` from when it was
set, our final timer will go off, and the callback passed in will execute,
leaving us with the final console output:

```
--first--
--second--
--third--
--fourth--
--fifth--
```

At this point, the runtime's work is done and as it bids you adieu the program
will exit.

This is the basic formula for how asynchronous actions in the event loop
functions. Network calls, file operations, event callbacks, etc.
all behave similarly. They have functions implemented at the native level
that allow access to a three underlying runtime's thread pool and can dispatch
actions outside of the main JS thread. When they call back, the JS runtime
receives an event, and at the next tick, or iteration of the event loop, those
events will have a chance to execute. I've included a link below to how
NodeJS's event loop runs, which covers the various phases it includes. Browser
runtimes function similarly but may have different phases or timings.

# Resources and Citations

There are many excellent resources for deep explanations of event loops.
These two are my favorite:

* [MDN Concurrency model and Event Loop](https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop)
* [The NodeJS Event Loop Official Docs](https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/)
