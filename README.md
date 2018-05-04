# Terminal session bootstrap

A simple executable to bootstrap your Linux Terminal session.

![demo.gif](./resources/demo.gif)

## Why?

Because we all have our own way of managing our Terminal session opening by:
- Setting the `PATH` variable
- Setting the proxy
- Adding aliases
- Applying a mandatory initialization process for a particular command line (e.g. for [jenv](http://www.jenv.be/), [nvm](https://github.com/creationix/nvm) or [rbenv](https://github.com/rbenv/rbenv))
- Managing several "Terminal session profiles"
- ... and so on

## How?

Terminal session bootstrap is done by using:
- The `session-bootstrap.sh` file
- The `session-bootstrap/` directory

Any `session-bootstrap/`'s files are then executed by the `session-bootstrap.sh` within the current Terminal session.

### Available features

- Bootstrap the Terminal session
- Apply the lexicographically order when discovering bootstrap script files
- Define the bootstrap script directory to use to manage several "Terminal session profiles"  

### Installation

```bash
$ curl -o $HOME/.session-bootstrap.sh https://raw.githubusercontent.com/abourdon/terminal-session-bootstrap/master/session-bootstrap.sh
$ mkdir -p $HOME/.session-bootstrap
```

Now we want to execute the `session-bootstrap.sh` at any Terminal session opening. Depending on your Shell, this installation can be done differently.

#### Bash

```bash
$ echo 'source $HOME/.session-bootstrap.sh' >> $HOME/.bashrc
```

#### Zsh

```bash
$ echo 'source $HOME/.session-bootstrap.sh' >> $HOME/.zshrc
```

### Need help?

```bash
$ ./session-bootstrap.sh --help
```

## How to add a bootstrap script?

Any file in the `session-bootstrap/` directory will be executed during the Terminal session opening. Thus, to add a bootstrap script at the Terminal session opening, simply place it to the `session-bootstrap/` directory.  

Some examples of `session-bootstrap`'s files can be found [here](session-bootstrap/).