#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'optparse'
require 'time'
require 'pathname'
require 'fileutils'
require 'retry-handler'

# コマンドライン引数を解析してハッシュに格納する
args = {}
arg_keys = [:from, :to, :date]
OptionParser.new do |parser|

  parser.accept(Time) do |s, |
    begin
      Time.parse(s) if s
    rescue
      raise OptionParser::InvalidArgument, s
    end
  end

  parser.on('-f', '--from COPY_FROM') {|v| args[:from] = v}
  parser.on('-t', '--to COPY_TO') {|v| args[:to] = v}
  parser.on('-d', '--date DATE', Time) {|v| args[:date] = v}
  parser.parse!(ARGV)
end

# 処理に必要はコマンドライン引数が設定されているか確認
# 設定されていなかったら処理を終了する
arg_keys.each do |key|
  unless args.has_key?(key)
    puts "Please input #{key.to_s}."
    exit 1
  end
end

# 指定されたディレクトリが存在するか確認
# 存在しない倍は処理を終了する
[args[:from], args[:to]].each do |dir|
  unless FileTest.exists?(dir) and FileTest.directory?(dir)
    puts "#{dir} not exists."
    exit 1
  end
end

copy_to_base = Pathname.new(args[:to])

# PDF最適化スクリプトのフルパスを取得
command = File::expand_path('./shrink_pdf.sh')

# 処理対象ディレクトリ配下のPDFファイルを列挙するためのパターン
pattern = "#{File::expand_path(args[:from])}/**/*.pdf"

# PDFファイルを列挙
Pathname::glob(pattern).each do |copy_from|

  # 最終更新日が指定された日付以前なら処理しない
  next if args[:date] > copy_from.mtime

  # コピー先のpathを生成
  # 元コピー先 + コピー元ファイルのディレクトリ名 + コピー元ファイルのファイル名
  copy_to_dir = copy_to_base.join(copy_from.parent.basename)
  copy_to = copy_to_dir.join(copy_from.basename)

  # 処理済みのファイルスキップ
  if FileTest.exist?("#{copy_to}.bak")
    puts "#{copy_to} was converted."
    next
  end

  # コピー先ディレクトリが存在するなら削除
  # if copy_to_dir.exist?
    # FileUtils.rm_rf(copy_to_dir.to_s)
  # end
  copy_to_dir.mkdir unless copy_to_dir.exist?

  FileUtils.copy_file(copy_from.to_s, copy_to.to_s)

  begin
    Proc.new {
      puts "Target file is #{copy_to.to_s}."
      ret = system("#{command} \"#{copy_to.to_s}\"")
      raise "Command error happend." unless ret
    }.retry(max: 5, wait: 1, accept_exception: StandardError)
  rescue RetryOverError
    puts 'Retry over.'
  end
end

