---
title: Light Table Part 2: A Retrospective
date: 2014-06-16
tags: editors, light table, foss editors
---

###### Start from [Part 1: An Introduction](/light-table-part-1-an-introduction/)

## First Impressions

Light table seems interesting upon first opening. It greets you with a brief splash-screen style intro before loading the "Welcome" tab which will give you some basic information on where to find the changelog, documentation, and the project on GitHub.  It is apparent right off the bat that the UI is custom (HTML and CSS), but in general it can be used *almost* like an app native to the OS.

One thing that I found was a bit odd was that Light Table takes the standard `Cmd-o` keybinding and maps that to its fuzzy-finder open-file menu, which is similar to `Cmd-t` in TextMate or `Cmd-p` in Sublime Text.  Typically Apple applications would use the native OS X file-finder with this keybinding, but rather `Cmd-Shift-o` will toggle it.  This isn't a problem or anything, just a bit unexpected. It realistically probably makes more sense to keep the fuzzy-finder to less keystrokes, but I think the TextMate or Sublime Text bindings probably make more sense here.
{<1>}![](/content/images/2014/Jun/fuzzyfile.png)

Workspaces are effectively Light Table's form of managing different projects in the environment.  You can search across multiple workspaces, but keep things organized under different top level directories.  This is also Light Table's version of a file tree, and while it performs largely the same as other file browsers it does offer the added benefit (or sometimes hinderance) that fuzzy-matching on opening files will cross multiple workspaces as added, and many workspaces may be visible at any given time.
{<2>}![](/content/images/2014/Jun/workspaces.png)

The next point of interest, and probably the primary point of access in Light Table, is the Command Bar.  It's quite similar to `Cmd-Shift-p` in Sublime Text.  This will be how you find or access most everything other than the files you want to edit, including key mappings, editor behaviors, plugin actions, etc.  It's quite handy and also supports fuzzy matching like its file-searching partner.
{<3>}![](/content/images/2014/Jun/command-bar.png)

### Tweaking Keymaps

The Command Bar is mapped to `Ctrl-Space` by default.  Since I have Alfred mapped to that binding across the OS, I wanted to remap this immediately so I don't have to click menu options every time I need to access it (which is a lot).  So I open up the Command Bar by clicking on the menu and type in `uk` which brings up the `User Keymap` as the first result, and press enter to open it.  When editing your keymappings, it may be beneficial to open up the default keymap in a new tabset (a pane in the Light Table window with its own tabs) so that you may look at both files side by side to ensure you place things in the right locations for proper overriding.
{<4>}![](/content/images/2014/Jun/keymap.png)

With both keymaps side by side I can see that I need to add a new entry to the `app` map, adding my preferred keybinding of `alt-space` to the keyword `:show-commandbar-transient`.  As soon as the cursor enters the vector area (`[]`), we start seeing options for autocompletion since Light Table is able to analyze and present options for items in its running environment that it knows about.
{<5>}![](/content/images/2014/Jun/keymap-completion.png)

After a few keystrokes I found the option I needed and complete it.  After completion I now see an explanation of what my keymap does to the right, courtesy of Light Table and Clojure/ClojureScripts inline documentation in function declarations.  This is quite an awesome feature if you're in either of these languages.
{<6>}![](/content/images/2014/Jun/keymap-info.png)

Upon saving the keymap will be evaluated into Light Table, so if we click the `View` menu in the menubar we can now see that `Commands` has our new keybinding added.
{<7>}![](/content/images/2014/Jun/keymap-change.png)

