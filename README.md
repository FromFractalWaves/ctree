# CTree

CTree is a CLI tool designed to keep modular codebases manageable, especially when working with AI-assisted development. It allows you to extract relevant portions of code efficiently while maintaining the modular structure of your project.

I built CTree using **o1-mini** to push beyond my current skill level, leveraging modular development to scale effectively.

## Installation

To install CTree, run the following commands:

```sh
sudo cp ctree.sh /usr/local/bin/ctree
sudo chmod +x /usr/local/bin/ctree
```

## Setup

To get started, configure the following files:

```sh
# Create the configuration files if they don’t exist
touch ~/.ctreeconf ~/.ctreeignore
```

Alternatively, you can copy an existing `.gitignore` file as a starting point:

```sh
cp .gitignore ~/.ctreeignore
```

### Configuration: `~/.ctreeconf`

CTree uses a configuration file to map numeric flags to file extensions for selective extraction. Example:

```ini
[flags]
1 = py
2 = tsx, jsx
3 = js, css
4 = json, ts
5 = json
6 = txt, md
7 = py, md, txt
8 = py
9 = tsx, ts, json, prisma
10 = java
```

### Ignore Rules: `~/.ctreeignore`

CTree also supports ignoring files and directories similar to `.gitignore`. Example:

```gitignore
node_modules/
__pycache__/
build/
*.log
```

## Usage

### Basic Usage

Run CTree to generate a directory tree:

```sh
ctree -v .
```

Extract all relevant files with increased verbosity:

```sh
ctree -vv -a > output.ctree
```

### Extracting Specific Code Sections

#### FastAPI Project

To extract all routers from a FastAPI application located in `app/routers/`, use:

```sh
ctree -vv -o app/routers
```

To extract all service modules:

```sh
ctree -vv -o app/services
```

#### Monorepo Structure

Extract all packages from a monorepo:

```sh
ctree -vv -o monorepo/packages
```

Extract all components from an application:

```sh
ctree -vv -o app/components
```

### Customizing Extraction

You can extract specific file extensions using mapped flags:

```sh
ctree -vv -2 -o app/pages
```

Or specify custom extensions:

```sh
ctree -vv -F yaml toml -o config app
```

### Using a Custom Ignore File

```sh
ctree -vv -a -L /path/to/custom_ignore.txt
```

## Why Use CTree?

- Helps manage modular projects by focusing on specific code sections.
- Makes working with AI-assisted coding more efficient by structuring code extraction.
- Keeps your workspace clean when navigating large codebases.
- Allows fine-grained control over extracted content using numeric flags.

More functionality and features will be added as development progresses!

