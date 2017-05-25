#!/usr/bin/env python
'''
---------------------------------------------------------------------------------
							This file is part of                                
								GodotExplorer                                   
					   https://github.com/GodotExplorer                         
---------------------------------------------------------------------------------
 Copyright (c) 2017 Godot Explorer                                              
																				
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
# coding=utf-8
import re
import fnmatch
import os
import sys

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
	for f in glob_path(".", "__init__.gd"):
		try:
			os.remove(f)
		except e:
			print("Failed remove file {} \n{}".format(f, e))
	if not '-c' in sys.argv and not '--clean' in sys.argv:
		extract_dir(".")


def extract_dir(root):
	pathes = os.listdir(root)
	content = ""
	licenseText = open('license').read()

	for p in pathes:
		path = os.path.join(root,p).replace("./", "").replace(".\\", "")
		if os.path.isfile(path) and path.endswith(".gd") and not path.endswith('__init__.gd'):
			content += gen_expression(root, path)
		elif os.path.isdir(path):
			subdirfile = extract_dir(path)
			if subdirfile is not None:
				content += gen_expression(root, subdirfile)
	if len(content) > 0:
		gdfile = os.path.join(root, '__init__.gd')
		try:
			open(gdfile,'w').write(licenseText + content)
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
	return 'const {} = preload("{}")\n'.format(name, path)

if __name__ == '__main__':
	main()