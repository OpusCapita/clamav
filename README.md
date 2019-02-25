# clamav

Offers a REST API to scan files for viruses.

## structure

The container runs 3 different services:

### clamd

An open source virus scanner.
Borrowed from https://github.com/mko-x/docker-clamav
A daemon with text based protocol that allows virius scans, see also
https://www.clamav.net/

### freshclam

Update program for clamd.
This will check the online virus database on intervals and will update the local db used by clamd.

### clamav-rest

Simple REST wrapper for the virus scan api.
https://github.com/solita/clamav-rest

## health checks

The docker health check makes sure
* clamd is running
* freshclam updater is running and last update is less than 4 hours ago 
(this is done by touching a updated.txt file from the updater and checking the timestamp of that file in health check)
* REST api is up and connected to clamd

THe consul health check will only check REST api up and connected, so consul wouldnt know in case updater died.
However, swarm would restart the instance once docker check fails.

## API

```
curl -F "name=blabla" -F "file=@./eicar.txt" clamav:3036/scan
Everything ok : false
```
