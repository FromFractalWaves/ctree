#!/bin/bash

# CTree Setup Script
# This script installs CTree and sets up configuration files from templates

# Print with color
print_status() {
  local color="\033[0;32m" # Green
  local reset="\033[0m"
  echo -e "${color}$1${reset}"
}

print_error() {
  local color="\033[0;31m" # Red
  local reset="\033[0m"
  echo -e "${color}$1${reset}"
}

print_info() {
  local color="\033[0;34m" # Blue
  local reset="\033[0m"
  echo -e "${color}$1${reset}"
}

print_warning() {
  local color="\033[0;33m" # Yellow
  local reset="\033[0m"
  echo -e "${color}$1${reset}"
}

# Determine the actual user's home directory, even when run with sudo
if [ -n "$SUDO_USER" ]; then
  USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  USER_HOME="$HOME"
fi

# Script header
echo ""
print_status "=== CTree Setup ==="
echo ""

# Check if we're in the right directory
if [ ! -f "ctree.sh" ] || [ ! -f "ctreeconf.txt" ] || [ ! -f "ctreeignore.txt" ]; then
  print_error "Error: Required files not found."
  print_error "Please run this script from the CTree repository directory."
  echo ""
  exit 1
fi

# Check if running with sudo and warn about config files
if [ -n "$SUDO_USER" ]; then
  print_warning "Running with sudo: Will install config files for user '$SUDO_USER'"
  print_warning "System-wide installation will be done with elevated privileges"
  echo ""
fi

# Step 1: Create backup of existing config files if they exist
if [ -f "$USER_HOME/.ctreeconf" ]; then
  print_info "Creating backup of existing ~/.ctreeconf to ~/.ctreeconf.backup"
  # Use the actual user for operations on home directory files
  if [ -n "$SUDO_USER" ]; then
    sudo -u "$SUDO_USER" cp "$USER_HOME/.ctreeconf" "$USER_HOME/.ctreeconf.backup"
  else
    cp "$USER_HOME/.ctreeconf" "$USER_HOME/.ctreeconf.backup"
  fi
fi

if [ -f "$USER_HOME/.ctreeignore" ]; then
  print_info "Creating backup of existing ~/.ctreeignore to ~/.ctreeignore.backup"
  if [ -n "$SUDO_USER" ]; then
    sudo -u "$SUDO_USER" cp "$USER_HOME/.ctreeignore" "$USER_HOME/.ctreeignore.backup"
  else
    cp "$USER_HOME/.ctreeignore" "$USER_HOME/.ctreeignore.backup"
  fi
fi

# Step 2: Copy configuration files as the real user, not as root
print_status "Installing configuration files to $USER_HOME..."
if [ -n "$SUDO_USER" ]; then
  sudo -u "$SUDO_USER" cp ctreeconf.txt "$USER_HOME/.ctreeconf"
  sudo -u "$SUDO_USER" cp ctreeignore.txt "$USER_HOME/.ctreeignore"
else
  cp ctreeconf.txt "$USER_HOME/.ctreeconf"
  cp ctreeignore.txt "$USER_HOME/.ctreeignore"
fi
echo ""

# Step 3: Install ctree.sh to /usr/local/bin - use sudo privileges if available
print_status "Installing CTree..."
if [ -w /usr/local/bin ] || [ -n "$SUDO_USER" ]; then
  # If running as sudo or have write permissions
  cp ctree.sh /usr/local/bin/ctree
  chmod +x /usr/local/bin/ctree
  print_status "CTree installed to /usr/local/bin/ctree"
else
  print_info "You don't have write permissions to /usr/local/bin."
  print_info "To install CTree system-wide, run this script with sudo:"
  echo ""
  echo "    sudo $0"
  echo ""
  
  # Alternative: Install to user's bin directory if it exists
  if [ -d "$USER_HOME/bin" ]; then
    print_info "Installing to ~/bin instead..."
    cp ctree.sh "$USER_HOME/bin/ctree"
    chmod +x "$USER_HOME/bin/ctree"
    print_status "CTree installed to ~/bin/ctree"
    
    # Check if ~/bin is in PATH
    if [[ ":$PATH:" != *":$USER_HOME/bin:"* ]]; then
      print_info "Note: Make sure ~/bin is in your PATH."
      print_info "You may need to add 'export PATH=\$PATH:\$HOME/bin' to your shell profile."
    fi
  fi
fi

echo ""
print_status "Setup complete!"
print_info "Configuration files installed:"
print_info "  ~/.ctreeconf"
print_info "  ~/.ctreeignore"
echo ""
print_info "Try running 'ctree' to test your installation."
echo ""