That was pretty simple!  I mapped a few other things you can see in the screenshot or in my [dotfiles](https://github.com/machuga/dotfiles).


###  Installing Plugins
With my fresh new keymapping for opening the Command Bar, I can select `Show Plugin Manager` and open up a list of my Installed and other Available plugins.
As you can imagine, the first thing I want to install is the `Vim` plugin so I can get my Vim keybindings in place. When I hover over plugins I get the option to install them or view the source of the plugin on GitHub.  I figured I could check out the source later so selected `Install` and waited for it to complete.

{<8>}![](/content/images/2014/Jun/plugin-manager.png)

Since Light Table will automatically start up new plugins I was somewhat surprised to discover that I didn't have any Vim bindings ready yet.  After reloading to be sure, I headed back into the plugin manager and clicked on `Source` to see if there was any information.

Just below the introduction is a `Setup` [header](https://github.com/LightTable/Vim), which indicated to me that the plugins loaded into Light Table don't really have any setup scripts or instructions in the Plugin Manager UI itself.  To figure out if there are extra steps needed to install a plugin, you need to check out the project readme and hope the developer has documented everything.  This isn't the end of the world, but somewhat frustrating that I have to leave the UI to figure these things out.

Setting up the Vim plugin is incredibly easy though, only requiring copying and pasting a single line into the `:editor` key of my user behaviors file.
So from the Command Bar I loaded my User Behaviors file and pasted the line into the `:editor` vector.  Upon save, viola; Vim bindings are active!  We also get to see a nice description that this line belongs to the Vim plugin and activates Vim.
{<9>}![](/content/images/2014/Jun/activate-vim.png)

Some of the other helpful plugins I've installed include:

* `Workspace Nav` which simply allows me to navigate the workspace file browser with keystrokes (and as a bonus with Vim bindings with the Vim plugin installed!).
* `Trailing Whitespace` to stop me from accidentally saving additional whitespace to lines in files.
* `Syntax Status Bar` to let me know what syntax highlighting is currently active
* `Rainbow` for uniquely identifying pairs of parenthesis in ClojureScript code
* `match-highlighter` to highlight closing parens, brackets, strings, etc to ensure I don't forget them
* `Markdown` which is a great way to write markdown files, watch them, and render them live in another tab as a preview
* `Git Status Bar` to show my current git branch and status in the status bar
* `Ctags` for ctag navigation

#####Markdown Plugin
{<10>}![](/content/images/2014/Jun/markdown-plugin.png)

There are a good amount of plugins with a varying degree of functionality in the manager, ranging from extremely simple highlighting to new Instarepls for Ruby or other languages.  It's also possible to install new themes via the plugin manager, such as the `base-16` themes. There isn't a huge selection in the plugin manager and it's not immediately available how to find more, but the community is growing so I'm hoping to see a better manager UI and experience come along in the future.  Discoverability of good plugins is kind of challenging as-is, so there is definitely room for improvement.

### Behavior Tweaks
I changed up a few additional things in my user behaviors to get the environment more to my liking.  I wanted to display line numbers but wasn't entirely sure how to go about doing it.  Since I knew Light Table was doing some completion techniques in the keymaps file I decided to see if something similar would take effect in the user behaviors.

So I clicked inside of the `:editor` vector and typed `linenum` and got a two pretty specific completion options to either hide or show line numbers.
{<11>}![](/content/images/2014/Jun/linenum-completion.png)

I selected the show option, pressed enter, and the text expanded into the correct keyword, `:lt.objs.editor/line-numbers`.
{<12>}![](/content/images/2014/Jun/linenum-info.png)

Next I wanted to change my font to use `Inconsolata-g`, so typed `font` as a new entry in the vector, pressed enter when it gave me the option to set the font of the editor, and then I was presented with a slightly different display than I was used to.
{<13>}![](/content/images/2014/Jun/font-settings.png)

While this doesn't seem entirely obvious, the screenshot of the display is telling us the order of the arguments.  As such, the font family is the first argument, font size is the second, and line height is the third.  This is form of inline documentation is wildly helpful, so I entered my values, saved, and the editor updated itself and was ready to go. I saw this as Light Table pulling some influence from Emacs and Elisp, but putting a better interface on a similar technique.

## Usage

### Overall Feeling

In general, unless you are using Clojure, ClojureScript/JavaScript, or Python, Light Table will largely perform like any other general purpose editor.  It has all the essential functionality to get your work done.  I primarily used CoffeeScript and Ruby throughout my time with Light Table, so I don't really think I got to take full advatange of the potential gains LT could've provided.  Its ability to highlight CoffeeScript is limited to what CodeMirror's plugin provides, and while there is a CoffeeScript plugin available for Light Table to provide some live coding it has a few additional steps and seems error prone.  Ruby does indeed have an Instarepl available in the plugins section but it requires a fair bit of additional extra work to get it working that I wasn't really willing to dedicate time to complete.

So I'd say overall for CoffeeScript and Ruby the experience is less-than-great, but still passable.  One annoyance I experienced regarding auto-completion in Ruby was that if I came along to do a `do...end` block, if I pressed enter at the end of typing `do` it would just count that as trying to complete the word, not drop me to the next line.  I think I've seen Sublime Text experience a similar issue while pairing with coworkers, so I don't think this issue is only a Light Table one, but it's still an annoyance nonetheless.

I also thing changing the default theme to one of the base16 or alternative themes would be something I'd recommend to make things easier to see (setting the theme in user behaviors also supports tab completion for available themes for your convenience).  I found the default theme challenging for things like finding my cursor or distinguishing certain tokens in the code if I was in less-than-optimal lighting.

### Speed

The speed of Light Table was where I found a fair bit of frustration. When you have only a file or two open without a heavy amount of syntax highlighting to do I think that LT runs fairly quickly overall, but I couldn't help but notice a sort of lag as I typed or performed screen-jumping actions sometimes.  This was primarily noticeable if I had more than a few files open or if the editor was open for a long duration.  I'll caveat that with the fact that my long-time usage of Vim has given me a very low tolerance for lag or delays of any sort.  If Vim gets sluggish at all I get disgruntled, so I'm quite in-tune to looking for such things. With that being said, I've had a few Sublime users tell me of similar frustrations with Light Table and Atom (both node-webkit powered projects), so I am inclined to believe this a general issue.

I also started noticing actions like saving start to hang for a while. This was mostly noticeable if I used `:w` with the Vim bindings because it will open the command bar action as it operates.  It would sometimes freeze there for up to a second before writing to disk and closing the command bar. I'm not terribly familiar with the node-webkit process, but I believe the whole GUI locks up here due to the main thread being locked and that the JS is still running in single-thread mode as per usual.  I don't know how different workers could benefit this, or if something in LT could be tweaked in a non-blocking way, but there are a few other things like this in the editor that I don't think I'm too qualified to speculate much further on.

Ultimately the editor is quickish start off with but really seems to get bogged after a little bit.  Hopefully this is something that can be corrected in later releases.

### Stability

From the best I can tell Light Table is pretty darn stable.  I didn't have it fall over on me even once, though I was able to hang its process as mentioned in my last post by running a `debugger` statement in JS on the internal browser. This is due to the entire Chromium runtime being locked up according to an issue on GitHub I noticed.  While Light Table never actually crashed I did have certain plugins, instarepls, or watchers seemingly give out in some strange way and never recover.  I wholly admit that this could have been something silly I did, but it was frustrated when I was trying to experiment with them.  Also noticeable are the number of errors that LT or plugins can manage to throw in the app - none of them seem to effect the LT process.  In short, I give a big thumbs up on its stability.

### User Experience

Another weird thing I experienced was loading of keymaps or behaviors being disrupted by a typo, but no discernable error message was given.  The only way I could tell something had gone wrong was that my vim bindings had stopped working.  I went through a heck of a debugging process to track down that cause, thinking it was a failing plugin at first.  Finally I searched around and found an issue on github indicating that it may be an issue in the behaviors/keymap.  I deleted a lot of code, noticed my missing `]`, saved, and magically everything worked again.

Unfortunately, the UI/UX of Light Table is pretty lacking overall.  It looks great, but most things are not very obvious.  When I said before that the command bar would be the primary access point, I meant that very literally.  Most menus in LT only have the most basic of options, everything else must be discovered via the command bar (or keymaps and user experience file autocompletions).  While a mediocre UX isn't the end of the world (hell, Vim isn't very obvious, but it does come with `vimtutor` and decent manpages), things could certainly stand to be a lot better.  A great example I will cover more next iteration is how Emacs encourages discoverability.  If you enter a command the long way, Emacs will give you a friendly notice that you can also do the same action via a simple keychord.  Since LT is guaranteed to be run via a GUI I think they could do a lot more to increase and improve the overall experience.

Now this isn't to say that LT doesn't care about the developer experience.  Quite the contrary, Chris Granger actually strives to improve the way developers write applications in generally.  That's why Light Table ships with watchers, instarepls, etc.  He's trying to give you excellent ways to vibe with your code, but the current issue that stands is we still want our editors to be very discoverable as applications themselves.  Sometimes it's harder to get up and running without that focus in place, but not everything will get top focus right out of the gate.

### Vim Emulation

This is an area that will openly admit will be horrendously critical and biased in every editor review.  I am insanely picky about Vim emulation.  If an editor offers a Vim or Vi emulation, I expect it to work with all of the things I use on a daily basis.  I am not saying I expect a full Vim to be available, but all of the primary key bindings and most traditional commands should be in place.  In short, I'm very reluctant to give up my muscle memory and concepts I no longer think about.

As for Light Table, its Vim mode is really only going to be as good as CodeMirror's plugin, which is to say not very good.  It has a few odd behaviors which irk me enough to be fairly disgruntled.  For example, if you happen to be in normal mode and highlight some code to start a LT watcher, it doesn't seem to select the last character under your cursor due to the way it emulates Vim cursor position.  This also happens if you try to copy text via mouse or `Cmd-c` in normal mode.  Another example is that visual line mode isn't active for some reason, even after Light Table updated part way through my review and added multi-cursor support a la Sublime.  As a less important, but still annoying issue, the plugin doesn't seem to give me an easy way to make mode-specific keybindings which is a shame (like `map`, `vmap` in Vim).  After my review wrapped up a [new version](https://github.com/LightTable/Vim/commit/76ea3b56b1d1f04e7021cc5a64666c718b0fa4c2) of the plugin came out which looked like it may addressed some of my concerns like visual line mode, key mapping per modes, etc, but it seems like the plugin does not yet support everything added to the CodeMirror plugin.  It did seem to correct my issues with being able to select blocks of code to the bottom of a file with `G`, which I was having issues with last release.

So while the plugin definitely helped me adopt Light Table faster and help me work at nearly my normal pace, it came with enough oddities that I'm not entirely sure I'd stick with it without heavily modifying it myself in the long run.  It's certainly doable, the rough edges are just kind of annoying.

### Areas for Improvement

I have high expectations from editors. I want them to allow me to modify my text in a performant manner and provide me effective mechanisms to do so while also preventing them from getting in my way.  It's not an easy task, but something I expect nonetheless.  For CoffeeScript and Ruby code, at least, I don't think Light Table is the right fit.  I'm not sure that Light Table is quite yet ready to be an all purpose editor due to it's lack of selling features, discoverability, and its heavy reliance for its awesome features to utilize ClojureScript.  JavaScript and Python have pretty high level support but I think ClojureScript and Clojure see the most benefit from the additional functionality provided by Light Table.

I also think some of the awesome features like code watchers, live editors, and instarepls are a little finicky.  As mentioned before it could easily just be doing something wrong, but I had a lot of issues with these features.  Most inline evaluation worked perfectly except for a set of issues I kept having one day where it didn't seem able to follow my changes any longer and kept complaining about things that weren't involved in my code.

The speed of the editor and the UX, as mentioned, could definitely see some improvement.  I don't want to beat on this too much, but they are pretty important areas in my opinion.  I'd really love the plugin manager to be a bit more transparent and allow for instructions to be available in-editor (or even set up as much as they can on their own).  It'd also be great for the search to be improved and for the listing to allow for overall better discoverability - categories, featured plugins, etc.

## Conclusion and Score

I really wanted to like Light Table since I have strong interest in Clojure and ClojureScript, but I hit quite a few annoyances along the way that make it a less-than-great editor for the two languages I used throughout most of my time - Ruby and CoffeeScript.  Some are completely correctable by installing or tweaking plugins/themes, but others are pretty core-level concerns - whether it be Light Table, CodeMirror, or node-webkit.  I believe that if progress keeps being made on it that Light Table could have a lot of interesting things in the future.  However, I have some concerns on its future due to a recent [comment](http://www.reddit.com/r/vim/comments/1ztxgd/why_atom_cant_replace_vim/cfx0kyq) by the author allegedly made on a private mailing list regarding the future of Light Table.  It's not really clear what he has in store for Light Table, but now that it's fully open source it could still stay alive even if he chooses to move onto other projects like [Aurora](https://www.youtube.com/watch?v=L6iUm_Cqx2s).

To someone getting involved with ClojureScript I think this would be the best place to start.  It lets you just start using it right off the bat, even against its own UI, which is pretty awesome.  Maybe even try it out with some regular JS development, or Clojure.

For those who are coming in planning to use other languages - be wary.  When reaching out to other languages that do not receive first class support, you may not see many gains over alternative editors with better internal or plugin support for those languages.
