[root@sandhya tmp]# cat finish.sh
#!/bin/bash

############################################################
### This is a benchmark script as per CIS                ###
###This is applicable for apache 2.2.This Can be modified###
### as required                                          ###
###                                                      ###
############################################################
#Take the backup of existing conf file
timestamp=`date +"%Y%m%d_%H%M%S"`
echo "Taking backup of Existing httpd.conf..."
read -p "Enter document root directory for your webserver : " ROOT
cd $ROOT/conf
mv httpd.conf  httpd.conf_$timestamp
echo "Existing httpd.conf backup has been taken..."

echo "****************************************"
##Creating Pre-requisite, please make sure you have permission to create directory inside /var/opt; else take Server admin team help to create for you .
## Here we have used /var/opt/apache22/ has been used to store dump and logs file for apache 2.2

echo "Creating Pre-requisite, please make sure you have permission to create directory inside /var/opt; else take Server admin team help to create for you"
echo "**************************************************"
echo "/var/opt/apache22/  Directory has been used to store dump and logs file for apache 2.2"

mkdir -p /var/opt/apache22
chown -R apache:apache /var/opt/apache22; chmod -R 775 /var/opt/apache22
mkdir -p /var/opt/apache22/corefiles
mkdir -p /var/opt/apache22/logs
mkdir -p $ROOT/run/
read -p "Enter instance name : " INSTANCE_NAME
touch $ROOT/run/$INSTANCE_NAME.pid
chown apache:apache $ROOT/run/$INSTANCE_NAME.pid

echo "###################creating httpd.conf containg all security fixes########"
echo "ServerRoot "\"$ROOT"\"" >> httpd.conf
echo "PidFile $ROOT/run/$INSTANCE_NAME.pid" >> httpd.conf
read -p "Enter the port number which has to be listen : " PORT1
echo "Listen $PORT1" >> httpd.conf
######This is the most consistent measured value and should be considered baseline,
####however this value may need adjustment based on site requirements. Deviations from this value require an exception
echo "Adding Baseline values..."
sleep 5;
echo -e "Timeout 300

KeepAlive On

MaxKeepAliveRequests 100

KeepAliveTimeout 15

LimitRequestFieldSize 20480

ServerTokens Prod

ServerSignature Off

CoreDumpDirectory "/var/opt/apache22/corefiles"

<IfModule worker.c>
  ThreadLimit           1000
  ServerLimit           1
  StartServers          1
  MaxClients            1000
  MinSpareThreads       1
  MaxSpareThreads       1000
  ThreadsPerChild       1000
  MaxRequestsPerChild   0
</IfModule>


LoadModule      env_module              modules/mod_env.so
LoadModule      log_config_module       modules/mod_log_config.so
LoadModule      mime_magic_module       modules/mod_mime_magic.so
LoadModule      mime_module             modules/mod_mime.so
LoadModule      negotiation_module      modules/mod_negotiation.so
LoadModule      status_module           modules/mod_status.so
LoadModule      include_module          modules/mod_include.so
#LoadModule      autoindex_module        modules/mod_autoindex.so
#The autoindex module must either be excluded from the build or pounded out.
LoadModule      dir_module              modules/mod_dir.so
#LoadModule      info_module             modules/mod_info.so
#The info module must either be excluded from the build or pounded out.
LoadModule      asis_module             modules/mod_asis.so
LoadModule      actions_module          modules/mod_actions.so
LoadModule      alias_module            modules/mod_alias.so
LoadModule      rewrite_module          modules/mod_rewrite.so
LoadModule      authz_host_module       modules/mod_authz_host.so
LoadModule      proxy_module            modules/mod_proxy.so
LoadModule      proxy_http_module       modules/mod_proxy_http.so
LoadModule      expires_module          modules/mod_expires.so
LoadModule      deflate_module          modules/mod_deflate.so

#######################################################################
### Section 2: 'Main' server configuration
#######################################################################
#
# The directives in this section set up the values used by the 'main'
# server, which responds to any requests that aren't handled by a
# <VirtualHost> definition.  These values also provide defaults for
# any <VirtualHost> containers you may define later in the file.
#
# All of these directives may appear inside <VirtualHost> containers,
# in which case these default settings will be overridden for the
# virtual host being defined.
#######################################################################

