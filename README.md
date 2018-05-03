# Terminal session startup

A simple executable to startup your Linux Terminal session.

## Why?

Because a lot of Linux tools need to be configured by setting the `PATH` variable or by executing an initialization process at any Terminal login session (e.g. [jenv](http://www.jenv.be/) or [rbenv](https://github.com/rbenv/rbenv)).    

## How does it works?

This project is composed of two parts:
- The `session-startup.sh` file
- The `session-startup/` directory

The `session-startup.sh` file execute any files from its associated `session-startup/` directory. Any `session-startup/`'s file execution is done within the current terminal session.  

In addition, `session-startup/`'s file iteration is done in the lexicographical order, letting `session-startup/`'s files executions to be sorted.

## How to use it?

### Install it

```bash
$ curl -o $HOME/.session-startup.sh https://raw.githubusercontent.com/abourdon/terminal-session-startup/master/session-startup.sh
$ mkdir -p $HOME/.session-startup
```

### Boostrap it

Now we want to execute the `session-startup.sh` at any Terminal login. Depending on your Shell, this installation can be done differently.

#### Bash

```bash
$ echo 'source $HOME/.session-startup.sh' >> $HOME/.bash_login
```

#### Zsh

```bash
$ echo 'source $HOME/.session-startup.sh' >> $HOME/.zlogin
```

## How to add a startup script?

Any file in the `session-startup/` directory will be executed during the Terminal session login. Thus, to add a startup script at the Terminal login, simply place it to the `session-startup/` directory.  

Some examples of `session-startup`'s files can be found [here](./session-startup/).