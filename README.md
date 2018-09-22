# cJSON for Clarion
[cJSON](https://github.com/DaveGamble/cJSON) is ultralightweight JSON parser in ANSI C. This repository contains cJSON port to Clarion.

## Requirements  
C6.3 and newer.

## How to install
Hit the 'Clone or Download' button and select 'Download Zip'.  
Now unzip cJSON-master.zip into a temporary folder somewhere.

Copy the contents of "libsrc" folder into %ClarionRoot%\Accessory\libsrc\win  
where %ClarionRoot% is the folder into which you installed Clarion.

## Contacts
- <mikeduglas@yandex.ru>
- <mikeduglas66@gmail.com>

## Price
Free

## Version history
v1.00 (23.09.2018)
- FIX: Parse could fail
- NEW: ToGroup method converts json object into a GROUP
- NEW: ToQueue method converts json array into a QUEUE
- NEW: ToFile method converts json array into a FILE
- NEW: Duplicate method creates a new, identical cJSON item
- NEW: json::Minify function removes whitespaces and comments
- NEW: json::Compare function compares two cJSON items
- CHG: new and modified examples

v0.99 (21.09.2018)
- FIX: array handling
- FIX: Unicode handling
- NEW: new examples

v0.98 (20.09.2018)