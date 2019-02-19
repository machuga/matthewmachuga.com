---

title: Waiting on Multiple Callbacks
date: 2019-02-18 23:59 UTC
tags: javascript, callbacks, series, gcj

---

First, a refresher on asynchronous functions utilizing callbacks:

```javascript
setTimeout(() => {
	console.log('One second later');
}, 1000);
```

The above code will log `One second later` to the console after at least a one
second delay (timing isn't precise in JS, but it'll usually be close...but I
digress). `setTimeout` accepts a callback to be executed after a set number of
milliseconds that are passed in as the second argument. We, the developer of a
JavaScript application, do not need to be concerned what happens inside of the
`setTimeout` function, we just need to understand that the event loop will
continue running, and after `1000` milliseconds our callback will be executed.

Plenty simple! But what happens when you have a number of asynchronous actions
you need completed before performing another action? Well in JavaScript proper,
there are no primitives for handling this situation with callbacks. You are
left to implement this logic on your own (or use a convenient library like
`async`, which is linked at the bottom). But never fear! If you've read the
past article you've already seen the code to handle this. This time we'll walk
through how and why this works.

Let's start off by assuming we have an array of four numbers representing
milliseconds.

```javascript
const durations = [250, 500, 750, 1000];
```

Next we're going to create a function that:

1. Takes an array of `n` numbers
2. Creates `n` timeouts based on the values in the array
3. Each timeout will output its duration upon completion
4. Upon all timeouts completing, will execute a callback that was passed in.

```javascript
const createTimeouts = (durations, callback) => {
	let remainingCount = durations.length;

	durations.forEach((duration) => {
		setTimeout(() => {
			console.log(`I completed in ${duration} milliseconds`);

			remainingCount -= 1;

			if (remainingCount <= 0) {
				callback();
			}
		}, duration);
	});
}
```

Finally, we'll invoke the function and pass in a function that will write out
to the console `We are all done!`. So if we save the whole thing:

```javascript
const durations = [250, 500, 750, 1000];

const createTimeouts = (durations, callback) => {
	let remainingCount = durations.length;

	durations.forEach((duration) => {
		setTimeout(() => {
			console.log(`I completed in ${duration} milliseconds`);

			remainingCount -= 1;

			if (remainingCount <= 0) {
				callback();
			}
		}, duration);
	});
}

createTimeouts(durations, () => {
	console.log("We are all done!");
});
```

and then execute the script, we'll see each timeout execute in order every
quarter second, with `1000` being swiftly followed by `We are all done!`

```
I completed in 250 milliseconds
I completed in 500 milliseconds
I completed in 750 milliseconds
I completed in 1000 milliseconds
We are all done!
```

There is no magic here! We're using an integer, `remainingCount` set to the
length of the number of callbacks we're going to execute. Then on every
callback execution we decrement `remainingCount` by one, and subsequently check
to see if we've reached `0`. If not, we keep going, but if `0` has indeed been
reached we're going to call the callback that's been passed into the
`createTimeouts` function to let the caller know that everything's been
completed.

Was that a bit underwhelming? Like most things in computer science, this
potentially challenging problem could be solved with a little bit of math.
Lucky for us!

## Handling `n` Functions Generically (and Naively)

Maybe you don't want to write this looping code every time - maybe you are
worried you may make a mistake, or you prefer not utilizing imperative
constructs when possible. We can turn this into a generic helper pretty
quickly, but we should define what we want first since there are many different
ways we may want this information returned.

I want to create a function, we'll call it `whenAllSettled`, that will accept a
list of functions accepting node-style callbacks `(err, result) => {}`, and
will execute each one in order. All executions, whether successful
or failures, will store an object with the keys `type` and `value` into a list
`results`. When no error is raised, the `type` key will be set to `success`,
and `value` set to whatever `result` was in the callback. When an error was
thrown, we will set `type` to `failure` and `value` to be the `Error` object
sent to the callback.

To test it out, we'll nest two levels of `whenAllSettled` to demonstrate that
it will wait for all of the first callbacks to complete, and that it can be
nested to wait in different ways.

Let's see what this looks like:

