# CTree

CTree is a CLI tool designed to keep modular codebases manageable, especially when working with AI-assisted development. It allows you to extract relevant portions of code efficiently while maintaining the modular structure of your project.

Unlike typical AI automation tools, CTree is **a human-centric augmentation tool**—it helps **you** structure and extract code efficiently, rather than replacing human decision-making.

I built CTree using **o1-mini** to push beyond my current skill level, leveraging modular development to scale effectively.

## Why CTree?

Most AI tools focus on **automating tasks** and **replacing human decision-making.** But that approach has a serious flaw:

- 🚫 **AI doesn’t always know what you want**
- 🚫 **AI is unpredictable without good structure**
- 🚫 **AI-generated outputs can be inconsistent**

That’s where **CTree** comes in. It bridges the gap between human intuition and AI execution by giving you a structured way to:

✅ Organize **complex ideas** before sending them to AI  
✅ Generate **clear, structured outputs** that AI tools can follow  
✅ Take advantage of **AI’s capabilities without losing control**  

Instead of fighting against AI’s quirks, CTree **works with them**, making it easier for you to **guide AI into producing better results.**

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

## Who is CTree For?

- **AI developers** who want more structured control over AI outputs  
- **Researchers & engineers** working with complex, multi-layered ideas  
- **Anyone using AI tools like O1-Mini** who wants **more consistency and control**  

If you’ve ever been frustrated by **AI’s unpredictability**, CTree is the missing piece that helps you **take charge of the interaction.**

## Final Thoughts

CTree flips the usual AI workflow on its head. **Instead of AI doing everything, it helps *you* work smarter with AI.**

Rather than treating AI as an **autonomous worker**, CTree treats AI as a **tool that needs proper input to function effectively.** That makes it one of the first **human-first AI augmentation tools**—built to **empower, not replace.**

🚀 **Take control of your AI interactions with CTree.**

