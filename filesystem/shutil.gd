##################################################################################
#                            This file is part of                                #
#                                GodotExplorer                                   #
#                       https://github.com/GodotExplorer                         #
##################################################################################
# Copyright (c) 2017-2018 Godot Explorer                                         #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal  #
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
##################################################################################

tool

# Copy the file `src` to the file `dst`.  
# Permission bits are ignored. `src` and `dst` are path names given as strings.  
# - - -  
# **Parameters**  
# * src: String The source file to copy from  
# * dst: String The destination file to copy  
# * buff_size: int The buffer size allocated while coping files  
# - - -  
# **Return**  
# * Error the OK or error code  
static func copy(src, dst, buff_size=64*1024):
    var fsrc = File.new()
    var err = fsrc.open(src, File.READ)
    if OK == err:
        var dir = Directory.new()
        if not dir.dir_exists(dst.get_base_dir()):
            err = dir.make_dir_recursive(dst.get_base_dir())
        if OK == err:
            var fdst = File.new()
            err = fdst.open(dst, File.WRITE)
            if OK == err:
                var page = 0
                while fsrc.get_pos() < fsrc.get_len():
                    var sizeleft = fsrc.get_len() - fsrc.get_pos()
                    var lenght = buff_size if sizeleft > buff_size else sizeleft
                    var buff = fsrc.get_buffer(lenght)
                    fdst.store_buffer(buff)
                    page += 1
                fdst.close()
                fsrc.close()
    return err