User apache

Group apache

ServerAdmin WebEngineering@MassMutual.com

#
# UseCanonicalName: Determines how Apache constructs self-referencing
# URLs and the SERVER_NAME and SERVER_PORT variables.
# When set "Off", Apache will use the Hostname and Port supplied
# by the client.  When set "On", Apache will use the value of the
# ServerName directive.
#
UseCanonicalName Off" >> httpd.conf

echo "Configuring Instances as per standard ...."
read -p "Enter HOST NAME your webserver : " SERVER_NAME
echo "ServerName $SERVER_NAME.private.massmutual.com" >> httpd.conf
echo -e "<Directory />
    Options None
    AllowOverride None
    Order deny,allow
    Deny from all
</Directory>" >> httpd.conf
echo "Adding document root . Example you can configure document root like /var/www/html .Please dont use like /var/www/html/ "
echo "************************************************"
read -p "Enter Document root path for your webserver : " DOCUMENT_ROOT
echo "Adding server directory for your webserver.Example you can use server dierctory /var/www .Please dont use like /var/www/ "
echo "************************************************"
read -p "Enter Server directory your webserver : " SERVER_DIRECTORY
echo "DocumentRoot \"$DOCUMENT_ROOT/http\"" >> httpd.conf
echo "<Directory \"$SERVER_DIRECTORY/\">" >> httpd.conf
echo -e "    Options None
    Options +Includes
# This controls which options the .htaccess files in directories can
# override. Can also be "All", or any combination of "Options", "FileInfo",
# "AuthConfig", and "Limit"
    AllowOverride
# Controls who can get stuff from this server.
    Order deny,allow
    Allow from all
</Directory>

<IfModule mod_dir.c>
# The index.html.var file (a type-map) is used to deliver content-
# negotiated documents.  The MultiViews Option can be used for the
# same purpose, but it is much slower.

DirectoryIndex index.html index.htm index.shtml index.html.var /index.html /index.htm /index.shtml

</IfModule>

#
# AccessFileName: The name of the file to look for in each directory
# for additional configuration directives.  See also the AllowOverride
# directive.
#
AccessFileName .htaccess

#
# The following lines prevent .htaccess and .htpasswd files from being
# viewed by Web clients.
#
<Files ~ "^\.ht">
    Order allow,deny
    Deny from all
</Files>

TypesConfig conf/mime.types

DefaultType text/plain

#
# The mod_mime_magic module allows the server to use various hints from the
# contents of the file itself to determine its type.  The MIMEMagicFile
# directive tells the module where the hint definitions are located.
#
<IfModule mod_mime_magic.c>
    MIMEMagicFile conf/magic
</IfModule>

HostnameLookups Off


LogLevel info" >> httpd.conf
echo "creating Logformat samples..."
echo "*******"
sleep 2;
echo -e 'LogFormat "%h %l %u %t \"%r\" %>s %b" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{Cookie}n\"" combined' >> /etc/httpd.conf

echo "                                 " >> httpd.conf

echo " Configuring Access logs and error log files .... "
echo "                                 " >> httpd.conf

echo "CustomLog "/var/opt/apache22/logs/instance.$INSTANCE_NAME.$PORT1.access.$SERVER_NAME.log"" >> httpd.conf
echo "ErrorLog "/var/opt/apache22/logs/instance.$INSTANCE_NAME.$PORT1.$SERVER_NAME.log"">> httpd.conf
echo "                                 " >> httpd.conf
echo -e "# EnableMMAP: Control whether memory-mapping is used to deliver
# files (assuming that the underlying OS supports it).
# The default is on; turn this off if you serve from NFS-mounted
# filesystems.  On some systems, turning it off (regardless of
# filesystem) can improve performance; for details, please see
# http://httpd.apache.org/docs-2.0/mod/core.html#enablemmap
#
EnableMMAP off

