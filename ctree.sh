#!/usr/bin/env python3
"""
ctree: A command-line utility to generate a tree of files in one or more directories,
excluding specified patterns defined in a .ctreeignore file. Optionally includes
contents of specified file extensions based on verbosity and configuration.

Usage:
    ctree [--verbose|-v] [--path-to-ignore -L PATH] [--exclude-dir -x DIR [DIR ...]]
          [--multi-mode -i DIR [DIR ...]] [--multi-selection -o DIR [DIR ...]]
          [--file-exts -F EXT [EXT ...]] [-1] [-2] [-3] [-4] [-5] [-6] [-7] [-8] [-9] [--10]
          [directories ...]

Options:
    -h, --help              Show this help message and exit.
    -v, --verbose           Increase verbosity level. Use -vv for full contents.
    -a, --all-exts          Include contents for all file extensions (requires -vv).
    -F EXT [EXT ...], --file-exts EXT [EXT ...]
                            Specify file extensions to include contents for when using -vv.
                            Example: -F tsx jsx js css
    -L PATH, --path-to-ignore PATH
                            Specify a custom path to a .ctreeignore file (overrides default behavior).
    -x DIR [DIR ...], --exclude-dir DIR [DIR ...]
                            Specify directories to exclude from verbose content inclusion.
                            Example: -x node_modules build dist
    -i DIR [DIR ...], --multi-mode DIR [DIR ...]
                            Specify directories to apply verbosity to exclusively.
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
    # Generate tree for the current directory with increased verbosity
    ctree -v . > .ctree

    # Generate tree for 'app' and 'pages' directories with full contents for flag -2 extensions
    ctree -vv -2 -o app pages > .ctree

    # Generate tree excluding 'node_modules' and 'build' directories
    ctree -v -x node_modules build . > .ctree

    # Generate tree applying verbosity only to 'src' and 'tests' directories
    ctree -vv -i src tests . > .ctree

    # Include additional extensions via --file-exts
    ctree -vv -1 -F yaml toml -o config app > .ctree

    # Using a custom .ctreeignore file
    ctree -vv -a -L /path/to/custom_ignore.txt app > .ctree
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
        '-v', '--verbose',
        action='count',
        default=0,
        help='Increase verbosity level. Use -vv for full contents.'
    )
    parser.add_argument(
        '-a', '--all-exts',
        action='store_true',
        help='Include contents for all file extensions (requires -vv).'
    )
    parser.add_argument(
        '-F', '--file-exts',
        nargs='+',
        metavar='EXT',
        help='Specify file extensions to include contents for when using -vv. Example: -F tsx jsx js css'
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
        help='Specify directories to exclude from verbose content inclusion. Example: -x node_modules build dist'
    )
    parser.add_argument(
        '-i', '--multi-mode',
        nargs='+',
        metavar='DIR',
        help='Specify directories to apply verbosity to exclusively. Example: -i src tests'
    )
    parser.add_argument(
        '-o', '--multi-selection',
        nargs='+',
        metavar='DIR',
        help='Specify multiple directories to include in the tree. Example: -o src app'
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
""")
        sys.exit(1)
    try:
        config.read(config_path)
        flags_mapping = {}
        if 'flags' in config.sections():
            for key in config['flags']:
                try:
                    flag_num = int(key)
                    if not (1 <= flag_num <= 10):
                        print(f"Warning: Flag number '{flag_num}' out of range (1-10). Ignoring.", file=sys.stderr)
                        continue
                    extensions = [ext.strip().lower() for ext in config['flags'][key].split(',')]
                    flags_mapping[flag_num] = extensions
                except ValueError:
                    print(f"Warning: Invalid flag '{key}' in config. Flags should be numeric (1-10).", file=sys.stderr)
        else:
            print(f"Error: No 'flags' section found in '{config_path}'.", file=sys.stderr)
            sys.exit(1)
        return flags_mapping
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

