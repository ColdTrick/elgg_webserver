Elgg webserver
==============

This Docker image provides a basic Apache webserver with PHP and all the modules required to run Elgg

Versioning
----------

The Docker images will be tagged based on the installed PHP version

- `7`: the latest available PHP 7 version
- `7.x`: the latest available PHP 7.x version
- `7.x.y`: the PHP 7.x.y version

PHP Hardening
-------------

PHP is hardened based on [OWASP][1] recommendations

[1]: https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/PHP_Configuration_Cheat_Sheet.md