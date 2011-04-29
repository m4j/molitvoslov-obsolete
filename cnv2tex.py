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

import sys, urllib2
from BeautifulSoup import BeautifulSoup, NavigableString
from urlparse import urlparse

sections = ["", "chapter", "section", "subsection", "subsubsection",
    "paragraph"]

def fetch(level, baseUrl, path):
    soup = getSoup(baseUrl, path)
    my_td = getMyTd(soup)
    if level > 0:
        heading = getHeading(my_td)
        print "\n\n\\" + sections[level] + "{" + heading + "}"
    print "\n%" + baseUrl + path
    node = getNode(my_td)
    for el in getContents(node):
        outputElement(el)
    subtitles = getSubtitles(node)
    for li in subtitles:
        fetch(level + 1, baseUrl, li.a["href"])
    #print soup.prettify()
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
    
def outputElement(el):
    if isinstance(el, NavigableString):
        print "\n" + el
    
def getMyTd(soup):
    return soup.find("div", id="center").table.tr.td.findNextSibling('td')
    
def getSoup(baseUrl, path = "/"):
    page = urllib2.urlopen(baseUrl + path)
    return BeautifulSoup(page)


if __name__ == '__main__':
    url = urlparse(sys.argv[1])
    fetch(0, url.scheme + "://" + url.netloc, url.path)

