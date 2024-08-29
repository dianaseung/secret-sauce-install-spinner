# OmniAdmin quick installation for Spinner v1.0
by Dia Seung

Quick Bash Script to help ease installing OmniAdmin for Spinner environments

Link to OmniAdmin: https://github.com/exela/secret-sauce/releases/tag/v0.1.0-barebones

---
## Usage: 
1. Clone repo to drive: `git clone https://github.com/dianaseung/secret-sauce-install-spinner.git`
2. Run `./omniadmin-spinner.sh init` to download jar, and setup jar location. 
3. Add alias to bashrc: alias omni='cp "path/to/omniadmin-spinner.sh" . && ./omniadmin-spinner.sh'
4. Setup a Spinner env (i.e. `./build.sh <lxc-environment>`) and then run `omni`

(*Tip: If you run into permission denied errors, don't forget to run 'chmod +x omniadmin-spinner.sh'*)

---

## Changelogs
- 8/15/24: Added `init` option to download omniadmin jar and set jar location
- 6/25/24: Initial Commit
