---
title: "I tried automating Adobe Premiere with Claude Code. The era where video editors can create their own custom plugins｜小渕｜Adobe Premiereの専門家｜動画編集STEP UP代表"
source: "https://note.com/happy_pika6857/n/n7c211a4b6d67?hl=en"
author:
  - "[[小渕｜Adobe Premiereの専門家｜動画編集STEP UP代表]]"
published: 2026-08-22
created: 2026-09-15
description: "Recently, I have been using Claude Code to create various tools to streamline video editing in Adobe Premiere.Since I am not an engineer myself, honestly, at first I thought, “There is no way I can make an Adobe Premiere plugin myself.” But after actually trying out Claude Code and building a fe"
tags:
  - "clippings"
---
### SYSTEM NOTICE

Auto translation by AI. Be sure, accuracy, nuances and authorial intent may not be fully reflected.Recently, I have been using Claude Code to create various tools to streamline video editing in Adobe Premiere.

Since I am not an engineer myself, honestly, at first I thought, **“There is no way I can make an Adobe Premiere plugin myself.”**

But after actually trying out Claude Code and building a few things, I found that I could do more than I expected.

Moreover, there is no need to create a universal plugin that can be sold and used by hundreds or thousands of people.

For example, for me, it is enough to just want to "insert frequently used sound effects with a single button," "avoid the hassle of adding the same animation every time," or "have markers placed on potentially unnecessary parts before cutting."

**It is fine to have tools that only I use, which are hyper-specialized for my own video editing workflow.**

I think this is a personally very interesting aspect of using Claude Code.

In this article, I will summarize as clearly as possible, based on my own trial and error, what kind of Adobe Premiere tasks can be streamlined, what kind of instructions to give to Claude Code, how to put the created tools into Premiere, and most importantly, the points where I failed.

This article is not aimed at engineers, but rather at **people who use Adobe Premiere for video editing on a daily basis.**

---

## Using Claude Code allows you to customize tedious Adobe Premiere tasks for yourself

First, regarding the question of "what exactly are you doing?", to put it very simply, I have Claude Code create extensions for Adobe Premiere, and I use them within Premiere.

If you look at the CEP method I am actually testing, the concept is quite simple.

First, I tell Claude Code "I want this kind of feature" and have it build the tool. I put the completed folder into the Adobe CEP folder. I restart Premiere and open it from "Window > Extensions."

That is the general outline.

Of course, the internals run on code, but I am not writing the code from scratch myself.

What I am doing is the workflow design: "how I want it to move on Premiere," "what I want it to do when I press this button," and "where I want to automate and where I want a human to make the decision."

I convey that to Claude Code and have it write the actual code.

By the way, as of August 2026, Adobe is promoting UXP as the next-generation framework, and CEP is positioned as Classic extensions. Also, UXP Hybrid Plugins have been added in Premiere 26.2, and the trend is moving toward more advanced processing in the future.

However, in this article, I will focus on the CEP method that I have actually experimented with several times.

