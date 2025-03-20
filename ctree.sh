#!/usr/bin/env python3
"""
ctree: A command-line utility to generate a tree of files in one or more directories,
excluding specified patterns defined in a .ctreeignore file. Optionally includes
contents of specified file extensions based on configuration.

Usage:
    ctree [--path-to-ignore -L PATH] [--exclude-dir -x DIR [DIR ...]]
          [--recursive-exclude-content -xr DIR [DIR ...]] [--multi-mode -i DIR [DIR ...]]
          [--multi-selection -o DIR [DIR ...]] [--file-exts -F EXT [EXT ...]]
          [--line-limit -ll NUM] [--tree-only -t] [--output-dir -od DIR]
          [-1] [-2] [-3] [-4] [-5] [-6] [-7] [-8] [-9] [--10] [directories ...]

Options:
    -h, --help              Show this help message and exit.
    -t, --tree-only         Output tree structure only, without file contents.
    -a, --all-exts          Include contents for all file extensions.
    -od DIR, --output-dir DIR
                           Specify output directory for .ctree file (default: current directory).
    -F EXT [EXT ...], --file-exts EXT [EXT ...]
                           Specify file extensions to include contents for.
                           Example: -F tsx jsx js css
    -L PATH, --path-to-ignore PATH
                           Specify a custom path to a .ctreeignore file (overrides default behavior).
    -x DIR [DIR ...], --exclude-dir DIR [DIR ...]
                           Specify directories to exclude from content inclusion.
                           Example: -x node_modules build dist
    -xr DIR [DIR ...]      Specify directories to recursively exclude content from, including all subdirectories.
                           Example: -xr node_modules build dist
    -ll NUM, --line-limit NUM
                           Limit the number of lines shown per file (default: unlimited).
    -i DIR [DIR ...], --multi-mode DIR [DIR ...]
                           Specify directories to apply content inclusion to exclusively.
                           Example: -i src tests
    -o DIR [DIR ...], --multi-selection DIR [DIR ...]
                           Specify multiple directories to include in the tree.
                           Example: -o src app
    -1                      Include contents for extensions mapped to flag -1 in ~/.ctreeconf.
    -2                      Include contents for extensions mapped to flag -2 in ~/.ctreeconf.
    -3                      Include contents for extensions mapped to flag -3 in ~/.ctreeconf.
    -4                      Include contents for extensions mapped to flag -4 in ~/.ctreeconf.
    -5                      Include contents for extensions mapped to flag -5 in ~/.ctreeconf.
    -6                      Include contents for extensions mapped to flag -6 in ~/.ctreeconf.
    -7                      Include contents for extensions mapped to flag -7 in ~/.ctreeconf.
    -8                      Include contents for extensions mapped to flag -8 in ~/.ctreeconf.
    -9                      Include contents for extensions mapped to flag -9 in ~/.ctreeconf.
    --10                    Include contents for extensions mapped to flag -10 in ~/.ctreeconf.

Examples:
    # Generate tree structure only for the current directory
    ctree -t . > .ctree

    # Generate tree for 'app' and 'pages' directories with contents for flag -2 extensions
    ctree -2 -o app pages > .ctree

    # Generate tree with contents, limiting each file to 200 lines
    ctree -6 -ll 200 > .ctree
    
    # Generate tree excluding 'node_modules' and all its subdirectories from content inclusion
    ctree -8 -xr node_modules . > .ctree

    # Generate tree applying content inclusion only to 'src' and 'tests' directories
    ctree -1 -i src tests . > .ctree

    # Include additional extensions via --file-exts
    ctree -1 -F yaml toml -o config app > .ctree

    # Using a custom .ctreeignore file
    ctree -a -L /path/to/custom_ignore.txt app > .ctree
"""

import os
import sys
import argparse
import fnmatch
from pathlib import Path
import configparser

