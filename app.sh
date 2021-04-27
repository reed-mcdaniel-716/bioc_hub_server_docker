#!/usr/bin/env bash
echo "First arg to app.sh: $1"
ruby schema_sequel.rb
sequel -m migrations/ "$1"
ruby convert_db.rb
# help from: https://stackoverflow.com/questions/65414400/need-config-ru-to-start-up-a-sinatra-app-from-within-a-docker-container
# help: https://linux.die.net/man/1/shotgun
# help: https://stackoverflow.com/questions/47025647/localhost-vs-0-0-0-0-with-docker-on-mac-os#:~:text=If%20you%20listen%20on%20localhost,can%20connect%20to%20your%20application.&text=0.0%20with%20the%20application%20you,with%20docker%20run%20%2Dp%20127.0.
shotgun -o 0.0.0.0 app.rb
