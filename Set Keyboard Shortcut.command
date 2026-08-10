#!/bin/zsh
# Interactive, Bitwig-only keyboard shortcut setup for TINACOLLAPSE.

set -euo pipefail

readonly script_directory="${0:A:h}"
readonly packaged_helper="${script_directory}/hotkey/tinacollapse-hotkey"
readonly helper_install_directory="${TINACOLLAPSE_HOTKEY_HELPER_DIR:-${HOME}/.local/lib/TINACOLLAPSE}"
readonly installed_helper="${helper_install_directory}/tinacollapse-hotkey"
readonly command_path="${TINACOLLAPSE_HOTKEY_COMMAND_PATH:-${HOME}/.local/bin/bitwig}"
readonly configuration_directory="${TINACOLLAPSE_HOTKEY_CONFIG_DIR:-${HOME}/.config/TINACOLLAPSE}"
readonly configuration_path="${configuration_directory}/hotkey.plist"
readonly launch_agents_directory="${TINACOLLAPSE_HOTKEY_LAUNCH_AGENTS_DIR:-${HOME}/Library/LaunchAgents}"
readonly launch_agent_label="${TINACOLLAPSE_HOTKEY_LABEL:-fun.sillytina.TINACOLLAPSE.hotkey}"
readonly launch_agent_path="${launch_agents_directory}/${launch_agent_label}.plist"
readonly launch_domain="gui/$(/usr/bin/id -u)"
readonly log_directory="${TINACOLLAPSE_HOTKEY_LOG_DIR:-${HOME}/Library/Logs}"
readonly log_path="${log_directory}/TINACOLLAPSE-hotkey.log"

typeset -gi key_code=0
typeset -gi modifiers=0
typeset -gi modifier_count=0
typeset -g key_name=""

function pause_if_double_clicked()
{
   [[ "${TINACOLLAPSE_HOTKEY_SKIP_PAUSE:-0}" == "1" ]] && return
   [[ "${0:t}" == *.command ]] || return
   print
   read -k 1 "?Press any key to close this window..."
   print
}

function fail()
{
   print -u2
   print -u2 "TINACOLLAPSE keyboard setup failed: $1"
   pause_if_double_clicked
   exit 1
}

