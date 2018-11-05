---
title: Setting up a Quick Dev Environment for React, ES2015, Babel, and Webpack
date: 2015-11-01 11:51 UTC
tags: js, webpack, react, es2015, es6, babel
---

This is going to be short and sweet.  I couldn't find a tutorial that spelled out a way to get a barebones environment setup for React using webpack and ES2015 without something being missing.  This is due in part to the fact that Babel has recently integrated JSX into its core, split things out into more packages, etc.  So here are a list of steps and brief explanations I found from a number of tutorials, namely [this one from Thoughtbot](https://robots.thoughtbot.com/setting-up-webpack-for-react-and-hot-module-replacement), [this one from Twilio](https://www.twilio.com/blog/2015/08/setting-up-react-for-es6-with-webpack-and-babel-2.html), and finally by just reading Babel and React documentation.

## Assumptions
You are running on OSX or Linux with node + npm installed, with node at at *least* version 0.12.x - I'm running 4.2.1.

## Create a new project

Create new directory `newapp` with a subdirectory named `app`

```bash
mkdir -p newapp/app
cd newapp
npm init
```

When you run `npm init` it will prompt you to fill out information about your project.  You can just feed it nonsense for now if you'd like to just get through it for test purposes.

## Install dependencies

### Babel

```bash
npm install babel-cli babel-core babel-preset-es2015 babel-preset-react --save-dev
echo '{\n  "presets": ["es2015", "react"]\n}' > .babelrc
```

Lots of Babel packages!  Let's run through these quickly:

- `babel-core`: Installs Babel itself for usage by other libraries and apps
- `babel-cli`: Installs the Babel CLI tool that you can use for compiling, debugging, etc.
- `babel-preset-es2015`: Installs the plugins available for to compile ES2015 syntax and functionality into ES5.
- `babel-preset-react`: Installs the plugins available for transforming JSX and Flow syntax/types into ES5. If you don't know what [Flow](http://flowtype.org/) is, you can completely ignore that extra bit of info.

I also include a snippet there to create a .babelrc file to load up the `es2015` and `react` plugins.  This could also just be done in the webpack config, but then it wouldn't be available from the CLI so I prefer this method.

### Webpack
Run this next installation command

```bash
npm install webpack babel-loader file-loader webpack-dev-server --save-dev
```

This will install Webpack along with its Babel integration.  Next `file-loader` is a basic file loader for loading static assets into the `dist` directory so everything is one relative location.  Finally I loaded up the `webpack-dev-server` just to make things simple to play with.  You can really use any web server to serve from your `dist` directory, but to get up and running quickly go ahead and use this.

Next create `webpack.config.js` in the root path next to `package.json`, and edit your config to look like this.

```javascript
module.exports = {
  context: __dirname + "/app",
  entry: {
    javascript: "./app.js",
    html: "./index.html",
  },
  output: {
    filename: "app.js",
    path: __dirname + "/dist"
  },
  module: {
    loaders: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loaders: ["babel-loader"]
      },
      {
          test: /\.html$/,
          loader: "file?name=[name].[ext]",
      },
    ]
  }
};
```

This makes the assumption you want to store your JS in `app` and want it to compile to `dist`.  If you'd like to change this, feel free. We've also told it to move `.html` files into the `dist` folder, and for `babel-loader` to be responsible for loading up and `js` or `jsx` files.

We'll create the related files in a moment, but we have one more dependency installation step left.

### React

```bash
npm install react react-dom --save
```

As specified by the [React Documentation](https://facebook.github.io/react/downloads.html#npm), we need both the `react` and `react-dom` packages in order to utilize React, since `React.render`, amongst other things were moved out to the `react-dom` package.

## Testing

Okay now that dependencies are installed, we can give some test runs.

Create a new file `app/index.html` and copy/paste this HTML:

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Webpack, Babel, and React!</title>
  </head>
  <body></body>
  <script src="app.js"></script>
</html>
```

Create a new file `app/app.js` and copy/paste the following:

```javascript
import React from "react";
import ReactDOM from "react-dom";

ReactDOM.render(
  <div>Hello!</div>,
  document.body
);
```

Now to verify that we have everything needed to use Babel and React, we're going to run

```bash
babel app/app.js --presets react
```

In the event `babel` can't be found because something got weird with your path, you can also invoke this with

```bash
./node_modules/babel-cli/bin/babel.js app/app.js --presets react
```

If everything worked as expected, you'll see a printout of the compiled file appear below the command in your shell.

Next we can move on to trying out the whole thing.

If you want to have the command available globally, you can install the `webpack-dev-server` globally by running `npm install -g webpack-dev-server`.  Otherwise, open up `package.json`, locate the `scripts` object, and add `"start": "webpack-dev-server --progress --colors"` to it.  It should look something like this when you're done.

```json
"scripts": {
  "start": "webpack-dev-server --progress --colors",
  "test": "echo \"Error: no test specified\" && exit 1"
}
```

So if you've installed it globally, run `webpack-dev-server --progress --colors`, otherwise simply run `npm start`.  This will start the dev server, compiling everything and launching the server at `http://localhost:8080`, where once you navigate to in your browser, you should see "Hello!" displayed correctly.

### Go Have Fun!

Now you have the barebones setup to start working with React and Babel via Webpack, so have fun and experiment.  Hopefully my morning of digging and trial-and-error can help you nail this on the first try.
