#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
---------------------------------------------------------------------------------
							This file is part of                                
								GodotExplorer                                   
					   https://github.com/GodotExplorer                         
---------------------------------------------------------------------------------
 Copyright (c) 2017-2019 Godot Explorer                                         
																				
 Permission is hereby granted, free of charge, to any person obtaining a copy   
 of this software and associated documentation files (the "Software"), to deal  
 in the Software without restriction, including without limitation the rights   
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      
 copies of the Software, and to permit persons to whom the Software is          
 furnished to do so, subject to the following conditions:                       
																				
 The above copyright notice and this permission notice shall be included in all 
 copies or substantial portions of the Software.                                
																				
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  
 SOFTWARE.                                                                      
---------------------------------------------------------------------------------
'''

import re
import fnmatch
import os
import sys

CWD = os.path.abspath(os.path.dirname(__file__))
IGNORE_LIST = [
	os.path.join(CWD, ".vscode"),
	os.path.join(CWD, "autoloads"),
	os.path.join(CWD, "plugin.gd")
]
LIB_NAME = None

def glob_path(path, pattern):
	result = []
	for root, _, files in os.walk(path):
		for filename in files:
			if fnmatch.fnmatch(filename, pattern):
				result.append(os.path.join(root, filename))
	return result

def identify(name):
	newname = name
	if len(newname) > 0:
		if newname[:1] in '0123456789':
			newname = re.sub('\d', '_', newname, 1)
		newname = re.sub('[^\w]', '_', newname)
	return newname

def main():
	for f in glob_path(os.getcwd(), "__init__.gd"):
		try:
			if os.path.dirname(f) not in IGNORE_LIST:
				os.remove(f)
		except e:
			print("Failed remove file {} \n{}".format(f, e))
	if not '-c' in sys.argv and not '--clean' in sys.argv:
		extract_dir(os.getcwd())


def extract_dir(root):
	if root in IGNORE_LIST:
		return None
	pathes = sorted(os.listdir(root))
	content = ""
	licenseText = open(os.path.join(CWD, 'LICENSE')).read()
	delayExtracs = []
	for p in pathes:
		path = os.path.join(root,p)
		if path in IGNORE_LIST:
			continue
		path = path.replace("./", "").replace(".\\", "")
		if os.path.isfile(path) and path.endswith(".gd") and not path.endswith('__init__.gd'):
			if os.path.basename(root) + ".gd" == os.path.basename(path):
				delayExtracs.append((root, path))
			else:
				content += gen_expression(root, path)
		elif os.path.isdir(path):
			subdirfile = extract_dir(path)
			if subdirfile is not None:
				content += gen_expression(root, subdirfile)
	for dp in delayExtracs:
		content += gen_expression(dp[0], dp[1])
	if len(content) > 0:
		gdfile = os.path.join(root, '__init__.gd')
		try:
			toolprefix = '\ntool\n'
			if root == CWD: toolprefix += 'extends Node\n'
			if LIB_NAME: toolprefix += 'class_name {}\n'.format(LIB_NAME)
			open(gdfile,'w').write(toolprefix + "\n" + content)
		except e:
			raise e
		return gdfile
	return None

def gen_expression(root, filepath):
	path = os.path.relpath(filepath, root)
	path = path.replace('\\', '/')
	name = identify(os.path.basename(path)[:-3])
	if os.path.basename(path) == '__init__.gd':
		name = identify(os.path.basename(os.path.dirname(filepath)))
	if os.path.basename(root) + ".gd" == os.path.basename(filepath):
		return '\n{}\n'.format(open(filepath).read())
	else:
		return 'const {} = preload("{}")\n'.format(name, path)

if __name__ == '__main__':
	main()