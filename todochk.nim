## Agile TODO's
##

## https://youtu.be/B67DVkJRdpQ

## We all write great code!

## We work hard, carve out the
## best data structures, polish
## shiny, powerful abstractions,
## and ensure all the devilish
## details of getting it just
## right are coded. Hey it's a
## hard job but someone's gotta
## do it.

## And because of all the effort
## we put in to get it done
## through the sweat of our brow
## we are rightly proud of our
## efforts and of our marvelous
## creations...


## ...until we aren't that is...

##  it-wasnt-me.png

## Our once beautiful creations
## are far too often skewed into
## ugly, embarrassing eyesores
## festooned with barnacles.
## Looking at the code we were
## once so proud of, we can
## scarcely remember why we were
## once proud of this
## scab-infested monstrosity.

## This is a frustrating and
## common phenomenon among
## software engineers. In other
## words, it's just "the way
## things are".

## The last time this happened
## to me was on some [href=https://nodejs.org](Node.js)
## code I had written for an
## internal slideshow app. When
## I first wrote it, it had
## seemed so beautiful, but when
## I went to make the latest
## changes I realized I wasn't
## very happy with the code
## anymore.

## So I sat down to figure out
## what the problem could be...

##  why.png

## And I struck upon a reason
## this could happen. I'm not
## sure it's the only reason or
## the best but it's definitely
## a major contributor. And the
## reason is:

## *_Being in a Hurry!_*

## Now I understand that being
## in a hurry is inevitable -
## deadline pressures, Friday
## night parties, screaming
## customers, or just feeling
## fed up are just some of the
## reasons we are in a hurry to
## finish. And these are
## perfectly valid reasons. All
## I'm saying is it _explains_ why
## our once beautiful code is
## now warty and pimply and
## beginning to creak and sag.

## So just what should we do?
## Should we just accept that
## this will never change and
## that code will get older and
## more horrible? Should we
## force ourselves to always
## slow down and make sure we
## release wonderful code at
## every point? Well perhaps -
## but in the cases where we
## just have to go with the
## quick-and-dirty here is a
## suggestion you may want to
## try with your team:

## *__Enter the humble TODO__*
## A neat and simple solution
## to when you are in a hurry is
## to use the humble TODO
## marker. This solution has two
## parts:
##
## *___The Solution
##  (1) When in a hurry _always_
##  drop a TODO marker with a
##  short description of what
##  you aren't doing that could
##  have been done better.
##
##  (2) When refactoring use
##  these TODO markers as
##  starting points and clean
##  them up.
## ___*

## Almost everybody stumbles
## into the first part of this solution.
## We know this from the
## bewildering variety of TODO
## markers we see in the wild:

## *____TODO TO_DO TO DO FIXME
## FIX_ME FIX ME XXX ZZX HACK
## !!! ???  TOFIX TO_FIX TO FIX
## ISSUE NOTE REVISIT____*

## I found an interesting paper
## that seems to confirm this.
## [href=https://www.researchgate.net/publication/221555589_TODO_or_to_bug_exploring_how_task_annotations_play_a_role_in_the_work_practices_of_software_developers](TODO or To Bug: Exploring
## How Task Annotations Play a
## Role in the Work Practices of
## Software Developers).


## Therefore all we have to do
## is to be a bit more
## structured in the way we use
## our TODO's and make sure they
## don't face the "write-only"
## list problem.

## In other words:

## *_____Keep our TODO's Agile!_____*

## Q: What can we do to help this?
## A: A simple start would be to
## measure the turnover of
## TODO's in the code and strive
## to keep that at a reasonable
## level.

## Q: How should we measure turnover?
## A: Check the number of TODO's
## added and the number of
## TODO's removed in the version
## history log. The turnover is
## then:
##
##                removed
##    turnover = -------- x 100
##                 added
##

## I've tried measuring turnover
## on a few projects and have
## got turnovers ranging from
## 87% to 31% (and 0% for no
## TODO's) which gave me a good
## indication of which projects
## were doing well with their
## TODO's and which were not.

## Try it out yourself and see
## if if works for you.

## The rest of this file
## generates a quick and simple
## report for any git repository
## on the TODO turnover which
## you can use for your team.
##

## NB: It is written in [href=http://nim-lang.org/](Nim) and
## the nim IPC is a bit slow so
## the result can be sped up so
## ping me if you would like it
## optimized. Or, in other words -
## *TODO:* Optimize? :-)

