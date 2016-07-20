#!/bin/bash

# Default Variables
USER="admin"
PASSWORD="admin"
HOST="http://localhost:4502"
ACTION="help"
PACKAGE=0
OUT=0
GROUP=""
NAME=""

function usage
{
	echo "usage: aem-pkmgr [list|install|download|upload|build] [-h http://localhost:4503] [-u admin1] [-p admin2] [-pk package.zip]"
}

function help
{
	usage
	echo ""
	echo "---Actions---"
	echo " list            - lists all available packages"
	echo " install         - installs a package"
	echo " upload          - uploads a package"
	echo " upload-install  - uploads and installs a package"
	echo " build           - builds a package"
	echo " download        - downloads a package"
	echo ""
	echo "---Parameters---"
	echo "-h  | --host     - Sets the AEM host, default is 'http://localhost:4502'"
	echo "-u  | --username - Sets the username to connect to AEM, default is 'admin'"
	echo "-p  | --password - Sets the password to connect to AEM, default is 'admin'"
	echo "-o  | --out      - The path to download the package"
	echo "-g  | --group    - Filter the package list by group"
	echo "-n  | --name     - Filter the package list by name"
	echo "-pk | --package  - Sets the package to install or upload"
	echo "-h  | --help     - Displays this message"
}

list ()
{
	echo "AVAILABLE PACKAGES:"
	echo ""
	ruby -ruri -rjson -rnet/http -e 'uri = URI.parse(ARGV[2]+"/crx/packmgr/list.jsp"); request = Net::HTTP::Get.new(uri); request.basic_auth(ARGV[3],ARGV[4]); response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|   http.request(request);  end;  group = ARGV[0].downcase;  name = ARGV[1].downcase;  j = JSON.parse(response.body);  j["results"].each do |package|  if (package["name"].downcase.include? name) and (package["group"].downcase.include? group) then   print package["name"]+"\n";   print "\tDescription: "+(package["description"] == nil ? "" : package["description"])+"\n";   print "\tVersion: "+(package["version"] == nil ? "" : package["version"])+"\n";   print "\tGroup: "+(package["group"] == nil ? "" : package["group"])+"\n";   print "\tPath: "+(package["path"] == nil ? "" : package["path"])+"\n\n";  end end ' "$GROUP" "$NAME" "$HOST" "$USER" "$PASSWORD"
}

install_package ()
{
	if [ "$PACKAGE" == "0" ]; then
		echo "Missing package!"
		echo "usage: aem-pkmgr install -pk [package-path]"
		exit 1
	fi
	echo "INSTALLING PACKAGE $PACKAGE..."
	encoded_package=${PACKAGE// /%20}
	curl -u $USER:$PASSWORD -X POST --fail "$HOST/crx/packmgr/service/.json$encoded_package?cmd=install"
	echo ""
}

upload_install ()
{
	if [ "$PACKAGE" == "0" ]; then
		echo "Missing package!"
		echo "usage: aem-pkmgr upload -pk [package-file]"
		exit 1
	fi
	echo "UPLOADING PACKAGE $PACKAGE..."
	curl -u $USER:$PASSWORD --fail -F file=@"$PACKAGE" -F force=true -F install=true $HOST/crx/packmgr/service.jsp
	echo ""
}

upload ()
{
	if [ "$PACKAGE" == "0" ]; then
		echo "Missing package!"
		echo "usage: aem-pkmgr upload -pk [package-file]"
		exit 1
	fi
	echo "UPLOADING PACKAGE $PACKAGE..."
	curl -u $USER:$PASSWORD --fail -F file=@"$PACKAGE" -F force=true -F install=false $HOST/crx/packmgr/service.jsp
	echo ""
}

download ()
{
	if [ "$PACKAGE" == "0" ]; then
		echo "Missing package!"
		echo "usage: aem-pkmgr download -pk [package-path]"
		exit 1
	fi
	echo "DOWNLOADING PACKAGE $PACKAGE..."
	encoded_package=${PACKAGE// /%20}
	if [ "$OUT" == "0" ]; then
		curl -u $USER:$PASSWORD -O --fail "$HOST$encoded_package"
	else
		curl -u $USER:$PASSWORD --fail "$HOST$encoded_package" > $OUT
	fi
	echo ""
}

build ()
{
	if [ "$PACKAGE" == "0" ]; then
		echo "Missing package!"
		echo "usage: aem-pkmgr build -pk [package-path]"
		exit 1
	fi
	echo "BUILDING PACKAGE $PACKAGE..."
	encoded_package=${PACKAGE// /%20}
	curl -u $USER:$PASSWORD -X POST --fail  "$HOST/crx/packmgr/service/.json$encoded_package?cmd=build"
	echo ""
}

# Parse the command line arguments from the parameters
while [ "$1" != "" ]; do
	case $1 in
		-h | --host )			shift
								HOST=$1
								;;
		-u | --username )		shift
								USER=$1
								;;
		-p | --password )		shift
								PASSWORD=$1
								;;
		-o | --out )			shift
								OUT=$1
								;;
		-pk | --package )		shift
								PACKAGE=$1
								;;
		-g | --group )			shift
								GROUP=$1
								;;
		-n | --name )			shift
								NAME=$1
								;;
		-h | --help )		    help
								exit
								;;
		build )					ACTION="build"
								;;
		list )					ACTION="list"
								;;
		"install" )				ACTION="install"
								;;
		"upload-install" )		ACTION="upload-install"
								;;
		upload )				ACTION="upload"
								;;
		download )				ACTION="download"
								;;
		* )						usage
								exit 1
	esac
	shift
done

# Perform the actions
if [ "$ACTION" = "list" ]; then
	list
elif [ "$ACTION" = "install" ] ; then
	install_package
elif [ "$ACTION" = "upload-install" ] ; then
	upload_install
elif [ "$ACTION" = "upload" ] ; then
	upload
elif [ "$ACTION" = "download" ] ; then
	download
elif [ "$ACTION" = "build" ] ; then
	build
else
	usage
fi