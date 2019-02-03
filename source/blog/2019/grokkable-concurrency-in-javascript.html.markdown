---

title: Grokkable Concurrency in JavaScript
date: 2019-02-03 19:30 UTC
tags: javascript, callbacks, series, gcj

---

**NOTE:** This is the first post in a series on Concurrent Programming in JavaScript.

## Introduction to the Problem
[Callback Hell](http://callbackhell.com/) is something you’ll hear many JavaScript developers refer to, and not endearingly. It is a very real place, and is to be feared, but it is fortunately something that can be avoided with a number of tactics. We will be reviewing a prime example of Callback Hell code to study and begin understanding its weaknesses so that we can begin to learn ways to clean it up. The logical place to starts seems to be with  focusing solely on callbacks, but there is so much more to learn!

## Problems in the Inferno

```javascript
const get = require('./get'); // get(url, callback)

const githubApi = 'https://api.github.com';
const githubEventsUrlFor = username => `${githubApi}/users/${username}/events`;
const githubRepoUrlFor = repo => `${githubApi}/repos/${repo}`;

const fetchReposForLatestActivity = (user, callback) => {
  let timeout = setTimeout(function() {
    callback(new Error('Timed out'));
  }, 3000);

  get(githubEventsUrlFor(user), (err, allEvents) => {
    if (err) {
      return callback(err);
    }

    const events = allEvents.slice(0, 3);
    const repos = [];
    let remainingCount = events.length;

    events.forEach(event => {
      get(githubRepoUrlFor(event.repo.name), (err, data) => {
        if (err) {
          return callback(err);
        }

        repos.push({
          author: data.owner.login,
          avatar: data.owner.avatar_url,
          name: data.name,
          full_name: data.full_name,
          url: data.html_url,
          description: data.description
        });

        remainingCount -= 1;

        if (remainingCount <= 0) {
          clearTimeout(timeout);
          callback(null, repos)
        }
      });
    });
  });
};

fetchReposForLatestActivity('machuga', (err, repos) => {
  if (err) {
    console.error(err);
    return;
  }

  console.log(repos);
});
```
The above figure is an example of  some code that starts pushing out to the right pretty quickly. What do I mean by pushing to the right?

## Nesting
Look above at how the code starts indenting further and further to the right depending on which level of callback nesting we're at. At the deepest point, we are 3 callbacks deep, and there is even a bit of iteration involved to push it out further - which adds its own extra level of complexity we'll address in a moment. To be clear, it is not necessarily the number of spaces (that's right, not tabs, internet) from the left margin that cause conflict; though harder to read, the biggest issue it causes is nested context.
The most deeply nested part in our code knows about and mutates the `timeout` variable we set in the upper-most `fetchReposForLatestActivity` function, and also knows about the original callback sent into that function. Even at the current length, but doubly so if this function was longer, it'd be very easy to start losing mental context of what variable is declared where. It's hard to remember what variables are still in scope, what you've accidentally changed, etc. from parent scopes. It is a very easy way to cause unexpected behavior and a good way to lose yourself in your code. Additionally, if you aren't cautious how you nest your scopes, letting variables from higher lexical scopes be used in lower ones, it can make extracting functions a bit of a challenge later.

## Error Handling
Explicit error handling is a good thing. Go, for example, embraces it as a first class citizen, where functions can return an error along with the intended return value. However, in JavaScript, error handling is all conventional, and thus sometimes things can surprise you. For instance, with traditional NodeJS style error handling (used in this figure), when errors are thrown from a function, the error should be sent as the first argument of the callback. Another style that pops up is the `errback`, where there is a second, separate callback to handle the error case, and the success callback does not receive an error argument.
Example:

```javascript
function doAThing(errback, callback) {
  if(wrongThingHappens) {
	  return errback(new Error('oops'));
  }
  callback('success');
}

doAThing(console.error, console.log)
```

There are other libraries that will, intentionally or unintentionally, throw the error in a destructive way (not sending it to the callback) if the error is thrown synchronously. This is a great way to cause unexpected behavior, and has caused me some grief over the years. This is definitely an area where consistency can help.
## Only-Once
Let's take a look at how we call our `fetchReposForLatestActivity` function:

```javascript
fetchReposForLatestActivity('machuga', (err, repos) => {
  if (err) {
    console.error(err);
    return;
  }

  console.log(repos);
});
```

Despite the size of the underlying function and numerous HTTP calls it protects us from worrying about, it is a pretty simple function. We pass it a `username` and a callback, and it will either send us an error or a list of repositories back. Great! Now what if we want to cache those repositories for a bit to avoid needing to make extraneous calls over the network? I have seen this done in so many terrifying ways (and done a few myself when I started writing JS) that I will not enumerate in this post, but the gist of it: If you are using timeouts or setting a cache value in a higher scope without ensuring you have something like a lock to prevent updating a variable multiple times, you are probably on the wrong path.  Even our iteration over repos in the above examples isn't perfect.

This can introduce challenges for structuring code because if you want to have any other code that uses the list of repos, they must be called from within the above callback to have the `repos` variable in scope. This comes right back to nesting. The solutions to these problems aren't hard, they just take a shift in thinking if you've only done synchronous programming up until this point.

## Iteration with Callbacks
Here be dragons.  Let's take a look at a shortened version of our iteration above:

```javascript
const repos = [];
let remainingCount = 0;

events.forEach(event => {
  get(githubRepoUrlFor(event.repo.name), (err, data) => {
    if (err) {
      return callback(err);
    }

    repos.push(...);

    remainingCount -= 1;

    if (remainingCount <= 0) {
      clearTimeout(timeout);
      callback(null, repos)
    }
  });
});
```

What we do is set a variable, `remainingCount` to be equal to the length of the array we are using. In our case, we have 3 events. Then every time a callback from `get` gets executed we decrement the value of `remainingCount` by one, and then when `remainingCount` becomes `0`, we know all `get` requests have completed and can execute the callback passed into our `fetchReposForLatestActivity` function. We also clear the timeout set earlier in the function so that if any HTTP requests get stuck we can still abort the `fetchReposForLatestActivity`  function. If any HTTP requests come back with an error, then we have chosen to fail immediately and call  `callback` with the error we received. It should be noted that I did not handle any actual clean up of cancelling HTTP requests and other such things for brevity.

## Cleaning up the Code
How can we clean up these various things? That’s what we’re going to cover over the next several blog posts - first with callbacks, then with Promises and other constructs. We’ll also go into more advanced patterns for handling common situations you’ll find yourself in when dealing with processing data, like sequential processing, concurrent processing, and more. I’d like to keep each one succinct enough to read quickly and search back through for quick references as you need them, so I will try to keep the amount of material to learn in each post limited. This will go from beginner to more advanced topics fairly quickly.

If you want to keep up to date with updates, please subscribe to my [mailing list](https://matthewmachuga.com) or [RSS feed](https://matthewmachuga.com/blog/feed.xml).

