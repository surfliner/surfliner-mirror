#!/usr/bin/env sh

publicowner=$(stat -c '%u' public)
if [ "$publicowner" = "101" ]; then
  tmpowner=$(stat -c '%u' tmp)
  if [ "$tmpowner" = "101" ]; then
    exit 1;
  fi
fi

echo "In order for the rails app pods to access local volumes, the"
echo "permissions on the comet/public and comet/tmp directories"
echo "need to be set with the following commands:"
echo ""
echo "chown -R 1001:101 public"
echo "chown -R 1001:101 tmp"
echo "chown -R 1001:101 db/schema.rb"
echo "chown -R 1001:101 Gemfile.lock"
echo ""
echo "This will require the sudo or administrator password.  If you"
echo "answer 'y' to the prompt, you will be asked for that password"
echo "and this script will set the permissions for you, or you can"
echo "answer 'n', copy the above commands, and run them yourself."
echo "Currently, the development environment will NOT work if those"
echo "permissions are not set correctly."

echo "Would you like me to set the permissions? (y/n):"
read -r yn;
echo ""

if [ "$yn" = "Y" ] || [ "$yn" = "y" ]
then
    echo "Setting permissions..."
    sudo chown -R 1001:101 public
    sudo chown -R 1001:101 tmp
    sudo chown -R 1001:101 db/schema.rb
    sudo chown -R 1001:101 Gemfile.lock
    sudo -k
else
    echo "Again, the development environment will NOT work unless"
    echo "these permissions are set:"
    echo ""
    echo "chown -R 1001:101 public"
    echo "chown -R 1001:101 tmp"
    echo "chown -R 1001:101 db/schema.rb"
    echo "chown -R 1001:101 Gemfile.lock"
    echo ""
fi