```javascript
const callbacks = [
	(done) => { setTimeout(() => { done(null, '1') }, 500) },
	(done) => { setTimeout(() => { done(null, '2') }, 200) },
];

const whenAllSettled = (fns, callback) => {
	const results = [];
	let remainingCount = fns.length;

	const done = (err, result) => {
		let resultObject;

		if (err) {
			resultObject = { type: 'failure', value: err };
		} else {
			resultObject = { type: 'success', value: result };
		}

		results.push(resultObject);

		remainingCount -= 1;

		if (remainingCount <= 0) {
			callback(null, results);
		}
	};

	fns.forEach((fn) => {
		fn(done)
	});
}

whenAllSettled(callbacks, (err, results) => {
	console.log("All done with round 1!", results);

	whenAllSettled([
		(done) => { setTimeout(() => done(new Error('oops')), 500); }
	], (err, results) => {
		console.log("All done with round 2!", results);
	})
});


```

Now if we run this code we can watch the output pop up over time:

```
All done with round 1! [ { type: 'success', value: '2' }, { type: 'success', value: '1' } ]
All done with round 2! [ { type: 'failure',
    value:
     Error: oops
         at Timeout.setTimeout [as _onTimeout] (/Users/machuga/src/book-examples/multipleCallbacksGeneric.js:37:37)
         at listOnTimeout (timers.js:324:15)
         at processTimers (timers.js:268:5) } ]
```

So that's cool - our functions wait till the appropriate time to execute, and
both successful and failures get returned properly. But if you are looking
carefully, you'll notice something a bit out of place.

```javascript
const callbacks = [
	(done) => { setTimeout(() => { done(null, '1') }, 500) },
	(done) => { setTimeout(() => { done(null, '2') }, 200) },
];
```

At the top we defined the `callbacks` array with two functions, the first
executed `done` with `1`, and the second with `2`; however, in our output we
can see that `2` was returned first and `1` came in after. This is because the
timeout for the first callback was longer (`500`) than the second (`200`). The
fact that the results can be returned out of their executed order can cause
non-deterministic results from our function - we can't be sure which
data comes from which function.

## How to Maintain Order

So we know that if we have callbacks firing whenever they please, and then the
results are being inserted into an array at that time, there is no guarantee on
what order our callbacks will be in. So we need a way to track the order as we
add them to our list of results. Courtesy of indexing into arrays, this is pretty
straight forward.

We're going to change our iteration over the callback functions:

```javascript
fns.forEach((fn) => {
  fn(done);
});
```

to also pass in the index to the looping function. If you haven't seen it before,
the function passed to `forEach` takes more than one argument. The first argument
is the value, but the second value is the index. So we're going to take that index
and pass it along to the `done` function. Our loop will now look like this:

```javascript
fns.forEach((fn, i) => {
  fn(done(i));
});
```

If you recall, our `done` function only accepts an `err` and a `result`, so we will
need to modify it to instead *return* a function that accepts an `err` and a `result`.
`done` will now accept an integer, and instead of running

```javascript
results.push(resultObject);
```

we will save directly to the index like this:

```javascript
results[i] = resultObject;
```

Now when we rerun our script we'll see our results are returned in the order in
which we passed in their functions.

```
All done with round 1! [ { type: 'success', value: '1' }, { type: 'success', value: '2' } ]
```

You can view the final version
[here](https://gist.github.com/machuga/e0dae53637be1ed6b3a97923cfadc775#file-callback-purgatory-2-multiple-callbacks-js).

## Wrap Up

So that's how to make a function that will wait for `n` functions to complete
and pass their results into callback in the order they were given. Hope that helps remove
any of the magic feeling behind it.

However, you may not want to write this yourself every time you want to work on
some code with callbacks. Good news! There is an awesome library,
[async](https://caolan.github.io/async/) that is capable of doing all of the asynchronous
magic with callbacks I'm going to demonstrate in this series! It's been battle tested
for years, so it's ready for you to use in your production code.

One thing you may be wondering: if this all happens asynchronously, how can I
be sure that `remainingCount` will ever reach `0`? Or will not go further than `0`?
Can't a race condition occur? Next article I'm going to walk through the basics of the
JavaScript event loop to ensure we have a solid working understanding before we continue
refactoring our asychronous code from earlier in the series.
