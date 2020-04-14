#!/usr/bin/env bash
set -e

bin_path=$HOME/bin
lib_path=$HOME/lib

get_releases() {
  curl --silent "https://api.github.com/repos/cdr/code-server/releases/latest" |
    grep '"browser_download_url":\|"tag_name":'
}

releases=$(get_releases)
package=$(echo "$releases" | grep 'linux' | grep 'x86' | sed -E 's/.*"([^"]+)".*/\1/')
version=$(echo $releases | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

echo $version
echo $package

temp_path=/tmp/code-server-$version

if [ -d $temp_path ]; then
  rm -rf $temp_path
fi

mkdir $temp_path
cd $temp_path

echo "-- Downloading code-server v$version"
wget $package > /dev/null

echo "-- Unpacking code-server release"
tar -xzf code-server*.tar.gz > /dev/null
rm code-server*.tar.gz

if [ -d $lib_path/code-server ]; then
  backup=$lib_path/BACKUP_$(date +%s)_code-server/
  mv -f $lib_path/code-server/ $backup
  echo "-- INFO: old code-server directory moved to $backup"
fi

mkdir -p $lib_path/code-server

mv -f code-server*/* $lib_path/code-server/

if [ -d $bin_path/code-server ]; then
  rm $bin_path/code-server
fi

mkdir -p $bin_path
ln -f -s $lib_path/code-server/code-server $bin_path/code-server

rm -rf -f $temp_path

echo "-- Successfully installed code-server at $bin_path/code-server"
echo "-- Ensure that $bin_path is present in your \$PATH"