#
# EnableSendfile: Control whether the sendfile kernel support is
# used  to deliver files (assuming that the OS supports it).
# The default is on; turn this off if you serve from NFS-mounted
# filesystems.  Please see
# http://httpd.apache.org/docs-2.0/mod/core.html#enablesendfile
#
EnableSendfile off

<IfModule mod_alias.c>" >> httpd.conf

echo "Alias /icons/ "\"$ROOT/icons/"\"" >> httpd.conf
echo "<Directory "\"$ROOT/icons/"\">" >> httpd.conf


echo -e "    Options Indexes MultiViews
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>

#
# This should be changed to the ServerRoot/manual/.  The alias provides
# the manual, even if you choose to move your DocumentRoot.  You may comment
# this out if you do not care for the documentation.
#" >> httpd.conf

echo "Configuring Language settings...."
sleep 2;
echo "AliasMatch "\"^/manual"\"(?:/(?:de|en|es|fr|ja|ko|ru))?(/.*)?$"\""$ROOT/manual$1"\" >> httpd.conf
echo "<Directory "\"$ROOT/manual"\">" >> httpd.conf
echo -e "    Options Indexes
    AllowOverride None
    Order allow,deny
    Allow from all

    <Files *.html>
        SetHandler type-map
    </Files>

    SetEnvIf Request_URI ^/manual/(de|en|es|fr|ja|ko|ru)/ prefer-language=$1
    RedirectMatch 301 ^/manual(?:/(de|en|es|fr|ja|ko|ru)){2,}(/.*)?$ /manual/$1$2
</Directory>" >> httpd.conf

echo "ScriptAlias /cgi-bin/ "\"$ROOT/cgi-bin/"\"">> httpd.conf
echo -e "<IfModule mod_cgid.c>

</IfModule>" >> httpd.conf
echo "<Directory "\"$ROOT/cgi-bin/"\">" >> httpd.conf
echo -e "    AllowOverride None
    Options None
    Order allow,deny
    Allow from all
</Directory>

<IfModule mod_autoindex.c>

IndexOptions FancyIndexing VersionSort


AddIconByEncoding (CMP,/icons/compressed.gif) x-compress x-gzip

