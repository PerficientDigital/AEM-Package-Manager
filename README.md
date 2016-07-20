# AEM-Package-Manager

A tool for installing [AEM packages](https://docs.adobe.com/docs/en/aem/6-0/administer/content/package-manager.html) from the command line. Compatible with:

 * OSX
 * Ubuntu Linux
 * Windows via cygwin

Requires:

* [Ruby](https://www.ruby-lang.org/en/downloads/)

## Installation

Download the script, make it executable and put it into the path on your computer.

## Usage

`aem-pkmgr [list|install|download|upload|build] [-h http://localhost:4503] [-u admin1] [-p admin2] [-pk package.zip]`

### Actions

 * list            - lists all available packages
 * install         - installs a package
 * upload          - uploads a package
 * build           - builds a package
 * download        - downloads a package

### Parameters

 * -h  | --host     - Sets the AEM host, default is 'http://localhost:4502'
 * -u  | --username - Sets the username to connect to AEM, default is 'admin'
 * -p  | --password - Sets the password to connect to AEM, default is 'admin'
 * -o  | --out      - The path to download the package
 * -g  | --group    - Filter the package list by group
 * -n  | --name     - Filter the package list by name
 * -pk | --package  - Sets the package to install or upload
 * -h  | --help     - Displays this message
