# Terminal session bootstrap

A simple executable to bootstrap your Linux Terminal session.

## Why?

Because a lot of Linux tools need to be configured by setting the `PATH` variable or by setting a proxy or by executing an initialization process when a new Terminal session is opening (e.g. [jenv](http://www.jenv.be/) or [rbenv](https://github.com/rbenv/rbenv))... and so on.  

## How does it works?

This project is composed of two parts:
- The `session-bootstrap.sh` file
- The `session-bootstrap/` directory

The `session-bootstrap.sh` file execute any files from its associated `session-bootstrap/` directory. Any `session-bootstrap/`'s file execution is done within the current terminal session.  

In addition, `session-bootstrap/`'s file iteration is done in the lexicographical order, letting `session-bootstrap/`'s files execution to be sorted.

## How to use it?

### Install it

```bash
$ curl -o $HOME/.session-bootstrap.sh https://raw.githubusercontent.com/abourdon/terminal-session-bootstrap/master/session-bootstrap.sh
$ mkdir -p $HOME/.session-bootstrap
```

### Boostrap it

Now we want to execute the `session-bootstrap.sh` at any Terminal session opening. Depending on your Shell, this installation can be done differently.

#### Bash

```bash
$ echo 'source $HOME/.session-bootstrap.sh' >> $HOME/.bashrc
```

#### Zsh

```bash
$ echo 'source $HOME/.session-bootstrap.sh' >> $HOME/.zshrc
```

## How to add a bootstrap script?

Any file in the `session-bootstrap/` directory will be executed during the Terminal session opening. Thus, to add a bootstrap script at the Terminal session opening, simply place it to the `session-bootstrap/` directory.  

Some examples of `session-bootstrap`'s files can be found [here](session-bootstrap/).