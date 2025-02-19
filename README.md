<div>
    <h1 align="center">Pebbles</h1>
    <h3 align="center">An easy to use yet powerful calculator app</h3>
</div>

![screenshot](screenshots/Screenshot.png)

<br>
Pebbles is an easy to use advanced calculator.
<br><br>
<a href="https://elementary.io"><img alt="Static Badge" src="data/badges/made_for_elementary_os_badge.svg"></a>

## Get it from store
| elementary OS    | FlatHub       	|
|------------------|---------------	|
|[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.subhadeepjasu.pebbles)|<a href="https://flathub.org/apps/details/com.github.subhadeepjasu.pebbles"><img src="https://flathub.org/assets/badges/flathub-badge-i-en.svg" width="160px" alt="Get it from Flathub!"></a>|

## Install from source using meson
You can install Pebbles by compiling it from source, here's a list of required dependencies:
 - `elementary-sdk 8`
 - `gtk 4`
 - `granite 7`
 - `glib-2.0`
 - `libsoup-2.4`
 - `gobject-2.0`
 - `libadwaita 1`
 - `meson`

<i>For non-elementary distros, (such as Arch, Debian, etc) you are required to install "vala" as additional dependency.</i>

Clone repository and change directory
```
git clone https://github.com/SubhadeepJasu/pebbles.git
cd pebbles
```

Compile, install and start Pebbles on your system
```
meson setup build --prefix=/usr
ninja -C build install
com.github.subhadeepjasu.pebbles
```
To run pebbles in testing mode
```
com.github.subhadeepjasu.pebbles --test
```

## Install from source using flatpak
```
flatpak-builder build  com.github.subhadeepjasu.pebbles.yml --user --install --force-clean
flatpak run com.github.subhadeepjasu.pebbles
```
To run pebbles in testing mode
```
flatpak run com.github.subhadeepjasu.pebbles --test
```


## Discussions
If you want to ask any questions or provide feedback, you can make issues in this repository

## Contributing
Feel free to send pull requests to this repository with your code.


<br>
<sup><b>License</b>: GNU GPLv3</sup>
<br>
<sup>© Copyright 2017-2024 Subhadeep Jasu</sup>
