require 'signet/oauth_2/client'
require 'picasa'
require 'dotenv'
require '~/utils/lowdash'
require 'json'
require 'ruby-progressbar'
Dotenv.load

# require 'pry'

client = Signet::OAuth2::Client.new(
  :authorization_uri => 'https://accounts.google.com/o/oauth2/auth',
  :token_credential_uri =>  'https://www.googleapis.com/oauth2/v3/token',
  :client_id => ENV['GOOGLE_PHOTOS_BACKUP_CLIENT_ID'],
  :client_secret => ENV['GOOGLE_PHOTOS_BACKUP_CLIENT_SECRET'],
  :scope => 'email profile https://picasaweb.google.com/data/',
  :redirect_uri => 'http://localhost:3000/oauth',
  :refresh_token => ENV['GOOGLE_PHOTOS_BACKUP_REFRESH_TOKEN'],
)

if client.refresh_token
  client.refresh!
else
  puts "Visit this url: "
  puts
  puts client.authorization_uri
  puts
  puts "then enter the code URL param:"
  print "http://localhost:3000/oauth?code="
  client.code = gets.chomp
  client.fetch_access_token!
  puts "Add this to your .bashrc or .env:"
  puts "GOOGLE_PHOTOS_BACKUP_REFRESH_TOKEN=\"#{client.refresh_token}\""
end

# picasa = Picasa::Client.new(user_id: "me", authorization_header: Signet::OAuth2.generate_bearer_authorization_header(client.access_token))
picasa = Picasa::Client.new(user_id: ENV["GOOGLE_PHOTOS_BACKUP_USER_ID"], access_token: client.access_token)
# binding.pry
progressbar = ProgressBar.create(title: "Downloading metadata", total: picasa.album.list.total_results, output: STDERR)
albums = picasa.album.list.albums.map{|a|
  album = picasa.album.show(a.id)
  progressbar.increment

  data = {
    id: a.id,
    name: a.name,
    numphotos: a.numphotos,
    photos: album.photos.map{|photo|
      exif = Hash[[:fstop, :make, :model, :exposure, :flash, :focal_length, :iso, :time, :image_unique_id].map{|k| [k, photo.exif.send(k)]}]
      exif[:time] = exif[:time].try(:to_time).try(:to_i)

      src = photo.content.src
      # add size to src
      src = src.reverse.sub("/", "/s#{photo.width}/".reverse).reverse
      # binding.pry
      photo_data = {
        src: src,
        id: photo.id,
        etag: photo.etag,
        height: photo.height,
        width: photo.width,
        size: photo.size,
        title: photo.title,
        timestamp: photo.timestamp.to_i,
        checksum: photo.checksum,
        summary: photo.summary,
        latitude: photo.latitude,
        longitude: photo.longitude,
        exif: exif,
        album: {
          id: a.id,
          name: a.name,
        }
      }
      puts photo_data.to_json
      photo_data
    },
  }

  # puts data.to_json
  # binding.pry
}
progressbar.finish

# puts ({albums: albums}).to_json
# binding.pry
# picasa.album.create(title: "api test", timestamp: Time.now.to_i)
# picasa.photo.create("album_id", file_path: "path/to/my-photo.png")