![画像](https://assets.st-note.com/img/1787220692-lpJCy3xBK70NsmiqY8cI4F5Q.png?width=1200)

---

## Starting off by saying "automate all of video editing" will probably lead to failure

This is a point I found to be quite important after actually trying it out.

When you start using Claude Code, you think, 'I might as well automate the entire video editing process.'

I want it to do the cuts. I want it to add subtitles. I want it to add sound effects. I want it to add animations. I want it to find images. And finally, I want it to check for mistakes.

At first, I also thought that creating an all-in-one tool would be the ultimate solution.

However, as you actually start building it, it becomes incredibly complex.

So, if it were me, I would first break down what I usually do in Premiere.

For example, video editing can be divided into tasks like 'cutting,' 'transcription/subtitles,' 'sound effects,' 'animation,' 'inserting assets,' and 'final check.'

Then, for each one, I think, **Does a human really need to do this manually every time?** and consider it.

This way of thinking is extremely important.

Take cutting, for example.

Video editing takes a lot of time for cutting, doesn't it? However, it's not as simple as just 'deleting all silent parts.'

Long pauses, fillers like 'um' and 'uh,' restatements, parts where the same content is repeated, and obviously unnecessary silence. You can have the system look for these things.

But if it were me, I wouldn't have it delete everything right away.

First, I would have it just place markers saying, 'This part is long,' 'There is a filler here,' or 'You are restating yourself here.'

After that, the editor checks it and cuts only what is truly unnecessary.

I believe this is easier to use in practical work.

The reason is that deleting every 'um' doesn't necessarily make for a good video. Some videos need a 0.5-second pause, and in interviews that convey emotion, there are cases where it is better to intentionally leave the pauses in.

In short, **cutting may look like a simple task, but it actually involves a lot of human editorial judgment.**

Therefore, instead of leaving everything to AI, 'just reducing the time spent looking for unnecessary parts' is enough to save a significant amount of time.

![画像](https://assets.st-note.com/img/1787220958-FSBxthM7aR2GU4IzfgT5pnmC.png?width=1200)

---

The same goes for transcription and subtitles.

If you just want to transcribe audio, Premiere has built-in features, and there are convenient services like Vrew.

Therefore, there is no need to go out of your way to build everything from scratch that is already covered by convenient tools.

If I were to build something, it would be beyond that.

For example, fixing 'proper nouns that are always misidentified'—like company names, service names, performer names, and industry jargon—using a custom dictionary.

Furthermore, you could determine the number of characters to display at once, split text at logical breaks, and adjust line breaks.

For instance, instead of displaying a transcription like 'Today, um, regarding video editing, I'd like to, you know, talk a little bit about it' exactly as is, you could clean it up to something like 'Today, I'd like to talk about video editing.'

Once you reach this point, it's no longer just a transcription; it becomes **a transcription that can be used directly in your video editing.**

This difference is quite significant.

Sound effects (SE) are also very compatible with automation.

For example, if the sound effects we frequently use in our video editing are limited to 'emphasis,' 'confirmation,' 'pop,' 'question,' and 'caution,' we can just turn each of them into a button.

Align the playhead, press \[Emphasis\], and it will load the SE you always use, place it on the designated audio track, and adjust it to the specified volume.

That's all there is to it.

Until now, you had to open a folder, search for the SE, drag it into Premiere, align it, and adjust the volume. You do this dozens of times for a single video.

Even if each instance only takes a few seconds, it adds up to a significant amount of time when you make dozens of videos every month.

These **tasks that don't require thinking but still require manual effort every time** are truly well-suited for automation.

However, even here, the question arises: 'Is it really necessary to have AI decide which SE to use?'

An editor watching the video can decide 'this is an emphasis SE' in about 0.5 seconds.

In that case, the human should just press the \[Emphasis\] button.

The human makes the judgment in 0.5 seconds. The system handles the 20 seconds of work that follows.

I believe this kind of division is the most realistic approach.

**Let humans do what humans are fast at, and let machines do what machines are fast at.**

You don't have to make everything AI.

---

## Animations and asset insertion can also be done in one click if they are 'routine tasks'.

Animations are the same.

When editing videos, it might look like you are doing completely different effects for each project, but in reality, you are using the same movements quite often.

Making a caption pop a little. Zooming in slightly. Sliding from the left. Bouncing. Fading.

Of course, you can do this with Premiere presets.

However, if it's something you use every day, it would be nice to have buttons like \[POP\], \[ZOOM\], \[SLIDE\], and \[BOUNCE\] on your own custom panel, so you can apply them to selected captions with a single click.

Especially for video production companies, the tone and manner are often quite fixed for each company.

If 'this movement for this project' or 'this animation for this caption' is decided to some extent, there is no need for a human to search through effects every time.

This can also be turned into a system.

Inserting images and video assets also takes up time in a subtle way.

Opening Finder, searching for folders, finding images, returning to Premiere, importing, placing them on the timeline, and adjusting the position.

You don't really notice these small back-and-forth movements while editing, but they add up to a significant amount of time.

In that case, you could register the logos and image assets you always use in your own panel, and have them imported into Premiere and placed on designated tracks like V2 or V3 with a click.

If it were a tool for sale, you would have to support various environments, but if it's for your own use, you can hardcode rules like 'images on V2', 'logos on V3', 'SE in this folder', and 'this rule for this project'.

In fact, I believe that **abandoning versatility is the greatest strength of custom plugins**.

![画像](https://assets.st-note.com/img/1787221129-rRP93IWK2b78gMJa016qYLHO.png?width=1200)

---

And the 'final check' after the video is completed is also interesting.

For example, is the volume okay? Are there any unnecessary gaps left? Are the necessary assets included? Is a specific title included? Is the SE volume according to the rules? Is there any strange material left on another track?

Is it really necessary for a human to visually check all of these things every single time?

Of course, it is difficult to leave tasks like "is this video interesting," "is the pacing good," or "does it resonate with the viewer" to a system.

However, things that can be checked mechanically should be left to the system.

Humans should focus on direction, pacing, visual clarity, and ease of understanding.

The system should look for rule violations.

I believe that by dividing tasks this way, we can not only save time but also reduce quality variations between editors.

---

## However, the biggest thing I felt after building this far is that "if you can't edit videos, you can't build good automation tools either."

This might be the most important point I want to convey in this article.

Claude Code will write the code for you.

But, **you still have to define for yourself what constitutes good video editing.**

For example, even if you ask it to "automatically cut long pauses," you have to decide what counts as a long pause in the first place.

Is it 0.2 seconds, 0.5 seconds, or 1 second?

It depends on the video, doesn't it?

Should you delete all the "ums" and "ahs"? How do you determine what counts as a restatement? How many frames should you leave before and after a cut? How do you connect them so it doesn't look unnatural?

This is not knowledge of code, but knowledge of video editing.

The same goes for subtitles.

How many characters are easy to read? Should it be one line or two? Where should you insert line breaks? How many seconds should it be displayed to be readable? Which words should be emphasized?

As for animation, if you say "make it move coolly," Claude Code will create something.

But the movement might be too fast. It might be too flashy. It might not fit the tone and manner of the project. It might move too much every time, making it harder for information to sink in.

In the end, **being able to build something and being able to use it in practice are completely different things.**

I don't think video editing skills will become unnecessary because of AI; I actually think the opposite is true.

When someone who understands video editing learns to use Claude Code, they become incredibly powerful.

As a video editor, you have your own standards: "I don't need this pause," "Keep this filler word," "Cut the caption here," "This amount of text is easy to read," "This is the right volume for sound effects," or "This movement fits this effect."

Until now, you had to manually recreate those standards every single time.

But now, **you can start incorporating those very standards into a system.**

I believe this is a massive shift.

![画像](https://assets.st-note.com/img/1787221333-FGs4UaT7E5OHurB6NPmMKpWh.png?width=1200)

---

## Trying to build an "all-in-one ultimate tool" usually makes it harder to use

This is something I actually tried and failed at.

It can do cuts. It can do transcription. It can add sound effects. It can do animations. It can insert images. It can even do the final check.

When it gets to that point, you want to pack everything into a single panel.

At first, you think, "An all-in-one Premiere efficiency tool is incredibly convenient," but in reality, it just kept getting harder to use.

The reason is simple: the complexity of the processing required for each function is completely different.

Sound effects are quite simple.

Animations are also relatively easy to standardize.

But cutting involves many judgment calls.

Captions also have fine details like text length and timing.

Once you start including image selection, that requires a completely different logic.

When you try to improve everything at once, things like "fixing the sound effects broke the cuts" or "touching the cuts messed up the UI" start to happen.

And in the end, everything is just 70% effective.

Because of that, I think **a plugin that performs one function at 95% is infinitely more valuable than a plugin where 10 functions perform at 70%.**

Start by building just a CUT ASSIST.

Try using it on an actual project.

Fix the subtle issues.

Use it again.

Once it's truly usable, I'll build a TRANSCRIPT ASSIST next.

Then sound effects after that.

Building it one by one like this is overwhelmingly better.

![画像](https://assets.st-note.com/img/1787221436-imuoWOtc0zKyD9Zv8FSVPCHh.png?width=1200)

---

## So, how do you actually build it with Claude Code?

From here on, I'll explain it quite simply using the CEP method I've actually been using.

First, for example, create a folder called "Cut-Assist" and open it in Claude Code.

With the CEP method, the general structure involves having a manifest.xml inside a CSXS folder, along with HTML, CSS, JavaScript, and ExtendScript for handling Adobe-side processes.

But you don't need to memorize all of this if you're not an engineer.

You just need to tell Claude Code something like,

> I want to create a CEP extension for Adobe Premiere. The goal this time is to 'detect candidates for silence, fillers, and restatements, and make them easy to check in Premiere.' Do not add other features like sound effects, subtitles, or animations. First, without implementing anything, please organize the necessary processes, required files, the processing needed on the Premiere side, and where to automate versus where to leave it for human verification.

is enough.

I don't think it's a good idea to have it write code right away.

Have it design it first.

Claude Code also has a Plan Mode, so before making major changes, have it think only about 'how to build it' first.

Then, proceed with the implementation based on that.

Furthermore, I would also create a "CLAUDE.md" file within the project.

In here,

> This project is a CEP extension for Adobe Premiere. One plugin, one purpose. Do not add features that were not requested. Do not change processes that are working correctly without permission. Present an implementation plan before making major changes. Do not create non-existent processes based on guesswork. Identify the cause of errors before fixing them. Prioritize actual usability in my own video editing over general-purpose functionality.

I will write down some rules like this.

It is quite convenient because I no longer have to explain the same thing every time.

Then, place the completed folder into the CEP/extensions folder that Premiere can read.

On a Mac, in the user environment, it is:

~/Library/Application Support/Adobe/CEP/extensions/

On Windows, it is:

C:\\Users\\\<USERNAME>\\AppData\\Roaming\\Adobe\\CEP\\extensions

There is a location like this.

Place the plugin folder you created there, restart Premiere, and open it from 'Window > Extensions'.

The image is:

**Claude Code → Custom Plugin → Adobe CEP/extensions → Adobe Premiere**

is how it works.

It is not that Claude Code and Premiere are magically connected directly; it is more like you are placing what you made with Claude Code in a location that Premiere can read.

![画像](https://assets.st-note.com/img/1787221627-zEhrCb7Z6XPsMm1HyYfdFD9L.png?width=1200)

---

This might sound difficult when you hear it, but in reality, when the panel you made yourself appears normally next to Premiere for the first time, it is quite moving.

However, it is also normal for it not to work on the first try.

It doesn't appear in the Premiere extensions list. The panel appears, but the buttons don't work. The buttons can be pressed, but Premiere doesn't react. The file is imported, but the position is off.

Things like this happen all the time.

What is important at that time is **not to just throw 'It doesn't work, fix it' at Claude Code.**

For example,

> Currently, the panel display, UI display, and button operations for Premiere are working correctly. Please do not change these. Only the cut processing on the Premiere side is not being executed. This time, please investigate only the cause of that and make the minimum necessary corrections.

I tell it this.

Even just doing this makes a huge difference.

If you let Claude Code touch everything without telling it 'this part is working so far,' you might end up breaking parts that were working just yesterday.

And one more thing.

**Save the moment it works.**

This is really important.

If the marker display for cut candidates works, save it at that moment.

If you understand Git, you can commit it, and if you don't, you can just copy the folder and name it something like 'Cut-Assist-v1-working'.

When developing with AI, it is common for things that were working yesterday to break when you add the next feature.

That is why you must always create a point where you can return to.

People who are not engineers, like me, should definitely do this.

---

## If you are a production company, I think you can even go as far as creating a 'company-exclusive Adobe Premiere'.

I think this mechanism is quite interesting not only for individual video editors but also for production companies.

For example, in our case, we have specific tone and manner requirements for each project.

'Sound effects at this volume,' 'this caption at this position,' 'titles follow this rule,' 'use this animation for this project,' 'check this before delivery.'

Until now, it was necessary to write these in a manual and have each editor memorize them.

Of course, training is necessary.

But if you can shift some of it to the system side, you can create a Premiere environment where mistakes are less likely to occur in the first place.

If you press 'Emphasis SE,' it will always be at the set volume.

When you press "Logo," it is always placed on the designated track and at the specified size.

If you press "CHECK" before delivery, a list of only the errors that can be mechanically determined will appear.

When this happens, it's not just about simple time-saving.

**It can reduce quality variations among editors.**

As a production company, I think this is actually of greater value.

---

## Ultimately, what will become important from now on is not just "people who can operate Premiere quickly."

In the past, if you wanted to speed up video editing, you would memorize shortcuts, create presets, buy a better PC, and get used to Premiere.

I think this was the standard.

Of course, all of that is still important today.

But with the emergence of things like Claude Code, another way of thinking has been added.

**Instead of making the task of clicking 100 times faster, create a system where you don't have to click 100 times at all.**

It's not just about practicing to do a 30-second task in 20 seconds, but thinking, "Can't this be done in one click?"

Since I started using Claude Code, this mindset has increased significantly.

I cannot write code.

But I understand video editing.

I also use Premiere on a daily basis.

I know where editors spend their time, and I know where they are prone to making mistakes.

I am more knowledgeable about that than Claude Code.

Therefore, **a person who knows the business designs it, and Claude Code implements it.**

We have become able to do this.

From now on, I believe that not only those who can operate Adobe Premiere incredibly fast, but also video editors who notice **“Does a human really need to do this task every time?”** and can turn that into a system will become powerful.

---

## Lastly. If you use Premiere, you might want to start by putting this article into Claude Code.

I think there are also people who feel, “It sounds interesting, but I don’t know what I should make for myself.”

For those people, I think it’s fine to put this article directly into Claude Code and ask it something like this at the end.

```
ここまでの内容を前提として、
私専用のAdobe Premiere業務効率化ツールを
一緒に設計してください。

まだコードは書かないでください。

まず私が普段Adobe Premiereで行っている
動画編集業務を詳しくヒアリングしてください。

その後、

・使用頻度
・1回あたり削減できる時間
・月間で削減できる時間
・実装難易度
・期待できる精度
・人間に残した方が良い判断
・既存ツールで代用できるか

という基準で候補を整理してください。

すでにAdobe Premiere標準機能、
Vrew、既存プラグイン、プリセットなどで
十分解決できる場合は、
無理に自作をすすめないでください。

巨大な万能ツールにはしません。

1つの目的に絞って、
実際の動画編集で毎日使える精度まで
完成させることを優先してください。

私はエンジニアではないので、
各工程で「今何をしているのか」も
分かりやすく説明してください。
```

After that, you can just talk about the things you find tedious while editing videos, like  
“Cutting is a hassle,”  
“Fixing subtitle line breaks every time is a pain,”  
“I want to eliminate the task of searching for and inserting sound effects,”  
“I want to make my usual animations one-click,”  
“I want to reduce the back-and-forth of importing image assets into Premiere,”  
“I want to make pre-delivery checks easier,”  
and so on.

The tools that should be built vary completely from person to person.

That is exactly why there is meaning in building them yourself.

However, there is one thing I think you should keep in mind: **just using Claude Code doesn't mean you can do everything without video editing skills.**

You have your own standards for “what makes a good cut,” “what makes readable subtitles,” and “what kind of direction fits this video.”

You pass those standards to Claude Code.

And you gradually turn the editing techniques you used to reproduce by hand every time into a system.

I believe this is the most powerful way to use it.

And, don't try to build everything from the start.

**Better to have one thing at 95 points than ten things at 70 points.**

First, complete one thing.

Use it in actual video editing.

Fix the subtle issues.

Use it again.

Once it becomes truly usable, build the next one.

In the past, if Adobe Premiere didn't have a feature you wanted, you had no choice but to look for a commercial plugin or wait for someone else to make it.

But now, **“For my video editing, I only need this specific feature”** —things like that are becoming possible for us to build ourselves.

It’s not just about using Adobe Premiere, but **tailoring Premiere itself to fit your own workflow.**

We have entered an era where even those of us who aren't engineers can do things like that.

I am still in the middle of experimenting with various things myself, so if I manage to bring anything to a level where it can be used in actual projects—such as cut assistance, subtitles, sound effects, or animations—I will share the details again!

6