def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Generate a tree structure of files in one or more directories, excluding specified patterns defined in a .ctreeignore file."
    )
    parser.add_argument(
        '-t', '--tree-only',
        action='store_true',
        help='Output tree structure only, without file contents.'
    )
    parser.add_argument(
        '-a', '--all-exts',
        action='store_true',
        help='Include contents for all file extensions.'
    )
    parser.add_argument(
        '-ll', '--line-limit',
        type=int,
        metavar='NUM',
        help='Limit the number of lines shown per file (default: unlimited).'
    )
    parser.add_argument(
        '-F', '--file-exts',
        nargs='+',
        metavar='EXT',
        help='Specify file extensions to include contents for. Example: -F tsx jsx js css'
    )
    parser.add_argument(
        '-L', '--path-to-ignore',
        metavar='PATH',
        help='Specify a custom path to a .ctreeignore file (overrides default behavior).'
    )
    parser.add_argument(
        '-x', '--exclude-dir',
        nargs='+',
        metavar='DIR',
        help='Specify directories to exclude from content inclusion. Example: -x node_modules build dist'
    )
    parser.add_argument(
        '-xr',
        nargs='+',
        metavar='DIR',
        help='Specify directories to recursively exclude content from, including all subdirectories. Example: -xr node_modules build dist'
    )
    parser.add_argument(
        '-i', '--multi-mode',
        nargs='+',
        metavar='DIR',
        help='Specify directories to apply content inclusion to exclusively. Example: -i src tests'
    )
    parser.add_argument(
        '-o', '--multi-selection',
        nargs='+',
        metavar='DIR',
        help='Specify multiple directories to include in the tree. Example: -o src app'
    )
    parser.add_argument(
        '-od', '--output-dir',
        metavar='DIR',
        help='Specify output directory for .ctree file (default: current directory)'
    )
    
    # Adding numeric flags -1 to -10
    for i in range(1, 11):
        if i < 10:
            parser.add_argument(
                f'-{i}',
                action='store_true',
                dest=f'flag_{i}',
                help=f'Include contents for extensions mapped to flag -{i} in ~/.ctreeconf.'
            )
        else:
            # argparse does not support multi-digit short options like -10 directly.
            # Hence, we use --10 as a workaround.
            parser.add_argument(
                '--10',
                action='store_true',
                dest='flag_10',
                help='Include contents for extensions mapped to flag -10 in ~/.ctreeconf.'
            )

    parser.add_argument(
        'directories',
        nargs='*',
        default=['.'],
        help='Directories to generate tree from. If --multi-selection is used, specify additional directories with -o.'
    )
    return parser.parse_args()

def load_config(config_path):
    """
    Load the ~/.ctreeconf configuration file.
    The config maps numeric flags (1-10) to file extensions.
    Example:
        [flags]
        1 = py
        2 = tsx, jsx
        3 = js, css
        
        [settings]
        default_filename = project.ctree
    """
    config = configparser.ConfigParser()
    if not os.path.isfile(config_path):
        print(f"Error: Configuration file '{config_path}' not found.", file=sys.stderr)
        print("Please create a '~/.ctreeconf' file with the following format:", file=sys.stderr)
        print("""
[flags]
1 = py
2 = tsx, jsx
3 = js, css
...
10 = java

[settings]
default_filename = project.ctree
""")
        sys.exit(1)
    try:
        config.read(config_path)
        result = {
            'flags_mapping': {},
            'default_filename': 'output.ctree'  # Default value if not specified
        }
        
        # Load flags section
        if 'flags' in config.sections():
            for key in config['flags']:
                try:
                    flag_num = int(key)
                    if not (1 <= flag_num <= 10):
                        print(f"Warning: Flag number '{flag_num}' out of range (1-10). Ignoring.", file=sys.stderr)
                        continue
                    extensions = [ext.strip().lower() for ext in config['flags'][key].split(',')]
                    result['flags_mapping'][flag_num] = extensions
                except ValueError:
                    print(f"Warning: Invalid flag '{key}' in config. Flags should be numeric (1-10).", file=sys.stderr)
        else:
            print(f"Error: No 'flags' section found in '{config_path}'.", file=sys.stderr)
            sys.exit(1)
            
        # Load settings section if it exists
        if 'settings' in config.sections():
            if 'default_filename' in config['settings']:
                result['default_filename'] = config['settings']['default_filename'].strip()
                
        return result
    except Exception as e:
        print(f"Error: Failed to parse configuration file '{config_path}': {e}", file=sys.stderr)
        sys.exit(1)

