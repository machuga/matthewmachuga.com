---

title: Compiling ES2017 with Babel for Node
date: 2017-08-07 00:00 UTC
tags: JavaScript, Auth0, Node, Babel

---

A long time ago I swore off compiling code I intended for NodeJS. I had
originally done this with some production CoffeeScript code back in 2013 and it
brought on a number of headaches — harder debugging, incompatibility with
modules, and extra indirection. I’m not entirely sure I’d call it a mistake;
CoffeeScript allowed us to move quickly with some advanced language features
that weren’t yet available in Node and that helped us build our app quickly.
However, those headaches I mentioned started to slow us down over time and I
quickly became jaded on the topic. After noticing at Auth0 we compile some code
at runtime with Babel, I figured I should open my mind and be willing to try
again.

Node has most modern features implemented; however, once you get used to the
ES2015 module spec it can be challenging going back to the standard Node/Common
`require`/`module.exports` way of doing things. At Auth0 we also may have our
extensions running on an LTS version of NodeJS rather than the most recent
release so I’d rather ensure that features I expect to be present are, in fact,
available.

Since some of our other extensions compile with Babel, I figured I’d fall in
line and try to create a new extension using the same pipeline. While some only
compile with the `es2015` preset, I figured I’d go for `es2017` because A: It’s
2017, and B: I wanted to ensure the spread ( `...` ) operator was available in
whichever version of Node the service used.

# Babel Configuration

The important part of the configuration lies with the `presets` key. We use
`.babelrc` for our Babel setup, so my file initially looked something like this:

```json
{
  "presets": ["es2017"]
}
```

I then, from another extension, borrowed a chunk of code to make Babel
transform things on the fly and shoved it into its own module at `lib/babel.js`.

```js
// Initialize Babel for the rest of the app

module.exports = function loadBabel() {
  require('babel-register')({
    sourceMaps: !(process.env.NODE_ENV === 'production')
  });
  require('babel-polyfill');
};
```

Since performing this operation has a global side-effect, I wanted to make sure
I stuck it behind a function with an explicit name so that it was obvious what
I was doing when I imported the module and ran the function with near the top
of my `index.js` file:

```js
const loadBabel = require('./lib/babel');
//...
loadBabel();

// Or, more condensed but less obvious:
require('./lib/babel')();
```

With that loaded I assumed I was good to go and tried to import another module.
We’ll say it was `import foo from './bar'`. I expected great things, but when I
ran the app with `node ./index.js` I was greeted with an error:
`Syntax Error: Unexpected token import` — `import` wasn’t recognized and was invalid. This struck
me as odd and I spent somewhere around a half hour jumping around in my code
assuming I made a typo somewhere or wasn’t using `babel-register` or
`babel-core/register` correctly. I’ll save you the same steps, but my salvation
came in the form of a
[GitHub issue comment](https://github.com/avajs/ava/issues/1139#issuecomment-264921916)
where a very logical, albeit not-obvious solution if you've only used `es2015`, was given:
`es2017` preset only compiles down to `es2016`.

![Very logical, but not obvious](https://cdn-images-1.medium.com/max/1600/1*z0afYoDEuGcUyAc90zsGfw.gif)

If you’ve used Babel, this probably seems clear, at least after being stated. Or
perhaps, like me, you assumed `es2017` to be packaged up to include `es2016`
and `es2015` presets by default. However, it is more logical that `es2017` need
only be composed of things to compile down to the next lowest target. What if
the runtime supports `es2016` and we only need a few features from `es2017`?
Running passes over the code for lower targets would start dropping the target
to lower levels than what’s needed. No sense in doing more work, or potentially
de-optimizing code for lower targets. As such, that makes the choices for
`es2016` and higher very logical and almost obvious (once you expect it).

So we then have two ways to solve the problem. One way, if your version of Node
has all features from the ES2015 and ES2016 specs, is to simply import the
Babel plugin to handle ES2015
modules,babel-plugin-transform-es2015-modules-commonjs , and then add it to our
.babelrc file like this:

```json
{
  "presets": ["es2017", "transform-es2015-modules-commonjs"]
}
```

Or we can take the more costly, but more inclusive, route of importing both
`es2016` and `es2015` presets from npm and including those in our `.babelrc` file.

```json
{
  "presets": [
    "es2017",
    "es2016",
    "es2015"
  ]
}
```

This will let all included presets perform their necessary duties and output
some ES5-friendly code at the end. I opted for the latter until I could verify
the version of Node on the servers, but once I reran my code with those presets
in place, the existing code and imports executed perfectly fine and I was ready
to write the rest of my modules as ES2015 ones.

I hope this helps you debug your issue if you’ve landed here after searching
for `Syntax Error: Unexpected token import`, or if you’re about to start a
project in Node or Browser JS, that this will save you some running around.

