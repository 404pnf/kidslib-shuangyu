#!/usr/bin/env ruby
#
# rename.rb is a Ruby version of the popular Perl command found in many
# modern Linux distributions.
#
# rename.rb was adapted from Larry Wall and Robin Barker's similar Perl
# script. This version, however, supports Ruby- instead of Perl-style
# filename transformations. Of particular interest in the Ruby script
# is the fact that an internal variable 'f', representing the current
# filename being renamed, is exposed on the external command line to
# the caller. This leads to the potential application of interesting
# Ruby-based side effects involving passive or active manipulation of
# the filename or the contents of the file while it is being renamed.
#
# For example, clever if somewhat silly transformations of filenames
# can be accomplished.  You can turn all the files in a directory into
# their natural palindromes with the command:
#
#   ./rename.rb -n 'concat(f.chop.reverse)' *
#
# In this command, the -n option tells rename not to actually perform
# the rename, but only to show what would have been done. The command
# 'concat(f.chop.reverse)' is enclosed in quotes (due to the embedded
# parentheses) and applied to each filename in turn. Finally, the
# filenames to be renamed comprise the remaining arguments on the command
# line. In this case the shell glob expression * tells shell to produce
# a list of all the file and directory names in the current directory
# and provide this list as arguments to rename.rb.
#
# The following command adds the md5sum of the contents of the file to
# the new name of the corresponding file:
#
#   ./rename.rb -n 'concat("."+`md5sum #{f}|cut -d" " -f 1`).chomp' *
#
# Lower-casing each file or directory name in a directory is accomplished
# by this simple command:
#
#   ./rename.rb -n downcase *
#
# Like Perl's version, this script will not rename a file if the
# transformed filename is the same as the original filename unless
# --force is requested. Instead, the program will silently resume
# processing any remaining filenames.
#
# The options for rename.rb:
#
#     -v, --verbose
#          Print names of files successfully renamed
#     -n, --no-act
#          Show which files would have been renamed, but do not actually perform the action
#     -f, --force
#          Overwrite existing files
#
# If filenames are not provided, rename.rb will read names from standard input.
#
# Copyright (c) 2008 Technetra Corp
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
require 'optparse'
 
verbose = no_act = force = op = nil
OptionParser.new do |opts|
  opts.banner = "Usage: rename.rb [options]"
  opts.on("-v", "--verbose", "Run verbosely") { |v| verbose = v }
  opts.on("-n", "--[no-]no-act", "Show what files would have been renamed") { |n| no_act = n }
  opts.on("-f", "--force", "Force, overwrite existing files") { |f| force = f }
end.parse!
 
verbose = true if no_act
op = ARGV.shift
 
if (argvcopy = ARGV).empty?
    print "reading filenames from STDIN\n" if verbose
    argvcopy = STDIN.read.split("\n")
end
 
argvcopy.each { |f|
    was = f
    f = eval("f.dup.#{op}")
    next if was == f # ignore quietly
    if File.exist?(f) and !force
	print  "#{was} not renamed: #{f} already exists\n"
    elsif no_act or File.rename(was, f)
	print "#{was} renamed as #{f}\n" if verbose
    else
	print "Can't rename #{was} #{f}: $!\n"
    end
}