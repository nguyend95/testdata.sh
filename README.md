# testdata.sh
Bash script for testing differences between C program reference outputs and your own programs' outputs for PA1 course at FIT CTU.


## How to use
To use this script, you just have to clone this repo:

```bash
git clone https://github.com/jayjay221/testdata.sh
```

Then run `testdata.sh` in the directory.

You can run the script without arguments - it will look for compiled source "a.out" and archive with reference outputs "sample.tgz" in current directory.

Paths to compiled source and archive can be added as arguments.

```bash
./tesdata.sh path_to_executable path_to_tar.gz
```

If you are too lazy to move the script to every directory you are debugging your program in, consider creating a symlink.

Run this code from the cloned directory.

```bash
sudo ln -s /usr/bin/testdata tesdata.sh
```

Then you can run the script the same way you would run installed programs from any directory.

```bash
testdata path_to_executable path_to_tar.gz
```

## Screenshots

![screenshot1](https://github.com/jayjay221/testdata.sh/blob/master/screenshot1.png?raw=true)
![screenshot2](https://github.com/jayjay221/testdata.sh/blob/master/screenshot2.png?raw=true)