def read_file_contents(file_path, max_lines=None):
    """
    Read the first few lines of a file to include in the tree.
    If max_lines is None, read the entire file.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = []
            if max_lines is None:
                lines = [line.rstrip('\n') for line in f]
            else:
                for _ in range(max_lines):
                    line = f.readline()
                    if not line:
                        break
                    lines.append(line.rstrip('\n'))
        if max_lines and os.path.getsize(file_path) > 10000:  # Optional: limit for very large files
            lines.append('...')  # Indicate that the file is truncated
        return lines
    except Exception as e:
        return [f"# Error reading file: {e}"]

def generate_tree(root_dirs, verbosity=0, ignore_patterns=None, include_all_exts=False, specific_exts=None, exclude_dirs=None, multi_mode_dirs=None):
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

    if multi_mode_dirs is None:
        multi_mode_dirs = []

    # Normalize exclude_dirs and multi_mode_dirs to absolute paths
    exclude_dirs = [os.path.abspath(d) for d in exclude_dirs]
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
                is_last = index == len(filtered_entries) - 1
                connector = '└── ' if is_last else '├── '
                display_entry = entry + ('/' if os.path.isdir(path) else '')
                tree_lines.append(prefix + connector + display_entry)

                if os.path.isdir(path):
                    extension = '    ' if is_last else '│   '
                    _tree(path, prefix + extension)
                elif verbosity > 1:
                    # Determine if the file's extension should have its contents included
                    _, ext = os.path.splitext(entry)
                    ext = ext.lstrip('.').lower()
                    include_content = False

                    current_abs_path = os.path.abspath(current_path)

                    # Check if multi-mode is enabled and if the current directory is in multi_mode_dirs
                    if multi_mode_dirs:
                        # Only apply verbosity if the current directory is in multi_mode_dirs
                        if current_abs_path in multi_mode_dirs:
                            if include_all_exts:
                                include_content = True
                            elif ext in specific_exts:
                                include_content = True
                    else:
                        # If not in multi-mode, apply globally unless the directory is excluded
                        if current_abs_path not in exclude_dirs:
                            if include_all_exts:
                                include_content = True
                            elif ext in specific_exts:
                                include_content = True

                    if include_content:
                        max_lines = None if verbosity >= 3 else 10  # Adjust as needed
                        contents = read_file_contents(path, max_lines=max_lines)
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
    flags_mapping = load_config(config_path)

    # Collect extensions from numeric flags (-1 to -10)
    specific_exts = []
    for i in range(1, 11):
        flag_attr = f'flag_{i}'
        flag_set = getattr(args, flag_attr, False)
        if flag_set:
            if i in flags_mapping:
                specific_exts.extend(flags_mapping[i])
            else:
                print(f"Warning: No extensions mapped for flag -{i} in config.", file=sys.stderr)

    # Collect extensions from --file-exts
    if args.file_exts:
        normalized_exts = [ext.lower().lstrip('.') for ext in args.file_exts]
        specific_exts.extend(normalized_exts)

    # Remove duplicates
    specific_exts = list(set(specific_exts))

    # Handle --exclude-dir and --multi-mode
    exclude_dirs = args.exclude_dir if args.exclude_dir else []
    multi_mode_dirs = args.multi_mode if args.multi_mode else []

    # Normalize multi_mode_dirs to absolute paths
    multi_mode_dirs = [os.path.abspath(d) for d in multi_mode_dirs]

    # Normalize exclude_dirs to absolute paths
    exclude_dirs = [os.path.abspath(d) for d in exclude_dirs]

    # Check for overlapping directories between exclude_dir and multi_mode
    overlapping_dirs = set(exclude_dirs).intersection(set(multi_mode_dirs))
    if overlapping_dirs:
        print(f"Warning: The following directories are specified in both --exclude-dir and --multi-mode and will be excluded from verbosity: {', '.join(overlapping_dirs)}", file=sys.stderr)
        # Remove overlapping directories from multi_mode_dirs
        multi_mode_dirs = [d for d in multi_mode_dirs if d not in overlapping_dirs]

    # Determine if verbosity requires specific flags
    verbosity = args.verbose

    if verbosity >= 2:
        if not (args.all_exts or specific_exts):
            print("Error: When using -vv, you must specify at least one of the following flags: "
                  "-a, -1 to -10, -F EXT, --multi-selection/-o, --multi-mode/-i", 
                  file=sys.stderr)
            sys.exit(1)

    # Generate the tree
    tree = generate_tree(
        root_dirs=root_dirs,
        verbosity=verbosity,
        ignore_patterns=ignore_patterns,
        include_all_exts=args.all_exts,
        specific_exts=specific_exts,
        exclude_dirs=exclude_dirs,
        multi_mode_dirs=multi_mode_dirs
    )
    print(tree)

if __name__ == '__main__':
    main()