def load_ignore_patterns(ignore_file_path):
    """
    Load ignore patterns from the specified .ctreeignore file.
    Supports comments and ignores empty lines.
    """
    patterns = []
    try:
        with open(ignore_file_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                patterns.append(line)
    except FileNotFoundError:
        pass
    except Exception as e:
        print(f"# Error reading ignore file '{ignore_file_path}': {e}", file=sys.stderr)
    return patterns

def should_ignore(name, is_dir, ignore_patterns):
    """
    Determine if a file or directory should be ignored based on the ignore patterns.
    """
    for pattern in ignore_patterns:
        # Handle directory patterns ending with '/'
        if pattern.endswith('/'):
            if is_dir and fnmatch.fnmatch(name + '/', pattern):
                return True
        else:
            if fnmatch.fnmatch(name, pattern):
                return True
    return False

def read_file_contents(file_path, line_limit=None):
    """
    Read lines from a file to include in the tree.
    If line_limit is None, read the entire file.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = []
            if line_limit is None:
                lines = [line.rstrip('\n') for line in f]
            else:
                for _ in range(line_limit):
                    line = f.readline()
                    if not line:
                        break
                    lines.append(line.rstrip('\n'))
                
                # Check if there are more lines in the file
                if f.readline():
                    lines.append('...')  # Indicate that the file is truncated
                    
        return lines
    except Exception as e:
        return [f"# Error reading file: {e}"]

def generate_tree(root_dirs, tree_only=False, line_limit=None, ignore_patterns=None, include_all_exts=False, 
                  specific_exts=None, exclude_dirs=None, exclude_recursive_dirs=None, multi_mode_dirs=None):
    """
    Generate the tree structure for the given root directories.
    """
    tree_lines = []

    if ignore_patterns is None:
        ignore_patterns = []

    if specific_exts is None:
        specific_exts = []

    if exclude_dirs is None:
        exclude_dirs = []
        
    if exclude_recursive_dirs is None:
        exclude_recursive_dirs = []

    if multi_mode_dirs is None:
        multi_mode_dirs = []

    # Normalize paths to absolute paths
    exclude_dirs = [os.path.abspath(d) for d in exclude_dirs]
    exclude_recursive_dirs = [os.path.abspath(d) for d in exclude_recursive_dirs]
    multi_mode_dirs = [os.path.abspath(d) for d in multi_mode_dirs]

    for root_dir in root_dirs:
        if not os.path.exists(root_dir):
            print(f"Warning: The directory '{root_dir}' does not exist. Skipping.", file=sys.stderr)
            continue
        if not os.path.isdir(root_dir):
            print(f"Warning: The path '{root_dir}' is not a directory. Skipping.", file=sys.stderr)
            continue

        abs_root = os.path.abspath(root_dir)
        root_name = os.path.basename(abs_root.rstrip('/')) or abs_root
        tree_lines.append(root_name + '/')

        def _tree(current_path, prefix=''):
            try:
                entries = sorted(os.listdir(current_path))
            except PermissionError:
                tree_lines.append(prefix + '└── [Permission Denied]')
                return

            # Filter entries based on ignore patterns
            filtered_entries = []
            for entry in entries:
                full_path = os.path.join(current_path, entry)
                is_dir = os.path.isdir(full_path)
                if should_ignore(entry, is_dir, ignore_patterns):
                    continue
                filtered_entries.append(entry)

            for index, entry in enumerate(filtered_entries):
                path = os.path.join(current_path, entry)
                abs_path = os.path.abspath(path)
                is_last = index == len(filtered_entries) - 1
                connector = '└── ' if is_last else '├── '
                display_entry = entry + ('/' if os.path.isdir(path) else '')
                tree_lines.append(prefix + connector + display_entry)

                if os.path.isdir(path):
                    extension = '    ' if is_last else '│   '
                    _tree(path, prefix + extension)
                elif not tree_only:
                    # Determine if the file's extension should have its contents included
                    _, ext = os.path.splitext(entry)
                    ext = ext.lstrip('.').lower()
                    include_content = False

                    current_abs_path = os.path.abspath(current_path)
                    
                    # Check if the current path is in a recursively excluded directory
                    in_recursive_excluded_dir = False
                    for excl_dir in exclude_recursive_dirs:
                        if current_abs_path == excl_dir or current_abs_path.startswith(excl_dir + os.sep):
                            in_recursive_excluded_dir = True
                            break
                    
                    # Skip content inclusion if in a recursively excluded directory
                    if in_recursive_excluded_dir:
                        continue

                    # Check if multi-mode is enabled and if the current directory is in multi_mode_dirs
                    if multi_mode_dirs:
                        # Only apply content inclusion if the current directory is in multi_mode_dirs
                        for multi_dir in multi_mode_dirs:
                            if current_abs_path == multi_dir or current_abs_path.startswith(multi_dir + os.sep):
                                if include_all_exts:
                                    include_content = True
                                elif ext in specific_exts:
                                    include_content = True
                                break
                    else:
                        # If not in multi-mode, apply globally unless the directory is excluded
                        if current_abs_path not in exclude_dirs:
                            if include_all_exts:
                                include_content = True
                            elif ext in specific_exts:
                                include_content = True

                    if include_content:
                        contents = read_file_contents(path, line_limit=line_limit)
                        for line in contents:
                            tree_lines.append(prefix + ('    ' if is_last else '│   ') + f'    {line}')

        _tree(abs_root)

    return '\n'.join(tree_lines)

def main():
    args = parse_arguments()

    # Handle multi-selection directories
    multi_selection_dirs = args.multi_selection if args.multi_selection else []

    # Handle positional directories
    positional_dirs = args.directories if args.directories else ['.']

    # Combine directories: positional + multi-selection
    root_dirs = positional_dirs + multi_selection_dirs
    
    # Get output directory if specified
    output_dir = args.output_dir if args.output_dir else '.'

    # Determine the ignore file path
    ignore_file = None
    if args.path_to_ignore:
        ignore_file = os.path.abspath(args.path_to_ignore)
        if not os.path.isfile(ignore_file):
            print(f"Error: The specified ignore file '{ignore_file}' does not exist.", file=sys.stderr)
            sys.exit(1)
    else:
        # If multiple root directories, prioritize local .ctreeignore in each root
        # Otherwise, look for a single local .ctreeignore
        local_ctreeignores = [os.path.join(os.path.abspath(d), '.ctreeignore') for d in root_dirs]
        global_ctreeignore = os.path.expanduser('~/.ctreeignore')

        # Collect all existing local .ctreeignore files
        existing_local_ctreeignores = [f for f in local_ctreeignores if os.path.isfile(f)]

        if existing_local_ctreeignores:
            ignore_file = existing_local_ctreeignores  # List of files
        elif os.path.isfile(global_ctreeignore):
            ignore_file = [global_ctreeignore]
        else:
            print("Error: No ~/.ctreeignore found. Please create a ~/.ctreeignore file or specify a custom ignore file using --path-to-ignore/-L.", file=sys.stderr)
            print("You can move your existing .gitignore to ~/.ctreeignore by running:", file=sys.stderr)
            print("    mv /path/to/.gitignore ~/.ctreeignore", file=sys.stderr)
            sys.exit(1)

    # Load ignore patterns from all relevant ignore files
    ignore_patterns = []
    if isinstance(ignore_file, list):
        for f in ignore_file:
            ignore_patterns.extend(load_ignore_patterns(f))
    else:
        ignore_patterns.extend(load_ignore_patterns(ignore_file))

    # Remove duplicates while preserving order
    seen = set()
    ignore_patterns = [x for x in ignore_patterns if not (x in seen or seen.add(x))]

    # Load configuration from ~/.ctreeconf
    config_path = os.path.expanduser('~/.ctreeconf')
    config = load_config(config_path)
    default_filename = config['default_filename']

    # Collect extensions from numeric flags (-1 to -10)
    specific_exts = []
    has_filter_flag = False
    for i in range(1, 11):
        flag_attr = f'flag_{i}'
        flag_set = getattr(args, flag_attr, False)
        if flag_set:
            has_filter_flag = True
            if i in config['flags_mapping']:
                specific_exts.extend(config['flags_mapping'][i])
            else:
                print(f"Warning: No extensions mapped for flag -{i} in config.", file=sys.stderr)

    # Collect extensions from --file-exts
    if args.file_exts:
        has_filter_flag = True
        normalized_exts = [ext.lower().lstrip('.') for ext in args.file_exts]
        specific_exts.extend(normalized_exts)

    # Remove duplicates
    specific_exts = list(set(specific_exts))

    # Handle --exclude-dir, -xr, and --multi-mode
    exclude_dirs = args.exclude_dir if args.exclude_dir else []
    exclude_recursive_dirs = args.xr if args.xr else []
    multi_mode_dirs = args.multi_mode if args.multi_mode else []

    # Normalize to absolute paths
    multi_mode_dirs = [os.path.abspath(d) for d in multi_mode_dirs]
    exclude_dirs = [os.path.abspath(d) for d in exclude_dirs]
    exclude_recursive_dirs = [os.path.abspath(d) for d in exclude_recursive_dirs]

    # Check for overlapping directories between exclude_dir and multi_mode
    overlapping_dirs = set(exclude_dirs).intersection(set(multi_mode_dirs))
    if overlapping_dirs:
        print(f"Warning: The following directories are specified in both --exclude-dir and --multi-mode and will be excluded from content inclusion: {', '.join(overlapping_dirs)}", file=sys.stderr)
        multi_mode_dirs = [d for d in multi_mode_dirs if d not in overlapping_dirs]

    # Check for overlapping directories between exclude_recursive_dirs and multi_mode
    overlapping_recursive_dirs = set(exclude_recursive_dirs).intersection(set(multi_mode_dirs))
    if overlapping_recursive_dirs:
        print(f"Warning: The following directories are specified in both -xr and --multi-mode; -xr takes precedence and will recursively exclude content: {', '.join(overlapping_recursive_dirs)}", file=sys.stderr)
        multi_mode_dirs = [d for d in multi_mode_dirs if d not in overlapping_recursive_dirs]

    # Determine if we should include content or just show the tree
    tree_only = args.tree_only
    
    # If a filter flag is used but tree_only is not specified, we include content
    if has_filter_flag or args.all_exts:
        tree_only = False
        
    # Handle line limit
    line_limit = args.line_limit  # None if not specified

    # Generate the tree
    tree = generate_tree(
        root_dirs=root_dirs,
        tree_only=tree_only,
        line_limit=line_limit,
        ignore_patterns=ignore_patterns,
        include_all_exts=args.all_exts,
        specific_exts=specific_exts,
        exclude_dirs=exclude_dirs,
        exclude_recursive_dirs=exclude_recursive_dirs,
        multi_mode_dirs=multi_mode_dirs
    )
    
    # If any filter flag is used, automatically output to a .ctree file
    if has_filter_flag or args.all_exts:
        # Create output filename based on roots
        if len(root_dirs) == 1 and root_dirs[0] != '.':
            # Use the directory name if there's only one non-current directory
            base_name = os.path.basename(os.path.normpath(root_dirs[0]))
            output_filename = f"{base_name}.ctree"
        else:
            # Otherwise use the default filename from config
            output_filename = default_filename
        
        # Create the full output path
        output_path = os.path.join(output_dir, output_filename)
        
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(tree)
            print(f"Tree saved to {output_path}", file=sys.stderr)
        except Exception as e:
            print(f"Error writing to file {output_path}: {e}", file=sys.stderr)
            # Still print to stdout as fallback
            print(tree)
    else:
        # Just print to stdout for tree-only output
        print(tree)

if __name__ == '__main__':
    main()