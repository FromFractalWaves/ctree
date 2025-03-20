# CTree: Curate Precise Context Snapshots for AI Chats

**CTree** is a CLI tool designed to transform chaotic codebases into structured context snapshots. It allows users to intelligently organizes and extracts code for precise AI interactions, making it invaluable for developers working with AI assistants on complex codebases like Next.js apps or FastAPI backends.

---

## Why CTree?

AI assistants produce brilliant but sometimes unwieldy code. CTree solves this challenge:

- **Curated Context**: Generate precise snapshots that give AI models exactly what they need
- **Targeted Extraction**: Include only relevant files and directories based on configurable filters
- **Modular Development**: Manage incremental updates across complex projects
- **Workflow Control**: Guide AI with proper context instead of overwhelming it

CTree transforms the way you interact with AI coding assistants by providing the perfect amount of context.

---

## Installation

Clone the repository and run the setup script:

```sh
git clone https://github.com/username/ctree.git
cd ctree
chmod +x ctree_setup.sh
./ctree_setup.sh
```

The setup script will:
- Install CTree to `/usr/local/bin` (if you have permissions) or to `~/bin`
- Create configuration files with default settings from templates
- Make backups of any existing configuration files

If you don't have write permissions to `/usr/local/bin`, the script will guide you through alternative options or you can run:

```sh
sudo ./ctree_setup.sh
```

---

## Configuration

The setup script creates two configuration files in your home directory:

### `~/.ctreeconf` (File Filters)

Maps numeric flags to file extensions:

```ini
#~/.ctreeconf

[flags]
1 = tsx, ts
2 = tsx, ts, json
3 = tsx, ts, prisma, json, js, py
4 = prisma, json, js, md, mjs
5 = js
6 = txt, md
7 = txt, sh
8 = py
9 = ts, tsx, py
10 = txt, md

[settings]
default_filename = snapshot.ctree
```

Customize these mappings to match your tech stack.

### `~/.ctreeignore` (Exclusion Patterns)

Uses familiar `.gitignore` syntax:

```gitignore
node_modules/
__pycache__/
*.log
dist/
```

---

## Usage

### Basic Tree Structure

Generate a directory tree without content:

```sh
ctree -t
```

#### Example Output:
```
db_api/
├── __init__.py
├── config.py
├── db.py
├── main.py
├── models.py
├── routers/
│   ├── __init__.py
│   ├── content.py
│   ├── content_item.py
│   ├── embedding.py
│   └── processor.py
├── schemas.py
├── sentences_main.py
└── utils.py
```

### Creating Context Snapshots

Include file contents with configurable line limits:

- Basic usage:
  ```sh
  ctree -8 db_api
  ```

- With line limits (limit to 200 lines per file):
  ```sh
  ctree -8 -ll 200 db_api
  ```

- All file types:
  ```sh
  ctree -a
  ```

### Targeted Context Creation

Focus on specific directories and file types:

```sh
# Extract TypeScript/React files from app and pages directories
ctree -1 -o app pages

# Create snapshot of Python API routers
cd db_api
ctree -8 -ll 200 routers
```

### Advanced Options

- **Recursive Exclusion**: `-xr node_modules` (excludes content from directories and subdirectories)
- **Line Limits**: `-ll 200` (limits lines per file)
- **Custom Output Directory**: `-od ~/snapshots`
- **Selective Inclusion**: `-i src tests` (limits to specific directories)

---

## AI Collaboration Workflow

CTree excels at facilitating structured AI interactions:

1. **Define Task**: Identify what needs to be changed (e.g., update a data type in `content.py`)
2. **Create Context**: Run `ctree -8 -ll 200 routers` to capture the relevant code
3. **Chat with AI**: Upload the `.ctree` file to your AI assistant with clear instructions
4. **Implement Changes**: Apply the AI-generated updates to your codebase
5. **Iterate**: Repeat for other components or refinements
6. **Commit**: Once all changes are complete, commit the entire update

This workflow maintains context integrity and scales from small tweaks to major refactors.

---

## Who Should Use CTree?

- **AI-Assisted Developers**: Create perfect context for AI coding assistants
- **Complex Project Teams**: Manage modular updates in large codebases
- **Framework Specialists**: Extract just what matters in Next.js, FastAPI, or other frameworks

---

## Recent Improvements

- **Automatic Output**: Content snapshots automatically save to `.ctree` files
- **Recursive Exclusion**: New `-xr` flag for excluding directories and subdirectories
- **Flexible Filtering**: Combined numeric flags, custom extensions, and directory targeting
- **Output Control**: Customizable line limits with `-ll` and output destinations

---

CTree bridges the gap between your code and AI assistants, ensuring you get the most value from AI-assisted development while maintaining control over your workflow.