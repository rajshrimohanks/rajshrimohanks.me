---
date: 2017-05-28T20:58:22.000Z
title: Setting up a slick new blog - 1 - Discovering Hugo
draft: false
---

After months of hiatus, here I am back, writing. Even though, I had a domain name registered and had made various attempts at maintaining a blog, they never were very successful. I realize now, that I had been impatient. And that even though I used to start writing for my joy, my mind was always conscious to try and please others. LIKES seemed important after all. But I've learned.

So before I started again, I wanted to be prepared. I wanted to set up an environment that would give me as less distractions as possible and one would satisfy my inner curiosity for geekiness as well. And I wanted it to be cost effective. Paying a sizeable chunk every month is not in my agenda. I had discovered that it soon became one of the factors to worry about no matter how cheap it gets. So I set about researching for months. And I guess I've made my decision.

I decided that I would use a static site generator this time. I had used Wordpress before, but I was not impressed with it. Also PHP never was my thing. I like minimalism in some aspects and the beauty of writing content using [Markdown syntax](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) appealed to me. But which generator? Open source's phenomenal rise means that one is spoilt for choice. So it is more of a matter of choosing what one likes rather than choosing _the best_.

One word which will be shouted by 8 out of 10 developers when asked about what static site generator to use, is [Jekyll](https://jekyllrb.com/). It's insanely popular and Github supports it natively making it more lucrative. One needn't even run a _build_, GitHub would take care of it and deploy it to [GitHub Pages](https://pages.github.io) automatically. For anyone entering into the world of static site generators, things couldn't be simpler. However, three things made me decide against Jekyll:

1. It's based on Ruby. And I constantly switch between my Linux machine and Windows machine. Ruby isn't really known for its Windows support nor have I played with it much. It could've been a great opportunity to learn Ruby, but at this point I don't think it would've been worthy.
2. Jekyll uses Liquid as its template engine. While really great, it's not the most powerful one out there. And somehow it didn't appeal to me.
3. When 8 out of 10 people are using something, it's hard to stand out. I wanted to stand out. :stuck_out_tongue:

So I hunted for more. And that's when I discovered [Hugo](https://gohugo.io/). Now while every other generator seems to be content with using a interpreted language like Ruby, JavaScript, CoffeeScript, etc. for their base, Hugo has chosen to be different and has been built using Go. Go has been around for ages, but it has started to gain traction only very recently. I'm a big fan of C. And Go's approach really fascinates me. I always wanted to learn it, and this seemed to be a great opportunity. And unlike the case with Ruby, this actually is something worthwhile, I would say.

Go's compiled nature means the builds are freakin' fast - Big plus for Hugo. It also means extensibility is difficult. But that doesn't seem to be a problem, it packs nearly every feature one would require to build an amazing blog. It's template engine is Go's own text template engine, which is vastly more powerful _(albeit less intuitive)_ than Liquid. I tried out a few examples from Hugo's site and my mind was set - this is it.

--------------------------------------------------------------------------------

_It's been pretty late for me now. I would continue this tomorrow. Watch this space!_
