## docker

### Run a container

```bash

docker run -p 5000:80 --name myfirstcontainer -d nginx

```

Since *nginx* is a webserver you can access the default web page on your localhost port 5000 now

```bash

curl localhost:5000

```

[Back to top](#docker)

Let's execute a command in the newly created container / mini-vm

```bash

docker exec -it myfirstcontainer ls -l

```

We can also take control of a *bash* session

```bash

docker exec -it myfirstcontainer bash


```

[Back to top](#docker)

Let's find all the .html files in the file system to see where the *nginx* web server's default path is

```bash

find / -type f -name *.html 2>/dev/null

```

As you can see it is in the **/usr/share/nginx/html** folder
Go there and change the default *html* page to something else

```bash

cd /usr/share/nginx/html
echo '<html><body><h1>Hello students</h1></body></html>' > index.html


exit

```

[Back to top](#docker)

Now try to call the *localhost:5000* again

You should see the new html appear

You might even be able to browse this page from a browser in your windows environment

If your *Linux* environment does not forward to your localhost in your Windows env. You can try the following

- In Linux get all the eth0 ip address 

```bash

hostname -I

```
It's usually the first ip address to appear

try that ip address with the port 5000 in your browser  (like 172.30.211.202:5000)

[Back to top](#docker)