AddIconByType (TXT,/icons/text.gif) text/*
AddIconByType (IMG,/icons/image2.gif) image/*
AddIconByType (SND,/icons/sound2.gif) audio/*
AddIconByType (VID,/icons/movie.gif) video/*

AddIcon /icons/binary.gif .bin .exe
AddIcon /icons/binhex.gif .hqx
AddIcon /icons/tar.gif .tar
AddIcon /icons/world2.gif .wrl .wrl.gz .vrml .vrm .iv
AddIcon /icons/compressed.gif .Z .z .tgz .gz .zip
AddIcon /icons/a.gif .ps .ai .eps
AddIcon /icons/layout.gif .html .shtml .htm .pdf
AddIcon /icons/text.gif .txt
AddIcon /icons/c.gif .c
AddIcon /icons/p.gif .pl .py
AddIcon /icons/f.gif .for
AddIcon /icons/dvi.gif .dvi
AddIcon /icons/uuencoded.gif .uu
AddIcon /icons/script.gif .conf .sh .shar .csh .ksh .tcl
AddIcon /icons/tex.gif .tex
AddIcon /icons/bomb.gif core
AddIcon /icons/back.gif ..
AddIcon /icons/hand.right.gif README
AddIcon /icons/folder.gif ^^DIRECTORY^^
AddIcon /icons/blank.gif ^^BLANKICON^^


DefaultIcon /icons/unknown.gif


AddDescription "GZIP compressed document" .gz
AddDescription "tar archive" .tar
AddDescription "GZIP compressed tar archive" .tgz


ReadmeName README.html
HeaderName HEADER.html


IndexIgnore .??* *~ *# HEADER* README* RCS CVS *,v *,t
</IfModule>


AddLanguage ca .ca
AddLanguage cs .cz .cs
AddLanguage da .dk
AddLanguage de .de
AddLanguage el .el
AddLanguage en .en
AddLanguage eo .eo
AddLanguage es .es
AddLanguage et .et
AddLanguage fr .fr
AddLanguage he .he
AddLanguage hr .hr
AddLanguage it .it
AddLanguage ja .ja
AddLanguage ko .ko
AddLanguage ltz .ltz
AddLanguage nl .nl
AddLanguage nn .nn
AddLanguage no .no
AddLanguage pl .po
AddLanguage pt .pt
AddLanguage pt-BR .pt-br
AddLanguage ru .ru
AddLanguage sv .sv
AddLanguage zh-CN .zh-cn
AddLanguage zh-TW .zh-tw


LanguagePriority en ca cs da de el eo es et fr he hr it ja ko ltz nl nn no pl pt pt-BR ru sv zh-CN zh-TW


ForceLanguagePriority Prefer Fallback


AddCharset ISO-8859-1  .iso8859-1  .latin1
AddCharset ISO-8859-2  .iso8859-2  .latin2 .cen
AddCharset ISO-8859-3  .iso8859-3  .latin3
AddCharset ISO-8859-4  .iso8859-4  .latin4
AddCharset ISO-8859-5  .iso8859-5  .latin5 .cyr .iso-ru
AddCharset ISO-8859-6  .iso8859-6  .latin6 .arb
AddCharset ISO-8859-7  .iso8859-7  .latin7 .grk
AddCharset ISO-8859-8  .iso8859-8  .latin8 .heb
AddCharset ISO-8859-9  .iso8859-9  .latin9 .trk
AddCharset ISO-2022-JP .iso2022-jp .jis
AddCharset ISO-2022-KR .iso2022-kr .kis
AddCharset ISO-2022-CN .iso2022-cn .cis
AddCharset Big5        .Big5       .big5
# For russian, more than one charset is used (depends on client, mostly):
AddCharset WINDOWS-1251 .cp-1251   .win-1251
AddCharset CP866       .cp866
AddCharset KOI8-r      .koi8-r .koi8-ru
AddCharset KOI8-ru     .koi8-uk .ua
AddCharset ISO-10646-UCS-2 .ucs2
AddCharset ISO-10646-UCS-4 .ucs4
AddCharset UTF-8       .utf8


AddCharset GB2312      .gb2312 .gb
AddCharset utf-7       .utf7
AddCharset utf-8       .utf8
AddCharset big5        .big5 .b5
AddCharset EUC-TW      .euc-tw
AddCharset EUC-JP      .euc-jp
AddCharset EUC-KR      .euc-kr
AddCharset shift_jis   .sjis

<IfModule mod_mime.c>

AddEncoding x-compress .Z
AddEncoding x-gzip .gz .tgz

AddHandler type-map var


</IfModule>

<IfModule mod_setenvif.c>
#
# The following directives modify normal HTTP response behavior to
# handle known problems with browser implementations.
#"  >> httpd.conf
echo "Configuring HTTP response behavior to handle known problems with browser implementations."

echo -e 'BrowserMatch "Mozilla/2" nokeepalive
BrowserMatch "MSIE 4\.0b2;" nokeepalive downgrade-1.0 force-response-1.0
BrowserMatch "RealPlayer 4\.0" force-response-1.0
BrowserMatch "Java/1\.0" force-response-1.0
BrowserMatch "JDK/1\.0" force-response-1.0
BrowserMatch "Microsoft Data Access Internet Publishing Provider" redirect-carefully
BrowserMatch "MS FrontPage" redirect-carefully
BrowserMatch "^WebDrive" redirect-carefully
BrowserMatch "^WebDAVFS/1.[0123]" redirect-carefully
BrowserMatch "^gnome-vfs" redirect-carefully
BrowserMatch "^XML Spy" redirect-carefully
BrowserMatch "^Dreamweaver-WebDAV-SCM1" redirect-carefully
 </IfModule>' >> httpd.conf
echo "Configured Apache 2.2 as per standard baseline"
echo "Lets test the configuration file"
STATUS=`httpd -t`
if [ "$STATUS" == "Syntax OK" ]
then
    echo "The configuration Looks Good.. Congratulations you have completed your task "
else

echo "Please Fix Error....."

fi
