# STRIDR

Setting up development workspace:

## Start Redis
1. redis-server (any path)

## Start side job workers
2. bundle exec sidekiq (project path)

## Create introspective tunnel for remote access (optional - requires Pro account)
3. ngrok tls -hostname=development.stridr.social 3000 (any path)

## Start Rails server
Using a self-signed SSL certificate, otherwise, `rails s`
4. rails s puma -b 'ssl://127.0.0.1:3000?key=.ssh/server.key&cert=.ssh/server.crt' (project path)

