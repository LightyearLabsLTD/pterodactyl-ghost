#!/bin/ash
set -e

cd /mnt/server

echo "🧹 Cleaning previous setup..."
rm -rf /home/container/ghost /mnt/server/.ghost
mkdir -p /mnt/server/.ghost /home/container
chown -R nobody: /mnt/server /home/container
chmod -R u+w /mnt/server /home/container

echo "🧰 Installing dependencies..."
apk --no-cache add sudo curl 'su-exec>=0.2'

echo "🔍 Node version check:"
node -v || echo "⚠️ Node not found in path!"

export PATH="/usr/local/bin:$PATH"

npm i --no-audit ghost-cli@latest -g

echo "📦 Preparing runtime..."
mkdir -p /.npm /.cache/yarn
chmod -R 755 /.npm /.cache/yarn
chown -R nobody: /.npm /.cache/yarn

cp -r ./temp/caddy /mnt/server/
cp ./temp/start.sh /mnt/server
curl -sSL "https://caddyserver.com/api/download?os=linux&arch=amd64&idempotency=33572405766393" -o /mnt/server/caddy-server
chmod +x /mnt/server/caddy-server /mnt/server/start.sh

ln -sf /mnt/server/.ghost /.ghost

echo "🚀 Installing Ghost..."
su -s /bin/ash nobody -c "
  export PATH='/usr/local/bin:$PATH'
  node -v
  ghost install local --no-start --no-enable --no-prompt --dir /home/container/ghost --process local
"

unlink /.ghost

mv /home/container/ghost /mnt/server

echo "✅ Ghost installation complete."
