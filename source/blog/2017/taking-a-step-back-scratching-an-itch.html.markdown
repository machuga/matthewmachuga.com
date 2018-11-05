---

title: Taking a Step Back & Scratching an Itch
date: 2017-08-14 00:00 UTC
tags: JavaScript, Webtask, NPM, cli

---

I’ve been spending the past two weeks adjusting to working at Auth0. Thus far
everything’s been great. The domain is interesting and challenging, the
problems are fun, and there are a **lot** of smart people working here. While I’ve
been getting up to speed, I’ve been working on a new bit of functionality and
learning a few of our products. The one that’s been getting a lot of my time
this week is our [Webtask.io](https://webtask.io) platform.

The elevator pitch for [Webtask.io](https://webtask.io) is that it allows you
to make serverless HTTP endpoints with Node. It’s a pretty neat concept,
similar to AWS Lamdbda or Google Cloud Functions. One thing that we do is allow
you to require a number of modules from npm without worrying about bundling
them yourself. For determining what packages are available, I’ve been utilizing
a solution developed by one of my coworkers, [Pablo
Terradillos](https://twitter.com/tehsis), hosted at
[canirequire](https://tehsis.github.io/webtaskio-canirequire/). `canirequire`
lets anyone search for their favorite npm module to see if it’s already
available inside of a Webtask script. It’s been really handy and appreciated.

Over the weekend I was trying to get a little bit further on my task at work,
when I realized I need to just take a step back and solve a different problem
for a while. My mind immediately went to converting canirequire to a CLI script
so that I could search for packages without leaving my terminal. After about 30
minutes of tinkering around, since Pablo had already taken care of any of the
challenging bits, I was able to publish
[canirequire-cli](https://www.npmjs.com/package/canirequire). All it really does it
call the webtask endpoint that tells me what packages we support, transform the
data a bit, and then run a regex search over the modules to see if any match
what I’m looking for. Once the search is done it simply returns a JSON response
and ends.

The problem wasn’t hard at all, but it was enough to redirect my mind elsewhere
and scratch my own itch.

If you want to put some code up on Webtask.io, give the package a try:

```
$ npm install -g canirequire-cli
$ canirequire request
{
 "request": [
  "2.67.0",
  "2.55.0",
  "2.56.0",
  "2.81.0",
  "2.27.0"
 ],
 "request-progress": [
  "0.3.1"
 ],
 "request-promise": [
  "1.0.2"
 ],
 "request-replay": [
  "0.3.0"
 ],
 "xmlhttprequest": [
  "1.7.0"
 ]
}
 ```
