---
draft: false
date: 2019-01-30T20:19:12+05:30
title: "TIL: The dig command"
description: "Just me figuring out that the Domain Information Groper exists."
slug: ""
tags: ["commands","til"]
categories: ["linux"]
externalLink: ""
---

The title is pretty much self-explanatory: **Today I Learnt that the `dig` command exists and my mind if pretty much blown.**

Till today, the way I checked my domain records was either by going to my registrar's page or by using `nslookup` to get the A record which is what I mostly have to do. But then I discovered `dig`. Ahh...

`dig google.com ANY +noall +answer`

That's all it takes. LOOK AT THIS RESPONSE!

```bash
; <<>> DiG 9.10.3-P4-Debian <<>> google.com ANY +noall +answer
;; global options: +cmd
google.com.             299     IN      A       74.125.24.102
google.com.             299     IN      A       74.125.24.100
google.com.             299     IN      A       74.125.24.139
google.com.             299     IN      A       74.125.24.113
google.com.             299     IN      A       74.125.24.138
google.com.             299     IN      A       74.125.24.101
google.com.             299     IN      AAAA    2404:6800:4003:c03::71
google.com.             599     IN      MX      40 alt3.aspmx.l.google.com.
google.com.             21599   IN      NS      ns3.google.com.
google.com.             59      IN      SOA     ns1.google.com. dns-admin.google.com. 231601783 900 900 1800 60
google.com.             599     IN      MX      20 alt1.aspmx.l.google.com.
google.com.             299     IN      TXT     "docusign=05958488-4752-4ef2-95eb-aa7ba8a3bd0e"
google.com.             3599    IN      TXT     "facebook-domain-verification=22rm551cu4k0ab0bxsw536tlds4h95"
google.com.             21599   IN      NS      ns4.google.com.
google.com.             599     IN      MX      10 aspmx.l.google.com.
google.com.             599     IN      MX      50 alt4.aspmx.l.google.com.
google.com.             21599   IN      NS      ns1.google.com.
google.com.             3599    IN      TXT     "globalsign-smime-dv=CDYX+XFHUw2wml6/Gb8+59BsH31KzUr6c1l2BPvqKX8="
google.com.             21599   IN      CAA     0 issue "pki.goog"
google.com.             21599   IN      NS      ns2.google.com.
google.com.             599     IN      MX      30 alt2.aspmx.l.google.com.
google.com.             3599    IN      TXT     "v=spf1 include:_spf.google.com ~all"
```

This pretty much gives me everything I need! I love it.

> [dig][dig-link] stands for _Domain Information Groper_, by the way.

[dig-link]: https://linux.die.net/man/1/dig
