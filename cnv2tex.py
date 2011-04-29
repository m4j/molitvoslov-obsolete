#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#       untitled.py
#       
#       Copyright 2011 Max Agapov <u1d070@penguin>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

import sys, codecs, locale, urllib2
from BeautifulSoup import BeautifulSoup, NavigableString, Tag
from urlparse import urlparse

# enable utf-8 output
sys.stdout = codecs.getwriter(locale.getpreferredencoding())(sys.stdout)

sections = [u"", u"chapter", u"section", u"subsection", u"subsubsection",
    u"paragraph"]

def fetch(level, baseUrl, path):
    soup = getSoup(baseUrl, path)
    my_td = getMyTd(soup)
    if level > 0:
        heading = getHeading(my_td)
        myprint("\n\n\\" + sections[level] + "{")
        myprint(heading)
        myprint("}")
    myprint("\n%" + baseUrl + path)
    node = getNode(my_td)
    outputElement(getContents(node))
    subtitles = getSubtitles(node)
    for li in subtitles:
        fetch(level + 1, baseUrl, li.a["href"])
    #myprint(soup.prettify()
    return 0

def getHeading(td):
    return td.h1.next
    
def getSubtitles(node):
    subs = node.find("ul", { "class" : "nodehierarchy_title_list" })
    if subs:
        return subs
    else:
        return []

def getNode(td):
    return td.find("div", { "class" : "node" })
    
def getContents(node):
    return node.div.contents

def myprint(str):
    sys.stdout.write(str)

def outputElement(root, allow_br=True):
    for el in root:
        if isinstance(el, NavigableString):
            #~ if el != "&nbsp;":
            s = el.replace('\n', ' ')
            s = s.replace('<', '$<$')
            s = s.replace('&lt;', '$<$')
            s = s.replace('>', '$>$')
            s = s.replace('&gt;', '$>$')
            s = s.replace('&#8212;', '"---')
            myprint(s)
        elif el.name == "br" and allow_br:
            myprint("\n\n")
        elif el.name == "p":
            myprint("\n\n")
            if el.next == "&nbsp;":
                myprint("\\medskip")
            else:
                outputElement(el, allow_br)
        elif el.name == "i" or el.name == "em":
            if el.find("br"):
                myprint("\n\n");
            myprint("{\\itshape ")
            outputElement(el, False)
            myprint("}")
        elif el.name == "b":
            myprint("{\\bfseries ")
            outputElement(el, allow_br)
            myprint("}")
    
def getMyTd(soup):
    return soup.find("div", id="center").table.tr.td.findNextSibling('td')
    
def getSoup(baseUrl, path = "/"):
    page = urllib2.urlopen(baseUrl + path)
    return BeautifulSoup(page)


if __name__ == '__main__':
    url = urlparse(sys.argv[2])
    fetch(int(sys.argv[1]), url.scheme + "://" + url.netloc, url.path)

