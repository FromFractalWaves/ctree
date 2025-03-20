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

## Example Usage

im about to modify the repo-analyzer-webui

ok let use

```bash
ctree -xr components -1
```

output

```bash
Tree saved to ./.ctree
```

1600 lines for everything but componenets in ts and tsx

cd to components

```bash
ctree -xr command-manager repositories ui visualizations -1
```

output

```bash
Tree saved to ./.ctree
```

1166 lines for that

now we have 2 files for rag

2766 lines

.ctree is placed in ./.ctree and ./components/.ctree

as we go to each command-manager, repositories, and visualizations the .ctree file ends up in there dirs

so after that we have about 5000 lines so im gonna start with the ./.ctree and ask what files are needed

i ask ai:

"""
Based on the frontend directory tree and the files you've provided, I need to analyze which components we need to understand the project structure. Let me evaluate what would be most helpful:

Looking at the structure, there are several key components that would give us better insight into the project's functionality:

1. `Dashboard.tsx` - This appears to be the main container component based on its usage in `page.tsx`
2. `TabNavigation.tsx` - Referenced in the context for tab navigation
3. `repository/RepositoryDiscovery.tsx` - Core functionality for discovering repositories
4. `visualizations/VisualizationDashboard.tsx` - Main visualization component
5. `JobList.tsx` - For displaying analysis jobs

These components would provide the best overview of how the application works since they appear to be the main structural components referenced in the app context and page layout.

The frontend is a Next.js application with a React-based UI that analyzes Git repositories. It has a context-based state management system (AppContext and ThemeContext) and uses a repository analyzer service to provide visualizations and metrics about Git repositories.

Would you like me to request these specific components to better understand the application's functionality?
"""

lets add components

"""
Looking at the files you've provided, I now have a good understanding of the components directory. The main components that implement the core functionality of the app are already included.

Based on what we have, I think we need a few more files to completely understand the application:

1. `repository/EnhancedRepositoryDiscovery.tsx` - This is referenced in Dashboard.tsx as the main component for the "discover" tab but we don't have its implementation yet.

2. `visualizations/VisualizationDashboard.tsx` - This component is used in ResultsPanel.tsx to display the analysis results.

3. Some of the visualization components like:
   - `visualizations/CommitActivity.tsx`
   - `visualizations/CommitHeatmap.tsx`
   - `visualizations/FileExtensionChart.tsx`
   
4. Additionally, it might be helpful to see:
   - `repository/RepositoryForm.tsx` - For understanding how repositories are created/edited

These components would give us a complete picture of how the application functions, especially the visualization aspect which appears to be a key feature of this Git repository analyzer.

From what I can see so far, this is a Next.js application that:
1. Discovers Git repositories in a file system
2. Allows users to analyze these repositories 
3. Manages analysis jobs
4. Displays visualization results of repository analysis
5. Has a tab-based UI for navigation between discovery, jobs, and results
"""
