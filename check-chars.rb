#!/usr/bin/env ruby
# ARGFに渡されたUTF-8の入力ファイルの全文字を確認し、
# Unicodeブロックに分ける。
# 危ないブロックについてはその文字を表示する
#
# Copyright (c) 2019 Kenshi Muto <kmuto@kmuto.jp>
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# gem install unicode-blocks でgemをインストールしておいてください
require 'unicode/blocks'
require 'optparse'

verbose = nil

# 警告したい文字ブロック
targetblocks_str = <<EOT.chomp
Arabic Presentation Forms-B
Block Elements
Braille Patterns
Dingbats
Emoticons
Enclosed Alphanumerics
Greek and Coptic
IPA Extensions
Latin Extended-A
Latin-1 Supplement
Letterlike Symbols
Mathematical Operators
Miscellaneous Symbols and Pictographs
Transport and Map Symbols
Unexpected Control
Unexpected Halfwidth and Fullwidth Forms
EOT

targetblocks = targetblocks_str.split("\n")

opt = OptionParser.new
opt.banner = "使い方: check-chars.rb [オプション] ファイル...\n  TeXやInDesignで危険な文字を検出する。"
opt.on('-v', '全文字について表示') { verbose = true }
opt.parse!(ARGV)

chars = []
ARGF.each do |l|
  l.chomp!
  chars += l.split('')
end

chars2 = chars.sort.uniq
chars2.each do |c|
  block = Unicode::Blocks.block(c)
  cp = nil

  if /[[:cntrl:]]/.match(c)
    block = 'Control'
    c = c.codepoints
    cp = c[0].to_s(16)
    # tab以外 (行末改行はchomp!で消えているはず)
    if c[0] != 9
      block = 'Unexpected Control'
    end
  else
    cp = c.codepoints[0].to_s(16)
  end

  if c == '｡' || c == '､'
    block = 'Unexpected Halfwidth and Fullwidth Forms'
  end

  if verbose
    # 全文字
    puts "#{c}\t#{block} (#{cp})"
  elsif targetblocks.include?(block)
    puts "#{c}\t#{block} (#{cp})"
  end
end
