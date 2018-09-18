

# loopback-world
A LAMP development docker container with Apache VHost and built in *.loopback.world HTTPS cert.

[![dockeri.co](http://dockeri.co/image/jstormes/loopback-world)](https://hub.docker.com/r/jstormes/loopback-world/)
 
## About
 
 This container image takes the jstormes/lamp image and extends it with XDebug, PHP Composer (composer), PhpUnit 
 (phpunit), Php Mess Detector (phpmd), and other CLI tools for PHP development.  It also includes the MariaDb Client.

## Quick start

Install Docker CE.

Clone this project.

Windows `.\run.ps1`

MAC/Linux `./run.sh`

Open your browser to https:\\info.loopback.world

Use git submodules to pull your code into the project.

## Built in Tools

MySQL - https:\\sql.loopback.world

Redis - https:\\redis.loopback.world

LDAP = https:\\ldap.loopback.world
 
## Usage Examples CLI
 
 To serve all the folders under the current working directory to *.loopback.world:
 
 BASH
 
```
cd (Path to project)
docker run -it -p 443:443 -v $(pwd):/var/www jstormes/loopback-world
```
 
 PowerShell
 
```
cd (Path to project)
docker run -it -p 443:443 -v ${PWD}:/var/www jstormes/loopback-world
```
 
 Windows CMD
 
```
cd (Path to project)
docker run -it -p 443:443 -v %cd%:/var/www jstormes/loopback-world
```
 
 
 This will use the directory name as the part of the domain name.  So if you have a folder called ```info/public``` 
 it will be served as https://info.loopback.world.  
 
### Example URL to Folder routing:
 
 https://test.loopback.world  ==> test/public/index.php
 
 https://cat.loopback.world ==> cat/public/index.php
 
 https://cat.loopback.world/dog.php ==> cat/public/dog.php
 
 
## Usage Example docker-compose.yml
 
```
 version: '3'
 
 services:
   lamp_server:
     image: "jstormes/loopback-world"
     environment:
         TZ: America/Los_Angeles
         XDEBUG_CONFIG: remote_host=host.docker.internal remote_port=9000 remote_autostart=1
         PHP_IDE_CONFIG: serverName=host.docker.internal
     ports:
       - 443:443
       - 4000:3306
       - 80:80
     volumes:
       - ./:/var/www
```

* Start the Docker Container 
    * `docker-compose run --service-ports lamp_server bash`
 
 
 