function resolve_key()
{
   case "$1" in
      a) key_code=0; key_name="a" ;;
      s) key_code=1; key_name="s" ;;
      d) key_code=2; key_name="d" ;;
      f) key_code=3; key_name="f" ;;
      h) key_code=4; key_name="h" ;;
      g) key_code=5; key_name="g" ;;
      z) key_code=6; key_name="z" ;;
      x) key_code=7; key_name="x" ;;
      c) key_code=8; key_name="c" ;;
      v) key_code=9; key_name="v" ;;
      b) key_code=11; key_name="b" ;;
      q) key_code=12; key_name="q" ;;
      w) key_code=13; key_name="w" ;;
      e) key_code=14; key_name="e" ;;
      r) key_code=15; key_name="r" ;;
      y) key_code=16; key_name="y" ;;
      t) key_code=17; key_name="t" ;;
      1) key_code=18; key_name="1" ;;
      2) key_code=19; key_name="2" ;;
      3) key_code=20; key_name="3" ;;
      4) key_code=21; key_name="4" ;;
      6) key_code=22; key_name="6" ;;
      5) key_code=23; key_name="5" ;;
      =|equals) key_code=24; key_name="=" ;;
      9) key_code=25; key_name="9" ;;
      7) key_code=26; key_name="7" ;;
      -|minus) key_code=27; key_name="-" ;;
      8) key_code=28; key_name="8" ;;
      0) key_code=29; key_name="0" ;;
      \]|rightbracket) key_code=30; key_name="]" ;;
      o) key_code=31; key_name="o" ;;
      u) key_code=32; key_name="u" ;;
      \[|leftbracket) key_code=33; key_name="[" ;;
      i) key_code=34; key_name="i" ;;
      p) key_code=35; key_name="p" ;;
      return|enter) key_code=36; key_name="return" ;;
      l) key_code=37; key_name="l" ;;
      j) key_code=38; key_name="j" ;;
      "'"|quote) key_code=39; key_name="quote" ;;
      k) key_code=40; key_name="k" ;;
      \;|semicolon) key_code=41; key_name="semicolon" ;;
      "\\"|backslash) key_code=42; key_name="backslash" ;;
      ,|comma) key_code=43; key_name="," ;;
      /|slash) key_code=44; key_name="/" ;;
      n) key_code=45; key_name="n" ;;
      m) key_code=46; key_name="m" ;;
      .|period) key_code=47; key_name="." ;;
      tab) key_code=48; key_name="tab" ;;
      space) key_code=49; key_name="space" ;;
      \`|grave) key_code=50; key_name="grave" ;;
      delete|backspace) key_code=51; key_name="delete" ;;
      escape|esc) key_code=53; key_name="escape" ;;
      f17) key_code=64; key_name="f17" ;;
      f18) key_code=79; key_name="f18" ;;
      f19) key_code=80; key_name="f19" ;;
      f20) key_code=90; key_name="f20" ;;
      f5) key_code=96; key_name="f5" ;;
      f6) key_code=97; key_name="f6" ;;
      f7) key_code=98; key_name="f7" ;;
      f3) key_code=99; key_name="f3" ;;
      f8) key_code=100; key_name="f8" ;;
      f9) key_code=101; key_name="f9" ;;
      f11) key_code=103; key_name="f11" ;;
      f13) key_code=105; key_name="f13" ;;
      f16) key_code=106; key_name="f16" ;;
      f14) key_code=107; key_name="f14" ;;
      f10) key_code=109; key_name="f10" ;;
      f12) key_code=111; key_name="f12" ;;
      f15) key_code=113; key_name="f15" ;;
      home) key_code=115; key_name="home" ;;
      pageup) key_code=116; key_name="pageup" ;;
      forwarddelete) key_code=117; key_name="forwarddelete" ;;
      f4) key_code=118; key_name="f4" ;;
      end) key_code=119; key_name="end" ;;
      f2) key_code=120; key_name="f2" ;;
      pagedown) key_code=121; key_name="pagedown" ;;
      f1) key_code=122; key_name="f1" ;;
      left) key_code=123; key_name="left" ;;
      right) key_code=124; key_name="right" ;;
      down) key_code=125; key_name="down" ;;
      up) key_code=126; key_name="up" ;;
      *) return 1 ;;
   esac
}

function add_modifier()
{
   local value="$1"
   if (( (modifiers & value) == 0 ))
   then
      (( modifiers |= value ))
      (( modifier_count += 1 ))
   fi
}

function parse_shortcut()
{
   local shortcut_input="$1"
   local normalized="${shortcut_input:l}"
   normalized="${normalized// /}"
   normalized="${normalized//⌃/control+}"
   normalized="${normalized//⌥/option+}"
   normalized="${normalized//⇧/shift+}"
   normalized="${normalized//⌘/command+}"

   local -a parts
   parts=("${(@s:+:)normalized}")

   local part
   local found_key=0
   for part in "${parts[@]}"
   do
      [[ -n "$part" ]] || continue
      case "$part" in
         command|cmd) add_modifier 256 ;;
         shift) add_modifier 512 ;;
         option|opt|alt) add_modifier 2048 ;;
         control|ctrl) add_modifier 4096 ;;
         *)
            (( found_key == 0 )) ||
               fail "enter exactly one non-modifier key"
            resolve_key "$part" ||
               fail "unsupported key '$part'"
            found_key=1
            ;;
      esac
   done

   (( found_key == 1 )) || fail "include one key after the modifiers"

   if (( modifier_count < 2 )) && [[ "$key_name" != f1[3-9] && "$key_name" != f20 ]]
   then
      fail "use at least two modifiers to avoid stealing a normal typing key"
   fi
}

function canonical_display_name()
{
   local -a display_parts
   (( modifiers & 4096 )) && display_parts+=("control")
   (( modifiers & 2048 )) && display_parts+=("option")
   (( modifiers & 512 )) && display_parts+=("shift")
   (( modifiers & 256 )) && display_parts+=("command")
   display_parts+=("$key_name")
   print -r -- "${(j:+:)display_parts}"
}

function stop_existing_agent()
{
   [[ "${TINACOLLAPSE_HOTKEY_SKIP_LAUNCHCTL:-0}" == "1" ]] && return
   /bin/launchctl bootout "${launch_domain}/${launch_agent_label}" \
      >/dev/null 2>&1 || true
}

function start_existing_agent_if_possible()
{
   [[ "${TINACOLLAPSE_HOTKEY_SKIP_LAUNCHCTL:-0}" == "1" ]] && return
   [[ -f "$launch_agent_path" ]] || return
   /bin/launchctl bootstrap "$launch_domain" "$launch_agent_path" \
      >/dev/null 2>&1 || true
}

[[ "${TINACOLLAPSE_SKIP_OS_CHECK:-0}" == "1" || "$(uname -s)" == "Darwin" ]] ||
   fail "this setup currently supports macOS only"

[[ -x "$command_path" ]] ||
   fail "run './Install collapse' before setting the keyboard shortcut"

/bin/mkdir -p "$helper_install_directory" "$configuration_directory" \
   "$launch_agents_directory" "$log_directory"

if [[ -f "$packaged_helper" ]]
then
   /usr/bin/install -m 0755 "$packaged_helper" "$installed_helper"
fi

[[ -x "$installed_helper" ]] ||
   fail "the native hotkey helper is missing; run './Install collapse' again"

current_display=""
if [[ -f "$configuration_path" ]]
then
   current_display="$(/usr/libexec/PlistBuddy -c 'Print :display' \
      "$configuration_path" 2>/dev/null || true)"
fi

print "TINACOLLAPSE Keyboard Shortcut Setup"
print "This shortcut is registered only while Bitwig Studio is the active app."
if [[ -n "$current_display" ]]
then
   print "Current shortcut: $current_display"
fi
print
print "Enter modifiers and one key separated by +"
print "Example: control+option+command+="
print "For +, include shift and use = as the key: control+command+shift+="
print

shortcut_input="${TINACOLLAPSE_HOTKEY_INPUT:-}"
if [[ -z "$shortcut_input" ]]
then
   read -r "shortcut_input?New shortcut: "
fi
[[ -n "$shortcut_input" ]] || fail "no shortcut was entered"

parse_shortcut "$shortcut_input"
display_name="$(canonical_display_name)"

setup_temporary_directory="$(mktemp -d /private/tmp/tinacollapse-hotkey-setup.XXXXXX)"
trap '/bin/rm -rf -- "$setup_temporary_directory"' EXIT INT TERM

configuration_base="${setup_temporary_directory}/hotkey"
/usr/bin/defaults write "$configuration_base" keyCode -int "$key_code"
/usr/bin/defaults write "$configuration_base" modifiers -int "$modifiers"
/usr/bin/defaults write "$configuration_base" display -string "$display_name"
/usr/bin/defaults write "$configuration_base" commandPath -string "$command_path"
/usr/bin/plutil -convert xml1 "${configuration_base}.plist"

agent_base="${setup_temporary_directory}/agent"
/usr/bin/defaults write "$agent_base" Label -string "$launch_agent_label"
/usr/bin/defaults write "$agent_base" ProgramArguments -array \
   "$installed_helper" --config "$configuration_path"
/usr/bin/defaults write "$agent_base" RunAtLoad -bool true
/usr/bin/defaults write "$agent_base" KeepAlive -bool true
/usr/bin/defaults write "$agent_base" ProcessType -string Interactive
/usr/bin/defaults write "$agent_base" LimitLoadToSessionType -string Aqua
/usr/bin/defaults write "$agent_base" StandardOutPath -string "$log_path"
/usr/bin/defaults write "$agent_base" StandardErrorPath -string "$log_path"
/usr/bin/defaults write "$agent_base" ThrottleInterval -int 5
/usr/bin/plutil -convert xml1 "${agent_base}.plist"

stop_existing_agent
if ! "$installed_helper" --validate "${configuration_base}.plist"
then
   start_existing_agent_if_possible
   fail "that shortcut is reserved or already in use"
fi

/usr/bin/install -m 0600 "${configuration_base}.plist" "$configuration_path"
/usr/bin/install -m 0644 "${agent_base}.plist" "$launch_agent_path"

if [[ "${TINACOLLAPSE_HOTKEY_SKIP_LAUNCHCTL:-0}" != "1" ]]
then
   /bin/launchctl bootstrap "$launch_domain" "$launch_agent_path" ||
      fail "macOS could not start the keyboard shortcut service"
   /bin/launchctl enable "${launch_domain}/${launch_agent_label}"
   /bin/launchctl kickstart -k "${launch_domain}/${launch_agent_label}"
   /bin/launchctl print "${launch_domain}/${launch_agent_label}" \
      >/dev/null || fail "the keyboard shortcut service did not stay running"
fi

print
print "Saved keyboard shortcut: $display_name"
print "It will trigger only while Bitwig Studio is the active application."
print "Reopen this setup at any time to replace the shortcut."
pause_if_double_clicked
