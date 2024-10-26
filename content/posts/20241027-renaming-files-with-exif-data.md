+++ 
draft = false
date = 2024-10-27T01:03:09+05:30
title = "Renaming files with EXIF data"
description = "My attempt at renaming a whole bunch of image files with their EXIF data."
slug = ""
authors = ["Rajshri Mohan K S"]
tags = ["golang","diy","exif"]
categories = ["experiments"]
externalLink = ""
series = []
+++

I suddenly found myself with a folder full of photos worth a whole 10GB which had rather awkward names. Seems like the photographer who shot the pictures used identical naming on multiple cameras/SD cards taken during multiple different times and as a result there were multiple files with the same base name but had `(1)` appended to them. Worse, some had `(1) (2)` appended:

![before-picture](/post-img/original-dir.png)

This meant the ordering was all horrible when viewed in Windows Explorer. When I poked around a bit, I found that the EXIF data was still intact and that meant, we can attempt to rename the files to order them chronologically. (Most photo libraries will automatically do this, including Google Photos where I planned on uploading them...But I wanted them to look neat on Windows Explorer as well.)

My first thought was to see if Microsoft PowerToys' excellent [PowerRename utility](https://learn.microsoft.com/en-us/windows/powertoys/powerrename) could do this out of the box. Sadly, this was not the case. Which meant, I've to probably write a script.

The first challenge is to extract the EXIF data from the image file. I came across this small utility called [ExifTool](https://exiftool.org/) which could extract EXIF metadata from an image file. So I attempted combining this with some PowerShell scripting. After an hour of fumbling around, I realized that my PowerShell skills are horrible at best and I was having a hard time using RegExs in PowerShell scripting. I decided that the best course was to write a program in Go which would get this done.

I knew it would be easy in Go, but I didn't expect it to be _this_ easy. I found that there existed a library for dealing with EXIF data, [goexif](https://github.com/rwcarlsen/goexif) which is used within Hugo. I checked out its repo and it was straight forward to use. And so, here's the result:

![after-picture](/post-img/dir-after.png)

All files, neatly renamed and sorted chronologically!

You can find the code I used here: [GitHub](https://github.com/rajshrimohanks/exif-rename)
