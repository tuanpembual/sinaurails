# README

Ruby version 2.3.3 working under Vagrant

## Install vagrant

`vagrant up`

## Install Ruby using rvm

```
curl -sSL https://get.rvm.io | sudo bash -s stable
rvm install ruby-2.3.3
gem install bundler --no-rdoc --no-ri
```

## Prepare Database

Buat user role:  
`sudo -u postgres psql --command "create role sinaurails with createdb login password 'superr4h4s14';"`

Atur koneksi untuk posgresql:  
`sudo vim /etc/postgresql/9.6/main/pg_hba.conf`

Cari bagian `local` (baris 90). ubah peer menjadi md5  
`local  all all md5`  
Kemudian restart service postgresql

## Setup Secret
`rake secret` # save ouput nilai ini dimasukkan ke file /etc/environment

## Setup Env
`sudo vim /etc/environment`

Tambahkan dengan baris berikut:  
```
#PATH="/home/ubuntu/bin:/home/ubuntu/.local/bin:/usr/local/rvm/gems/ruby-2.3.3/bin:/usr/local/rvm/gems/ruby-2.3.3@global/bin:/usr/local/rvm/rubies/ruby-2.3.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/rvm/bin"
export SINAURAILS_DATABASE_PASSWORD="superr4h4s14"
export RAILS_SERVE_STATIC_FILES="public"
export SECRET_KEY_BASE="xxxxx"
```

Reload env  
`source /etc/environment`

## Setup Rails
```
bundle install
RAILS_ENV=production bundle exec rake db:create db:migrate
RAILS_ENV=production bundle exec rake db:seed
RAILS_ENV=production bundle exec rake assets:precompile
```

## Setup Nginx
Install nginx dari lumbung hulu.
```
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" > /etc/apt/sources.list.d/nginx.list
apt update
apt install nginx
```

Edit default file di path /etc/nginx/sites-available/  
Timpa dengan baris berikut:  
```
upstream my_app {
  server unix:///home/ubuntu/puma/sinaurails.sock;
}

server {
  listen 80;
  server_name localhost; # change to match your URL
  root /vagrant/public; # I assume your app is located at that location

  location / {
    proxy_pass http://my_app; # match the name of upstream directive which is defined above
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  location ~* ^/assets/ {
    # Per RFC2616 - 1 year maximum expiry
    expires 1y;
    add_header Cache-Control public;

    # Some browsers still send conditional-GET requests if there's a
    # Last-Modified header or an ETag header even if they haven't
    # reached the expiry date sent in the Expires header.
    add_header Last-Modified "";
    add_header ETag "";
    break;
  }
}
```
Restart nginx  
`sudo systemctl restart nginx`

## Setup Puma
```
chmod +x script/puma.sh
./script/puma.sh start # (start|stop|status|restart)
```

## Setup Script for Deploy
