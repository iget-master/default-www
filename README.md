# Default WWW

This docker image is the base for any web development on iGet.

It's based on *Ubuntu 16.04 (Xenial Xerus)* and contains the following stack:

* Nginx
* PHP 7.1
* MySQL 5.7
* Memcached

In addition to default PHP extensions, the following extensions are present:

- ext-zip
- ext-curl
- ext-mysql
- ext-mbstring
- ext-memcached
- ext-tidy

The `nginx` is configured to serve `/var/www` on port 80 in this order of priority:

- public/index.html
- public/index.htm
- public/index.php
- index.html
- index.htm
- index.php

This allow compatibility with Laravel applications, since index isn't on root.
