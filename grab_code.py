#!/usr/bin/env python

import fileinput
import re

starthighlight = re.compile(".*highlight +gap.*")
endhighlight = re.compile(".*endhighlight.*")
fileinclude = re.compile(".*\{\% +include +code-link.html.*file=\"(.*)\".*\%\}")
flag = False
for line in fileinput.input():
    if starthighlight.match(line):
        flag = True
    elif endhighlight.match(line):
         flag = False
         print "#### --"
    elif fileinclude.match(line):
         name = fileinclude.match(line).group(1)
         print "#### " + name
         with open("downloads/code/" + name) as file:
           for l in file.readlines():
                print l,
         print "#### --"
    elif flag:
        print line,
