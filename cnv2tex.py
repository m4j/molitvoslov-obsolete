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
from datetime import datetime

# enable utf-8 output
sys.stdout = codecs.getwriter(locale.getpreferredencoding())(sys.stdout)

sections = [u'', u'mypart', u'mychapter', u'section', u'subsection', u'subsubsection',
    u'paragraph']

chapterSection = u'mychapter'

class Fetcher:
    
    baseUrl = ''

    "output to this file"
    myFile = None
    
    def __init__(self, baseUrl, file=None):
        "Basic constructor."
        self.baseUrl = baseUrl
        self.myFile = file

    def fetch(self, level, path):
        try:
            soup = self.getSoup(path)
            my_td = self.getMyTd(soup)
            if level == 0:
                self.myFile = self.openFile('root.tex')
                self.myprint('% Autogenerated on ' + datetime.now().isoformat())
            else:
                heading = self.getHeading(my_td)
                self.myprint('\n\n\\' + sections[level] + '{' + heading + '}')
#                self.writeText(heading)
#                self.myprint('}')
            sys.stdout.write('\n')
            sys.stdout.write('  ' * (level + 1) + path + '-->' + self.myFile.name)
            self.myprint('\n%' + self.baseUrl + path)
            node = self.getNode(my_td)
            self.outputElement(self.getContents(node))
            subtitles = self.getSubtitles(node)
            count = 0
            for li in subtitles:
                #~ if count == 3:
                    #~ break
                count = count + 1
                href = li.a['href']
                if level == 0:
                    fname = href.replace('/', '_') + '.tex'
                    try:
                        file = self.openFile(fname)
                        fetcher = Fetcher(self.baseUrl, file)
                        fetcher.fetch(level + 1, href)
                        self.myprint('\n\n\\input{' + fname + '}')
                    finally:
                        if file:
                            file.close()
                else:
                    self.fetch(level + 1, href)
            if self.isChapter(level):
                self.myprint('\n\n\\mychapterending')
        finally:
            if level == 0 and self.myFile:
                self.myFile.close()
        return 0
        
    def openFile(self, fname):
        return codecs.open(fname, 'w', 'utf-8')

    def getHeading(self, td):
        return td.h1.next

    def isChapter(self, level):
        return sections[level] == chapterSection
        
    def getSubtitles(self, node):
        subs = node.find('ul', { 'class' : 'nodehierarchy_title_list' })
        if subs:
            return subs
        else:
            return []

    def getNode(self, td):
        return td.find('div', { 'class' : 'node' })
        
    def getContents(self, node):
        return node.div.contents

    def myprint(self, str):
        self.myFile.write(str)

    def outputElement(self, root):
        for el in root:
            if isinstance(el, NavigableString):
                self.writeText(el)
            elif el.name == 'br':
                self.myprint('\n\n')
            elif el.name == 'p':
                self.myprint('\n\n')
                if el.next == '&nbsp;':
                    self.myprint('\\medskip')
                else:
                    self.outputElement(el)
            elif el.name == 'i' or el.name == 'em':
                self.myprint('\\itshape ')
                self.outputElement(el)
                self.myprint('\\normalfont{}')
            elif el.name == 'b':
                self.myprint('\\bfseries ')
                self.outputElement(el)
                self.myprint('\\normalfont{}')
            elif el.name == 'a' and el.get('class') == 'icona':
                file_name = self.findAndSaveBigIcon(el)
                self.myprint('\\myfig{' + file_name + '}')
                sys.stdout.write(', ' + file_name)
                
    def findAndSaveBigIcon(self, el_a):
        bi_soup = self.getSoup(el_a['href'])
        bi_div = bi_soup.find('div', { 'class' : 'big-icon' })
        img_src = bi_div.img['src']
        file_name = 'img/' + img_src.split('/')[-1]
        img = urllib2.urlopen(img_src)
        out = open(file_name, 'wb')
        out.write(img.read())
        out.close()
        return file_name

    def writeText(self, el_str):
        s = el_str.replace('<', '$<$')
        s = s.replace('&lt;', '$<$')
        s = s.replace('>', '$>$')
        s = s.replace('&gt;', '$>$')
        s = s.replace('&#8212;', '"---')
        s = s.replace(' - ', ' "--- ')
#        s = s.replace(' – ', ' "--- ')
#        s = s.replace(' &mdash; ', ' "--- ') 
        s = s.replace('&quot;', '"')
        self.myprint(s)

    def getMyTd(self, soup):
        return soup.find('div', id='center').table.tr.td.findNextSibling('td')
        
    def getSoup(self, path = '/'):
        page = urllib2.urlopen(self.baseUrl + path)
        return BeautifulSoup(page)

if __name__ == '__main__':
    url = urlparse(sys.argv[2])
    baseUrl = url.scheme + '://' + url.netloc
    Fetcher(baseUrl).fetch(int(sys.argv[1]), url.path)

