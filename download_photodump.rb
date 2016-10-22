require 'json'
require 'shellwords'
require 'dotenv'
Dotenv.load

root = ENV['PHOTODUMPROOT'] || "."

ARGF.each_line{|line|
  photo = JSON.parse(line)

  path = File.join(root, photo['id'])
  cmd = "curl #{photo['src'].shellescape} > #{path.shellescape}"

  if !File.exists?(path) || File.size(path) == photo['size']
    `#{cmd}`
  end
}
