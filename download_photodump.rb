require 'json'
require 'shellwords'
require 'fileutils'
require 'dotenv'
Dotenv.load

root = ENV['PHOTODUMPROOT'] || "."
FileUtils.mkdir_p(root)

ARGF.each_line{|line|
  photo = JSON.parse(line)

  path = File.join(root, photo['id'])
  cmd = "curl #{photo['src'].shellescape} > #{path.shellescape}"

  if !File.exists?(path) || File.size(path) == photo['size']
    `#{cmd}`
  end
}
