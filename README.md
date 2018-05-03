# loopback-world
A LAMP development docker container with Apache VHost and built in *.loopback.world HTTPS cert.
 
 ## About
 
 This container image takes the jstormes/lamp image and extends it with XDebug, PHP Composer (composer), PhpUnit 
 (phpunit), Php Mess Detector (phpmd), and other CLI tools for PHP development.  It also includes the MariaDb Client.
 
 ## Usage Examples CLI
 
 To server all the folders under the current working directory to *.loopback.world:
 
 BASH:
 
 ```docker run -it -p 8080:80 -v $(pwd):/var/www jstormes/loopback-world```
 
 PowerShell
 
 ```docker run -it -p 8080:80 -v ${PWD}:/var/www jstormes/loopback-world```
 
 Windows CMD
 
 ```docker run -it -p 8080:80 -v %cd%:/var/www jstormes/loopback-world```
 
 
 This will use the directory name as the part of the domain name.  So if you have a folder called ```test/public``` 
 it will be served as http://test.loopback.world:8080.  
 
 ### Example URL to Folder mappings:
 
 http://test.loopback.world:8080/index.php  ==> test/public/index.php
 
 http://cat.loopback.world:8080/index.php ==> cat/public/index.php
 
 http://cat.loopback.world:8080/dog.php ==> cat/public/dog.php
 
 ### JSON logging in Apache2
 
 From inside the Docker bash prompt you can query the apache json formatted logs:
 
 * Formatting a json log
     * `jq --slurp . /var/log/apache2/json.log`
 * Tailing a json log
     * `tail -f /var/log/apache2/json.log | jq`
 
 
 ## Usage Example docker-compose.yml
 
 
 