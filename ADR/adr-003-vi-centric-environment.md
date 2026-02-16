# ADR 003: Vi-Centric Development Environment

## Status

**Accepted** - February 2026

## Context

Efficiency in text editing is critical for infrastructure work. This ADR documents the decision to adopt a vi-centric workflow using Vim/Neovim.

## Decision

Build a professional-grade Vim/Neovim configuration optimized for infrastructure work.

### Components

1. **Editor: Neovim**
   - Modern fork of Vim with Lua scripting
   - Built-in LSP support for language features
   - Tree-sitter for syntax highlighting

2. **Terminal Multiplexer: tmux**
   - Session persistence across disconnects
   - Window and pane management
   - Scriptable for automation

3. **CLI Tools**
   - ripgrep (rg) - fast grep alternative
   - fd - fast file finder
   - fzf - fuzzy finder
   - bat - cat clone with syntax highlighting
   - jq - JSON processor
   - curlie - HTTP client

4. **Workflow Integration**
   - Shell keybindings in vim mode
   - Vim-seamless tmux navigation
   - Quick buffer switching

### Key Bindings

```
<Leader>ff - Fuzzy find files
<Leader>fg - Grep in project
<Leader>fb - Buffer list
<Leader>/  - Comment toggle
<C-w>h/j/k/l - Navigate tmux panes
```

## Consequences

### Positive
- Extremely fast text editing
- Keyboard-only workflow (no mouse)
- Highly customizable
- Demonstrates Unix philosophy

### Considerations
- Learning curve for team members
- Requires dotfiles management
- Some IDE features not available

## References

- Neovim Documentation
- Primeagen (Vim tips)
- Modern Vim (book)
