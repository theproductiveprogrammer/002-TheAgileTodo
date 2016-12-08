## The Agile TODO List
##

## https://youtu.be/-4S6UPH5lSU

## I don't know about you but I
## often look back at code I
## have written and feel bad
## about it.

##  it-wasnt-me.png

## Why is this? I had always
## accepted this as something
## that happened but then I
## began to wonder _why_.

##  why.png

## One of the problems, I have
## found, is there are actually
## _two_ distinct stages while
## writing code:
##
##  (1) The design is clear and
##  the approach we have started
##  with can be accomplished and
##  we are only having fun
##  "translating" it into
##  working code.
##  (2) The design is breaking
##  down (or we don't have one)
##  and we are "exploring" how to
##  solve the problem.

## Now I don't know about you
## but if I am under pressure
## for delivery I usually
## reach stage (2) very quickly.
## I _know_ I can do better but
## I just don't have the time
## right now. I'm sure you've
## faced this situation and so
## has everyone in your team.

## So just what should we do?

## *_Enter the humble TODO_*
## A simple, powerful, solution
## is to use the humble TODO
## marker. Everyone stumbles
## into this solution as we can
## see from the bewildering
## variety of TODO markers
## found in the wild:

#Todo markers

## Because it is such a common
## solution we should be able to
## make use of it strategically
## in our teams. Here is a
## suggestion for how we could
## approach this for the most
## productive output.
##
## * Get as clear about the
## design as you can, then code
## that out as fast as you can
## to get to completion.
##
## * When there is the slightest
## doubt about needing to spend
## time on coding rather than
## completing, simply write a
## TODO marker _along with the
## reason_ and proceed.
##
## This simple strategy of using
## TODO's effectively segregates
## the code into code that the
## developer is happy with and
## code that the developer is
## not happy with.
##
## This means, whenever we want
## to spend time refactoring, we
## now have a nice place to
## start - not only do we have a
## point (the TODO) but we
## usually have some starting
## reason as well (the TODO
## comment).
##

## *__The Write Only Problem__*
## The problem with the TODO
## list, as we all know, is that
## it becomes a "write only
## list" of items that are
## seldom taken up or corrected.
## So what can we do? A simple
## start would be to measure the
## turnover of TODO's in the
## code and strive to keep that
## at a reasonable level.

## How do we measure turnover?
## We simply check the number of
## TODO's added and the number
## of TODO's removed in the
## version history log. The
## turnover is then:
##
##                removed
##    turnover = -------- x 100
##                 added
##

## The rest of this file
## generates a quick and simple
## report for any git repository
## on the TODO turnover which
## you can use for your team.
##

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