import osproc, nre, streams, strutils

# TODO Marker
let TODORX = re"[^A-z0-9](TO[ _]?DO|FIX[ _]?ME|XXX|ZZX)[^A-z0-9]"

# [=] Calculate the TODO
# turnover using the formula:
#
#                removed
#    turnover = -------- x 100
#                 added
#
# [ ] Get the version history
# log along with the patches
# committed using:
#   git log -p
# [ ] If the line starts with
# "+++" or "---" ignore it
# [ ] If a line starts with "+"
# check to see if the line
# contains a TODO and increment
# "added" counter
# [ ] If a line starts with "-"
# check to see if line contains
# a TODO and increment "removed"
# counter
# [ ] Calculate and return the
# turnover
proc calculate_turnover(): int =

  var p = startProcess("git", args=["log", "-p"], options={poUsePath})
  var outp = outputStream(p)
  var line = newStringofCap(120).TaintedString
  var added: int = 0
  var removed: int = 0
  while true:
    if outp.readLine(line):
      if line.startsWith("+++ ") or line.startsWith("--- "):
        continue
      if line.startsWith("+"):
        if contains(line, TODORX): added += 1
      if line.startsWith("-"):
        if contains(line, TODORX): removed += 1
    elif not running(p): break
  close(p)

  if added > 0:
    let turnover = removed*100/added
    return int(turnover)

  return 0


# [!] Return a list of text
# files checked into git.
# [+] Git keeps track of the
# files checked in and their
# content type so we can use
# that.
# [+] The command to use is:
#   git ls-files
# [+] The option that gives us
# information about the content
# type is:
#   --eol
# [+] We get output like the
# following:
#
#    i/lf    w/lf    attr/ .gitignore
#    i/-text w/-text attr/ 000/bye.png
#    i/lf    w/lf    attr/ 000/post.css
#    i/mixed w/mixed attr/ AppDelegate.swift.php
#
# (the separator between the
# file name and attributes is a
# tab character)
# [ ] Run "git ls-files --eol"
# [ ] Read the output line by line
# [ ] Filter out the text file
# lines
# [ ] Return the filenames
# filtered
proc get_git_text_files(): seq[string] =

  # [:cond:]
  # [=] Check if the given line is a
  # text file
  # [ ] The second field must be
  # one of w/lf, w/cr, w/crlf,
  # or w/mixed
  proc cond_is_text_file(line: string): bool =
    let rx = re" (w/[^ ]*) "
    let m = find(line, rx)
    if m.isSome():
      let v = m.get().captures[0]
      return v == "w/lf" or v == "w/cr" or v == "w/crlf" or v == "w/mixed"
    return false

  # [=] Extract the filename
  # from the output line
  # [ ] Split line into
  # attribute,filename (at first tab)
  # and return filename
  proc extract_filename(line: string): string =
    let rx = re".*\t(.*)"
    let m = match(line, rx)
    if m.isSome():
      return m.get().captures[0]
    return nil

  var p = startProcess("git", args=["ls-files", "--eol"], options={poUsePath})
  var outp = outputStream(p)
  var line = newStringofCap(120).TaintedString
  result = @[]
  while true:
    if outp.readLine(line):
      if cond_is_text_file(line):
        result.add(extract_filename(line))
    elif not running(p): break
  close(p)


# [=] Count the number of TODO's
# pending in the code right now.
# [ ] Get list of text files
# from git
# [ ] Add the number of TODO's
# in each file
proc count_todos(): int =

  # [=] Count the number of
  # TODO's in a file
  # [ ] Count the number of
  # lines in the file that match
  # a TODO marker.
  proc count_todos_in(file:string): int =
    var count: int = 0
    for line in lines file:
      if contains(line, TODORX): count += 1
    return count

  let txt_files = get_git_text_files()
  var count = 0
  for file in txt_files:
    count += count_todos_in(file)
  return count


# [:start:]
# [=] Report the turnover of
# TODO's along with the number
# outstanding.
# [ ] Calculate the turnover
# [ ] Count the number of
# pending TODO's
# [ ] Show both
#
let turnover = calculate_turnover()
let outstanding = count_todos()
echo $turnover & "% turnover (" & $outstanding & " TODO's outstanding)"
