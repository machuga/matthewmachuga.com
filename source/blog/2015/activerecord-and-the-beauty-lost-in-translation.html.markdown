---
title: "ActiveRecord and the Beauty Lost in Translation"
date: 2015-09-12 14:32 UTC
tags: activerecord, ruby, php, orm, testing
---

## The Endless Fight

Sometime in 2014, PHP-land started to debate whether Active Record was a tolerable ORM pattern, and whether one should use Active Record or Data Mapper ORMs.  In PHP, this comes down to something like Laravel's Eloquent ORM as an Active Record implementation vs. Doctrine, the reigning mainstream (and probably only) PHP data mapper implementation.  After a surge of interest in Domain-Driven Design (DDD) and Hexagonal Architecture in the Laravel, and overall PHP communities, people began to detest one of the very things that drew them to the framework in the first place.  This was fueled by a number of vocal and notable Laravel community members learning Doctine, talking about it heavily, and some evangelizing it.  With outside influence from the PHP world providing the same judgement against the impure Active Record pattern, the pitchforks started to come out from all over.

The long and short of the argument is that the Active Record pattern is found by some to be inferior to the Data Mapper pattern.  Why?

### Entity / Repository Separation

Active Record models know not only how to represent a row in a database, but also how to query and persist itself and other objects to the database. DDD, hexagonal architecture, and  most general OOD practices tell object-oriented developers that their objects should do *one thing*.  Even though this rule can be easily overlooked in many cases, AR models know how to do a whole slew of things.  Depending on the AR implementation, this number of responsibilities an object may have can grow even larger.  This level of responsibility blending commonly makes things:

- Harder to change
- Harder to isolate bugs
- Harder to test
- Harder to refactor

Along with the mixing of concerns, AR models are explicitly aware of their database representations.  The table fields are typically publicly exposed as properties or magic properties on the object.  This can be disruptive to someone attempting to create a minimal entity with a very explicit interface that isn't one-to-one with the database.  This is analogous to creating an API over HTTP; sometimes you don't mind consumers knowing the schema of your database tables, but most often you'd like to give them access to that information in a more consumable, or more encapsulated way.  When you have very complex business logic in your domain, you may find Data Mapper providing a bit of an easier means to working with your data at the trade off of typically needing some extra work and boilerplate.

### Testing is Meh

Some of the hate on this level is largely just regurgitation of hearing others say it, but if you have tried testing AR objects from any implementation you are well aware it is not the most pleasant of experiences.  If you're doing integration or end-to-end level testing where you are interacting with the database already, then it's fairly painless to test if you avoid mocking.  However if you are unit testing your models, attempting to check some behavior you've placed on the entity, you may be in for some hurt if in anyway calls a method or property that relies on the database.  Frameworks like Rails and Laravel provide means for making unit testing models a bit easier, and honestly as long as you can stub out the model's database connection it's not terrible to test.  However, this must usually be done on each individual object so it is not the most pleasant of experiences.  It also makes integration testing objects that have AR models as collaborators a bit more challenging since you'll have to mock out the DB access before you pass it into the collaborator, which isn't ideal.

Compare this with the way that a Data Mapper's entities may be tested, they're usually just plain objects of whatever language is being used and don't need things mocked because the entities have no knowledge of the database.  An entity would be fetched from a repository object, meaning that the concerns are already separated.  One can then easily test all operations of the entity quite simply without the runaround.

### Community Pressure, Shaming, and Perceived Inferiority

As a developer who is involved in a community, especially a newer developer, it is common to feel a sense of pressure in terms of trends and current "best practices".  If high praise or disdain for a practice or technology comes from more prominant members of a community, it becomes harder to ignore.  The voices then propagate from the top-down in a tree-like fashion, adding volume as it goes.  By the time it reaches new developers, it's nearly unavoidable and impossible to ignore.  However, part of the message is usually lost in translation somewhere along the way - the *when* and *why* something should be used.  Sometimes this reasoning is amplified because it's natural for us as developers to get excited to use a new concept or technology.  Somewhere along the way, though, we lose the reasoning by the time it reaches the next level in the tree.  This can often lead to the developers feeling like the *must* use something like Data Mapper in all situations if they are told it is far better than ActiveRecord.

