# git-secret-diff
A diff tool for [git secret](https://github.com/sobolevn/git-secret)
 
## What is git-secret-diff
[git secret](https://github.com/sobolevn/git-secret) already has a changes option. But it does not make diffs with other commits.
git-secret-diff allows you to compare encrypted files beetween specific commits or beetween a specific commit and your local changes.
It makes use of the already existing [git secret changes](https://sobolevn.github.io/git-secret/git-secret-changes).

## Prerequesites
[git secret](https://github.com/sobolevn/git-secret) should be installed.

## Command
gitsecret_diff \[files to compare] \[-a | --sha1] \[-b | --sha2] \[-w | --working-dir] \[-p | --password] \[-h | --help]

## Options
```
  files to compare    - If you want to make diff only on certain files of git secret  
  -a | --sha1         - First commit sha. 
                        If only sha1 is provided then git-secret-diff will make a diff beetween sha1 and local.
                        If no sha is provided git-secret-dif will make a diff beetween local decrypted files and the encrypted ones. 
  -b | --sha2         - Second commit sha. If sha2 is provided then git-secret-diff will make a diff beetween sha1 and sha2
                        If Sha2 is provided then sha1 must also exist
  -w | --working-dir  - The working dir for the script to work.
  -p | --password     - The password for git secret reveal
  -h | --help         - Print help screen
```

## Limitations

Due to a bug on git secret changes if various files are provided on \[files to compare] only the first one will be compared.
There's already this issue on git secret project.

## Notes
Only tested on macOS. If you are using macOS please install [gnu getopt](http://brewformulas.org/gnu-getopt), otherwise it might not work. 

## Contributors

* [Miguel Silvestre](https://github.com/msilvestre)
