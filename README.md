# loopback-world
A LAMP development docker container with Apache VHost and built in *.loopback.world HTTPS cert.
 
 ## About
 
 This container image takes the jstormes/lamp image and extends it with XDebug, PHP Composer (composer), PhpUnit 
 (phpunit), Php Mess Detector (phpmd), and other CLI tools for PHP development.  It also includes the MariaDb Client.
 
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
 
 
 This will use the directory name as the part of the domain name.  So if you have a folder called ```test/public``` 
 it will be served as https://test.loopback.world.  
 
 ### Example URL to Folder routing:
 
 https://test.loopback.world  ==> test/public/index.php
 
 https://cat.loopback.world ==> cat/public/index.php
 
 https://cat.loopback.world/dog.php ==> cat/public/dog.php
 
 ### JSON logging in Apache2
 
 This Docker image logs Apache in JSON format.  This is mostly for logging to stdout/stderr in Docker hosted
 environments like AWS.  This can be an example for your production images that are hosted on AWS and where
 the logs are consumed by a JSON aware logging tool.
 
 From inside the Docker bash prompt you can query the apache json formatted logs:
 
 * Formatting a json log
     * `jq --slurp . /var/log/apache2/json.log`
 * Tailing a json log
     * `tail -f /var/log/apache2/json.log | jq`
     * `tail -f /var/log/apache2/error.log | jq`
 
 
 ## Usage Example docker-compose.yml
 
```
 version: '3'
 
 services:
   lamp_server:
     image: "jstormes/loopback-world:7"
     environment:
         TZ: America/Los_Angeles
         XDEBUG_CONFIG: remote_host=host.docker.internal remote_port=9000 remote_autostart=1
         PHP_IDE_CONFIG: serverName=host.docker.internal
         APPLICATION_ENV: "local"
     ports:
       - 443:443
       - 4000:3306
     volumes:
       - ./data:/data
       - ./:/var/www
```

* Start the Docker Container 
    * `docker-compose run --service-ports lamp_server bash`
 
 
 