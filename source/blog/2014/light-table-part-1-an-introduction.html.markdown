---
title: Light Table Part 1: An Introduction
date: 2014-06-08
tags: editors, light table, foss editors
---

# Light Table

My text editor journey began with Light Table.  It's not my first experience with the editor by a long shot, but this was the longest continuous streak I've spent exclusively editing with it (okay, technically I edited git messages in Vim because I forgot to assign `EDITOR` to the command line `light` app to launch the GUI). I've enjoyed a number of things about this editor and the plugins I've picked up, but we'll get to the pros and cons in a bit - let's start with basic information about the editor.

## About Light Table
Light Table was initially developed by Chris Granger in 2012 - receiving over $316K in a Kickstarter program.  While initially rough around the edges and requiring boot from a Java jar file, Light Table is continuously being polished up and has a pretty solid UI.  It uses the node-webkit library as a foundation for the interface/application, and uses CodeMirror as the editor. Light Table is almost entirely written in ClojureScript.  As such, it does a *really* good job of providing an interactive environment for ClojureScript, JavaScript, and Clojure.  Despite being largely popular in, and targeted for, the Clojure community, the only component still written in Clojure is the set of bindings to load up a Clojure REPL.

## Highlights

### Watchers and Connections
Light Table has watchers available in JavaScript, ClojureScript, and Python to track values in real time.  Choose a connection (what runtime you want to evaluate your watches/code), Set a watch, start making changes or run your application and the watchers will update the values as they run.  I personally had an issue with this working reliably in testing, but it was likely something I was doing wrong.

The connections allow you to bind to different runtimes and environments to your REPLs or watches, as previously mentioned.  Some of the defaults include an embedded or external browser, a local or remote Clojure REPL, the Light Table UI itself, Node, or Python.  You can also include additional connections from the plugin manager or write your own for your favorite runtime.

{<1>}![](/content/images/2014/Jun/connections.png)


### Embedded REPLs
Those familiar with Emacs will appreciate the fact of being able to fire up REPLs on the fly.  Light Table's REPLs are typically in Live mode - where you'll get inline evaluation without performing any commands to eval your code.  It's quite a nice way to write your code if you're working on an application in one of the supported languages.

{<2>}![](/content/images/2014/Jun/live-repl-1.png)


### Inline Evaluation
Rather than using console logging or a dedicated debugger, Light Table lets you evaluate a line of code right there in the editor with a simple keychord.  This is great for figuring out where your code is going to throw exceptions or return slightly incorrect values without breaking your focus. As mentioned before - just select the connection you want to eval against and it's good to go.

{<3>}![](/content/images/2014/Jun/inline-eval.png)

### Embeded Webkit Browser
Since Light Table is built on `node-webkit`, it supports the ability to call up a browser right inside of the editor.  This is great for working on a JS/ClojureScript application since you can control nearly every aspect of your code without even leaving your editor.  The biggest caveat I've found with this feature I want to document, which I should've considered prior to attempting, was that if you enter a `debugger` statement in your JavaScript it will hang the entire editor since it will halt the JS runtime.  As such, you'll be forced to force quit Light Table and restart it.

{<4>}![](/content/images/2014/Jun/embedded-webkit.png)

### Completely Flexible
Keybindings are super easy to manipulate for various parts of the editor, and the general behavior and functionality of the editor is just as easy to configure.  Light Table's architecture (and ClojureScript as a language) lend themselves well to creating an extensible and introspectable environment.  Since the functionality is treated as data, it makes reconfiguring or extending the editor or platform quite simple in any language that can compile down to JS.  Of course, you'll almost always need a bit of ClojureScript to hook it into the platform, but much of that can be copypasta'ed from the web.

LT seems to borrow partially from Emacs and partially from Sublime Text as far as keymapping and behavior goes.  Both keymapping and behaviors have `system` and `user` files where all of the configuation belongs, much like Sublime. Similarly, both keymappings and behaviors are using ClojureScript to configure, manly maps - this is similar to how all Emacs scripting is done in Emacs Lisp.
{<5>}![](/content/images/2014/Jun/configs.png)

## Plugins
Light Table's plugin ecosystem is still pretty small but it seems to be growing slowly. Its plugin manage is built into the OS and as such makes management and discoverability fairly easy.  That being said, the flat index listing of all packages and the search are not the greatest ways to find packages in my opinion, but it is better than what some other editors provide out of the box.  Additionally some of the packages have many unseen dependencies or behind-the-scenes gotchas; however, these issues could be made more obvious with some UI tweaks, although complete resolution may be more involved.

One notable thing about the Light Table plugin system is that you also have access to any CodeMirror plugin, so long as there is a small adapter for it to be plugged into LT. Even Vim mode is one of these CodeMirror plugins; they're quite common since reinventing the wheel would be a bit unnecessary, and CodeMirror has quite a few plugins already.

{<6>}![](/content/images/2014/Jun/plugins.png)


## Overall

Light Table is largely capable and seems to contiously get more and more solid. Also, considering it was only open sourced a few months ago, it has made a lot of progress in a short time. If it continues picking up speed I have high hopes of LT becoming a premier choice for Clojure and ClojureScript development.  It has some loose ends to tie up, but I'm looking forward to see what the future has in store for it.

Next post I'll give a review of my experiences with Light Table, both good and bad.
