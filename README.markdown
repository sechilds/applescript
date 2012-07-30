# applescript version control

This is a fork of [kfdm/applescript](https://github.com/kfdm/applescript)
which gave me the idea to use a Rakefile to copy the files.

## applescript

Since I'm starting from scratch, my computer has no applescripts on it yet.
The compiled versions won't work well for version control,
so this repository (which I forked) has a Rakefile that will compile
all the applescripts and put them in the proper directory.

## Rake

I had not used `rake` before, so figuring it out took a little work.
Useful sites:

* [Rake Tutorial -- Another C Example](http://onestepback.org/index.cgi/Tech/Rake/Tutorial/RakeTutorialAnotherCExample.red)
* [ruby - Flexible Rake task - Stack Overflow](http://stackoverflow.com/questions/6563889/flexible-rake-task)
* [Rake tutorial -- Tomas Svarovsky's scrapbook](http://www.svarovsky-tomas.com/rake.html)
* The [Rakefile](https://github.com/chmurph2/iTunes-AppleScripts/blob/master/Rakefile) from [chmurph2/iTunes-AppleScripts](https://github.com/chmurph2/iTunes-AppleScripts) gave me the idea that I could just copy the files over.

My solution is not very elegent. The scripts are compiled into the existing directory and then copied over.

## install

* `git clone git://github.com/sechilds/applescript ~/applescript`
* `cd ~/applescript`
* `rake`

Installation works now.

