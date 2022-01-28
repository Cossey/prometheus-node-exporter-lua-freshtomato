# Node Exporter for FreshTomato

This is a tweaked version of openWRTs `prometheus-node-exporter-lua` designed for FreshTomato devices.
Only the `prometheus-collectors` that were specific to openWRT have been removed.
I have added a temperature collector to return the device and wireless temperatures.
You could probably add more collectors to display wireless metrics.

**NOTE: This has only been tested on a Linksys EA6700 device.**

## Usage

You need to setup and [install Entware](https://wiki.freshtomato.org/doku.php/entware_installation_usage) on your FreshTomato router.

Then install the required packages:

```sh
opkg install lua luac luasocket
```

The sub directories in the `files` folder will then need to be copied over to your router, into the Entware folder `/opt`.

To execute node exporter until restart run:

```sh
/opt/bin/lua /opt/bin/prometheus-node-exporter-lua --bind 192.168.1.254 --port 9100 &
```

FreshTomato does not have a service manager.
If you want to execute node exporter on router boot you will need to use an `.automount` file placed in the `/opt` folder.

Example `/opt/exporter.autorun`:

```sh
#!/bin/sh

sleep 5
/opt/bin/lua /opt/bin/prometheus-node-exporter-lua --bind 192.168.1.254 --port 9100 &
```

> Depending on the router, when `.automount` executes it does not guarantee that the device is ready so you should include a short sleep before executing node exporter.
