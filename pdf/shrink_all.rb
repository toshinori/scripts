#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'retry-handler'

# 処理対象のディレクトリを取得
target = ARGV[0]

if target.nil? or target.empty?
	puts "Target directory not set."
	exit 1
end

# ディレクトリが存在しない場合はエラー
unless FileTest.exist?(target) and FileTest.directory?(target) then
	puts "Directory not found."
end

# PDF最適化スクリプトのフルパスを取得
command = File::expand_path('./shrink_pdf.sh')

# 処理対象ディレクトリ配下のPDFファイルを列挙
pattern = "#{File::expand_path(target)}/**/*.pdf"

Dir::glob(pattern).each do |f|
  # 処理済みのファイルスキップ
  if FileTest.exist?("#{f}.bak")
    puts "#{f} was converted."
    next
  end

  # https://github.com/kimoto/retry-handler/blob/master/README.rdoc
  # retry-handlerを使用してコマンドがエラーを返してきたら
  # 指定回数リトライする
  begin
    # http://doc.ruby-lang.org/ja/1.9.2/class/Benchmark.html
    Proc.new {
      puts "Target file is #{f}."
      ret = system("#{command} \"#{f}\"")
      raise "Command error happend." unless ret
    }.retry(max: 5, wait: 1, accept_exception: StandardError)
  rescue RetryOverError
    # リトライ回数を超えた場合
    puts 'Retry over.'
  end
end
