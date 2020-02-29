<div>
    <h1 align="center">Pebbles</h1>
    <h3 align="center">An easy to use yet powerful calculator app</h3>
</div>

![screenshot](screenshots/Screenshot.png)

<br>
Pebbles is an advanced calculator application based in Vala and Gtk.

## Get it on elementary OS Appcenter
[![Get it on AppCenter](https://appcenter.elementary.io/com.github.subhadeepjasu.pebbles)

## Install from source
You can install Pebbles by compiling it from source, here's a list of required dependencies:
 - `gtk+-3.0>=3.18`
 - `granite>=5.3.0`
 - `gsl>=2.4`
 - `glib-2.0`
 - `gobject-2.0`
 - `meson`

<i>For non-elementary distros, (such as Arch, Debian, etc) you are required to install "vala" as additional dependency.</i>

Clone repository and change directory
```
git clone https://github.com/SubhadeepJasu/pebbles.git
cd pebbles
```

Compile, install and start Pebbles on your system
```
meson build --prefix=/usr
cd build
sudo ninja install
com.github.subhadeepjasu.pebbles
```

To run pebbles in testing mode
```
com.github.subhadeepjasu.pebbles --test
```

<sup>**License**: GNU GPLv3</sup>
