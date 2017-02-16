# git-secret-diff
A diff tool for [git secret](https://github.com/sobolevn/git-secret)
 
## What is git-secret-diff
[git secret](https://github.com/sobolevn/git-secret) already has a changes option. but it does not make diffs with other commits.
git-secret-diff allows you to compare encrypted files beetween specific commits or beetween a specific commit and your local changes.
It makes use of the already existing [git secret changes](https://sobolevn.github.io/git-secret/git-secret-changes)

## Prerequesites
[git secret](https://github.com/sobolevn/git-secret) should be installed.

## Command
gitsecret_diff gitSha1 \[-s | --sha2] \[-w | --working-dir] \[-p | --password] \[-h | --help]

## Options
```
  -s | --sha2         - Second commit sha2. If sha2 is provided then git-secret-diff will make a diff beetween sha1 and sha2
  -w | --working-dir  - The working dir for the script to work.
  -p | --password     - The password for git secret reveal
  -h | --help         - Print help screen
```

## Contributors

* [Miguel Silvestre](https://github.com/msilvestre)
