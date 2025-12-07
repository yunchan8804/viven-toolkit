#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const COMMANDS = {
  install: 'install',
  init: 'init',
  help: 'help',
  version: 'version'
};

const COLORS = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  red: '\x1b[31m',
  cyan: '\x1b[36m'
};

function log(message, color = COLORS.reset) {
  console.log(`${color}${message}${COLORS.reset}`);
}

function getPackageVersion() {
  const packageJson = require('../package.json');
  return packageJson.version;
}

function showHelp() {
  console.log(`
${COLORS.cyan}Viven SDK Claude Toolkit${COLORS.reset}
Claude Code development toolkit for Viven SDK Unity VR projects

${COLORS.yellow}Usage:${COLORS.reset}
  npx viven-sdk-claude-toolkit <command>
  viven-toolkit <command>

${COLORS.yellow}Commands:${COLORS.reset}
  ${COLORS.green}install, init${COLORS.reset}    Install toolkit to current directory
  ${COLORS.green}help${COLORS.reset}             Show this help message
  ${COLORS.green}version${COLORS.reset}          Show version

${COLORS.yellow}Examples:${COLORS.reset}
  cd my-unity-project
  npx viven-sdk-claude-toolkit install

${COLORS.yellow}What gets installed:${COLORS.reset}
  - CLAUDE.md          Main guide for Claude Code
  - .claude/           Settings and permissions
  - viven-snippets/    Lua code templates
`);
}

function copyRecursive(src, dest) {
  const stats = fs.statSync(src);

  if (stats.isDirectory()) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }

    const files = fs.readdirSync(src);
    for (const file of files) {
      copyRecursive(path.join(src, file), path.join(dest, file));
    }
  } else {
    fs.copyFileSync(src, dest);
  }
}

function install(targetDir) {
  const templatesDir = path.join(__dirname, '..', 'templates');

  log('\nViven SDK Claude Toolkit Installer', COLORS.cyan);
  log('===================================\n', COLORS.cyan);

  // Check if templates directory exists
  if (!fs.existsSync(templatesDir)) {
    log('Error: Templates directory not found!', COLORS.red);
    process.exit(1);
  }

  // Check if it looks like a Unity project
  const assetsDir = path.join(targetDir, 'Assets');
  if (!fs.existsSync(assetsDir)) {
    log('Warning: Assets folder not found. This may not be a Unity project.', COLORS.yellow);
    log('Continuing anyway...\n', COLORS.yellow);
  }

  // Copy CLAUDE.md
  const claudeMdSrc = path.join(templatesDir, 'CLAUDE.md');
  const claudeMdDest = path.join(targetDir, 'CLAUDE.md');

  if (fs.existsSync(claudeMdSrc)) {
    if (fs.existsSync(claudeMdDest)) {
      log('  [SKIP] CLAUDE.md already exists', COLORS.yellow);
    } else {
      fs.copyFileSync(claudeMdSrc, claudeMdDest);
      log('  [OK] CLAUDE.md', COLORS.green);
    }
  }

  // Create and copy .claude directory
  const claudeDirSrc = path.join(templatesDir, '.claude');
  const claudeDirDest = path.join(targetDir, '.claude');

  if (!fs.existsSync(claudeDirDest)) {
    fs.mkdirSync(claudeDirDest, { recursive: true });
  }

  const settingsFile = path.join(claudeDirDest, 'settings.local.json');
  if (!fs.existsSync(settingsFile)) {
    const settings = {
      permissions: {
        allow: [
          "WebFetch(domain:wiki.viven.app)",
          "WebFetch(domain:sdkdoc.viven.app)"
        ]
      }
    };
    fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2));
    log('  [OK] .claude/settings.local.json', COLORS.green);
  } else {
    log('  [SKIP] .claude/settings.local.json already exists', COLORS.yellow);
  }

  // Copy snippets
  const snippetsSrc = path.join(templatesDir, 'snippets');
  const snippetsDest = path.join(targetDir, 'viven-snippets');

  if (fs.existsSync(snippetsSrc)) {
    if (fs.existsSync(snippetsDest)) {
      log('  [SKIP] viven-snippets already exists', COLORS.yellow);
    } else {
      copyRecursive(snippetsSrc, snippetsDest);
      log('  [OK] viven-snippets/', COLORS.green);
    }
  }

  log('\n' + '='.repeat(40), COLORS.cyan);
  log('Installation complete!', COLORS.green);
  log('\nInstalled files:', COLORS.cyan);
  log('  - CLAUDE.md (Claude Code guide)');
  log('  - .claude/settings.local.json (WebFetch permissions)');
  log('  - viven-snippets/lua/ (Code templates)');
  log('\nYou can now use Claude Code with Viven SDK support!', COLORS.green);
  log('');
}

function main() {
  const args = process.argv.slice(2);
  const command = args[0] || COMMANDS.help;
  const targetDir = process.cwd();

  switch (command.toLowerCase()) {
    case COMMANDS.install:
    case COMMANDS.init:
      install(targetDir);
      break;

    case COMMANDS.version:
    case '-v':
    case '--version':
      log(`v${getPackageVersion()}`);
      break;

    case COMMANDS.help:
    case '-h':
    case '--help':
    default:
      showHelp();
      break;
  }
}

main();