This will then lead to pressure and even shaming from community members to one another if one chooses to use ActiveRecord.  At this point, there is now a perceived inferiority of not only ActiveRecord, but also the developers who use to use it. By this point it should be obvious where the game "Telephone" originated, and why it is so silly.  Things lost in translation or modified over time somehow become grounds for judgement.  We're all guilty of it at some point, and probably far more often than we believe.

## The Reality of Active Record

The points mentioned above have merit.  Testing ActiveRecord objects, or collaborators of said object, can be challenging.  Mixing concerns between persistance and domain logic can also make things muddier and harder to follow.  This can also make debugging code using AR models more challenging since the database may contacted at any time unintentionally.  However, do these cons always outweigh the benefits?  In my opinion, *no*.

Admitting my contributions to this, on an episode of [The Laravel Podcast](https://itunes.apple.com/us/podcast/episode-14-dhh-domain-events/id653204183?i=328486884&mt=2) I was quoted saying something along the lines of "I just don't like it anymore" when asked my thoughts on ActiveRecord.  Even today, this remains true.  **However**, I still use ActiveRecord implementations **every** **single** **day** and am quite content.  I still like it better than other options available at this point.  In the Rails world, ActiveRecord is still the de facto ORM, especially if you want to develop fast.  It does everything we need for the most part, and for the areas it doesn't we can drop down a level and optimize while still being within ActiveRecord.  It is *good enough*.

### It's Easy

Getting many things done in an ActiveRecord implementation is wildly fast and easy, especially if the implementation has added some excellent features to help it along.  It's so easy to just call `save()` on the object I'm working with and know that it'll be persisted if all went well.  It's convenient to be able to do something like `user.blog_posts << Blog.new(attrs)` to add a new associated blog post, knowing that foreign keys at the database level will be handled for me automatically.  In the event I need some sort of advanced query and do not want to fight the query builder directly, I can use `User.find_by_sql` and pass in my hand-rolled SQL query.

### Domain Modeling is Still Entirely Possible

Nothing is explicitly halting you from modeling your domain effectively with ActiveRecord models.  Sure, you'll have some unrelated methods available on the objects themselves, but you can choose as a developer or as a team to not use them in certain contexts.  It takes more discipline for sure, but you can avoid exposing fetching or persisting logic outside of the model itself.  You can still create service classes to handle complex domain logic that use these methods as needed to model additional concepts.  The idea that you *can't* model your domain properly with ActiveRecord is a myth, but it might indeed take a bit of extra effort.

### ActiveRecord Can Scale

At my day job we have a large Rails codebase that serves millions of users with some quite complex domain logic, and I'm going to let you in on a secret - we use ActiveRecord!  Sure, there are situations where we'd like cleaner entities or repositories, but in general we can usually just refactor some code or extract a new service object and still get a great result.  Even our data warehouse uses ActiveRecord with a number of custom queries.  It's wild how helpful it can be.  We don't need to worry about complex object hydration anywhere, we can quickly avoid N+1 issues, and most of our day-to-day operations are streamlined by the ActiveRecord internals.  We can pass `DateTime` objects to queries and they'll be cast properly for us.  We can fetch related data quickly from relations, even nested relations.  We send a huge amount of business logic and traffic through our codebase without any crazy speed loss that you may have heard of when using ActiveRecord ORMs.  As long as you use some good practices and are dilligent as a developer, it is certainly possible to happily and successfully use ActiveRecord.

## Be Critical

The next time you come across the ActiveRecord vs. Data Mapper argument, or ones like it, be critical of what is being said. If it impacts your work in some way, do some research to find out if what is being said is true or if it has been something lost in translation.  Don't feel bad for using a pattern that has spread across multiple languages and ecosystems successfully, and is probably the reason we have most of the web frameworks we do today.  While the ActiveRecord existed well before Rails, it was Rails that gave it a beautiful API and made other frameworks like CodeIgniter, Laravel, .NET, Fuel, Django, etc want to have something comparable.

If you use Eloquent, ActiveRecord for Rails, or any other AR ORM, make sure you know that you are not alone.  You are in good company of many, many developers who use it successfully day-to-day.  However, if one day you choose to use a Data Mapper implementation or something else, then you will still be in good company, and still deserve respect regardless of which side of the fence you fall.

Let's all be friends.
