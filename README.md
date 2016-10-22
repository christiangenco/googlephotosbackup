# Google Photos Backup

Don't trust the cloud? Back up your google photos library to a local hard drive and sleep soundly.

## Installation

```bash
$ git clone git@github.com:christiangenco/googlephotosbackup.git
$ cd googlephotosbackup
$ bundle
```

### Oauth2 song and dance

This setup is a pain, but you only have to do it once. If you know of an easier way to get set up I'd welcome a pull request.

Create a new project on https://console.developers.google.com and [generate an Oauth client ID](https://console.developers.google.com/apis/credentials).

Put the `Client ID` and `Client secret` in your `.bashrc` or a new `.env` file in the project root:

```
GOOGLE_PHOTOS_BACKUP_CLIENT_ID="client id from the google developer console"
GOOGLE_PHOTOS_BACKUP_CLIENT_SECRET="client secret from the google developer console"
GOOGLE_PHOTOS_BACKUP_USER_ID="your_email@gmail.com"
```

Generate a refresh token by running `ruby generate_photodump.rb`:

```
$ ruby generate_photodump.rb
Visit this url:

https://accounts.google.com/o/oauth2/auth?long_url_generated_here

then enter the code URL param:
http://localhost:3000/oauth?code=
```

Visit that url, authorize your app to have access to your Google Photos data, then paste the value of the `code=` parameter in the URL it redirects to in the terminal.

Follow the generated directions:

```
Add this to your .bashrc or .env:"
GOOGLE_PHOTOS_BACKUP_REFRESH_TOKEN="generated refresh token"
```

### Set root directory

To get photos to download in a directory other than the project directory, add a line like this to your `.bashrc` or `.env`:

```
PHOTODUMPROOT="/Volumes/backup/gphotos/"
```

## Usage

```bash
$ ruby generate_photodump.rb > dump.jsona
$ ruby download_photodump.rb dump.jsona
```

Photo metadata is stored as json objects in dump.jsona, and looks like this:

```json
{"src":"https://lh3.googleusercontent.com/.../s4032/IMG_5533.JPG","id":"634319...","etag":"\"YDkqe.\"","height":3024,"width":4032,"size":1604103,"title":"IMG_5533.JPG","timestamp":1476823823,"checksum":"","summary":"","latitude":null,"longitude":null,"exif":{"fstop":2.2,"make":"Apple","model":"iPhone 6s","exposure":0.008333334,"flash":false,"focal_length":4.15,"iso":40,"time":1476805823,"image_unique_id":"f924185dc420000000000000000"},"album":{"id":"1000000082","name":"InstantUpload"}}
```

Actual files are stored by their `id` in the `PHOTODUMPROOT` directory.
