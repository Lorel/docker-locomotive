#!/usr/bin/env bash

echo
echo "Setting system timezone..."
dpkg-reconfigure -f noninteractive tzdata

echo
echo "Setting GEM environment..."
rm -rf ~root/.gem
export GEM_HOME=/usr/local/rvm/gems/ruby-2.3.1
export GEM_PATH=/usr/local/rvm/gems/ruby-2.3.1
export GEM_SPEC_CACHE=/usr/local/rvm/gems/ruby-2.3.1/specifications
export PATH=/usr/local/rvm/gems/ruby-2.3.1/bin:/usr/local/rvm/rubies/ruby-2.3.1/bin:$PATH
gem environment

echo
echo "Installing latest bundler..."
gem uninstall bundler-1.10.6
gem install bundler

if [ ! -f /home/app/engine/app ]; then
	echo
	echo "Setting up Ruby on Rails..."
	gem install rails -v 4.2.6
	ln -sf /usr/local/rvm/gems/ruby-2.3.1/gems/railties-4.2.6/bin/rails /usr/local/bin/rails
	cd /home/app; rails new engine --skip-bundle --skip-active-record --skip
	cd /home/app/engine
	grep "gem 'locomotivecms', '~> 3.1.1'" Gemfile || echo "gem 'locomotivecms', '~> 3.1.1'" >> Gemfile
fi

echo
echo "Installing ruby gems..."
cd /home/app/engine; RAILS_ENV=production bundle install

if [ ! -f config/initializers/locomotive.rb ]; then
	echo
	echo "Installing locomotive..."
	cd /home/app/engine; rails generate locomotive:install
	sed -i 's/localhost/db/g' /home/app/engine/config/mongoid.yml
	sed -i 's/# config.secret_key/config.secret_key/g' /home/app/engine/config/initializers/devise.rb
	sed -i 's/# config.pepper/config.secret_key/g' /home/app/engine/config/initializers/devise.rb
fi
chown app:app -R /home/app

echo
echo "Compiling Assets..."
su - app -c "cd /home/app/engine; RAILS_ENV=production bundle exec rake assets:precompile --trace"

echo
echo "Starting Phusion Passenger Stand-alone..."
/bin/bash -l -c "rvm wrapper ruby-2.3.1 --no-prefix --all"
RAILS_ENV=production bundle exec passenger start -a 0.0.0.0 -p 8080 -e production
