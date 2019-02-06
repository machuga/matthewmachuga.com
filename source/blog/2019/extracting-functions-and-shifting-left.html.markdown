---

title: Extracting Functions and Shifting Left
date: 2019-02-06 11:00 UTC
tags: javascript, callbacks, series, gcj

---

Let's take a look at our example from last time:

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

We have a number of different nesting levels going on here and a lot of work
happening in one named function. As with most other areas of programming, this
code would probably do well to be broken apart into logical, well named
functions. But asynchronous code, especially in languages that are lexically
scoped like JavaScript, can sometimes be a bit more challenging to tease apart.
We will start with some low hanging fruit and then move to more involved
extractions in later posts.

## Extract HTTP Requests

The first thing I want to do is extract the embedded HTTP requests into named
functions, that way it is clear what they are doing, and they are easier for us
to talk about. A win for both you the reader of this article and for people
who will eventually read your asynchronous code.

```javascript
const fetchRepo = (repoName, callback) => {
  get(githubRepoUrlFor(repoName), callback);
};

const fetchEventsForUser = (user, callback) => {
  get(githubEventsUrlFor(user), callback);
}
```

Something to note here is that I was able to pass the callback sent to our new
functions directly to the `get` call without an intermediate callback. Why does
this work? We left the invoking code expecting the same callback signature, and
all of our callbacks expect `(error, result)` as an argument list. So we can
save ourself a frame on the callstack (extra compute time and extra garbage to
be collected), and skip over reduncancy that would look like:

```javascript
const fetchRepo = (repoName, callback) => {
  get(githubRepoUrlFor(repoName), (err, repo) => {
    if (err) {
      return callback(err);
    }

    callback(null, repo);
  });
};
```

This small set of extractions makes our main fetching function look like this:

```javascript
const fetchReposForLatestActivity = (user, callback) => {
  let timeout = setTimeout(function() {
    callback(new Error('Timed out'));
  }, 3000);

  fetchEventsForUser(user, (err, allEvents) => {
    if (err) {
      return callback(err);
    }

    const events = allEvents.slice(0, 3);
    const repos = [];
    let remainingCount = events.length;

    events.forEach(event => {
      fetchRepo(event.repo.name, (err, data) => {
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
```

That makes me feel a bit better. A small win, but the asynchronous patterns are
still the same, as is the nesting level. Well until we think of something,
let's just consider breaking our problem down into smaller logical chunks.

## Encapsulating Logic

Let's start by separating the idea of fetching a user from the concept of
making 3 additional requests for the individual repositories. I won't cover how
the iteration works in this post, but will cover that bit more in the next.

I think our best place to separate this code out into a new function is right
after where the events are sliced into a subset of the collection. However, I
am blocked by one thing:

```javascript
clearTimeout(timeout);
```

In that line I'm trying to clear out the timeout we set at the top of the
`fetchReposForLatestActivity` function. We do this in case any of the HTTP
requests take too long, error out, or our counter never reaches 0. Looking
closely, this also includes the `fetchEventsForUser` request.

This could be a blocker because I don't want to need to keep `timeout` from the
lexical scope of the parent function. Thankfully, I don't notice any reason
this timeout *needs* to be cleared at the end of particular requests, just that
it needs to be cleared if all requests complete successfully. In fact...I think
there is an error here. We want the timeout to be cleared on failure too!
Cleaning up old crufty code can be a great way to uncover bugs. Well we can
address that in a bit - one step at a time when refactoring.

Back on topic, let's yank all is code into yet another asynchronous function
and invoke it from the same place.

```javascript
const fetchReposForEvents = (events, callback) => {
  const repos = [];
  let remainingCount = events.length;

  events.forEach(event => {
    fetchRepo(event.repo.name, (err, data) => {
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
        callback(null, repos)
      }
    });
  });
};

const fetchReposForLatestActivity = (user, callback) => {
  let timeout = setTimeout(function() {
    callback(new Error('Timed out'));
  }, 3000);

  fetchEventsForUser(user, (err, allEvents) => {
    if (err) {
      return callback(err);
    }

    fetchReposForEvents(allEvents.slice(0, 3), (err, repos) => {
      if (err) {
        return callback(err);
      }

      clearTimeout(timeout);
      callback(null, repos);
    });
  });
};
```

I like this a lot better for a few reasons:

1. I don't have to care about how events are iterated over inside of the
   `fetchReposForLatestActivity` function anymore - I've decoupled the concept.
   Instead, now it is the responsibility of `fetchReposForEvents` to care about
   the iteration over the multiple HTTP requests, and how repos are trimmed
   down.
2. It shortens up the body of `fetchReposForLatestActivity` into a nice
   consumable chunk. I can see two main error cases right up front, see when
   the timeout gets cleared, and what gets sent back to the callback.
3. That bug we found regarding the `timeout` not being cleared when errors
   occur does not need to interfere with the `fetchReposForEvents` inner
   workings, it will just deal with errors or success inside of the callback it
   fires upon completion.

So did we lessen the nesting level? Technically we did, since the iteration is
no longer within this function, but the callback nesting is still the same.

This wouldn't inherently be a problem in a real codebase, but I'm trying to
teach you something, so this simply will not do.

We'll start looking at some new techniques soon for flatting out our callbacks
soon, but in the next post I think it'd be a good idea to explain how waiting
for multiple callbacks to complete were handled in this app.
