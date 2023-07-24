# Git Stack extension scripts

This repo contains scripts to enable a stack-based workflow with git. This is achieved by using the [git-stack](https://github.com/gitext-rs/git-stack) extension and a few convenience scripts which extend the functionality of `git-stack`.

## Installation

### Prerequisites

1. Homebrew must be installed
2. `zsh` must be installed

### Install

```
git clone https://github.com/ahmed-envoy/git-stack.git
cd git-stack
./setup-git-stack.sh
```

Run the `setup-git-stack.sh` script. This will

1. Install `rust` and `cargo` so that https://github.com/gitext-rs/git-stack can be installed
2. Install https://github.com/gitext-rs/git-stack
3. Install https://github.com/gitext-rs/git-branch-stash which enables quality of life undo operations
4. Installs the `gh` cli tool which is used to create PRs
5. Updates the `$PATH` in `.zshrc` to point to  the `cargo` bin
6. Updates the `$PATH` in `.zshrc` to point to `~/bin` and copies the scripts in this repo to `~/bin`
7. Runs `git stack alias` which sets up aliases for `git stack` for shorter commands. See https://github.com/gitext-rs/git-stack/blob/main/docs/reference.md#git-stack-alias for more information.

### Updating

`git pull && ./upgrade.sh`

## Getting Started

### Configure your protected branch

One configuration which is not automated is to set the protected branch. 

`git-stack --protect <glob>`

In most cases, this will be `main`, `master` or `develop`. Under the hood, this is stored in your local repo's git config. `.git/config` under `stack.protected-branch`

Please see https://github.com/gitext-rs/git-stack/blob/main/README.md#configuring-git-stack for more information.

### Creating a stack

In `git-stack` a stack is inferred from the current branch and commit ancestry. A stack does not need to be explicitly created.

Regular git commands can be used to create a stack. For example, `git checkout -b <branch> && git commit` will append a new branch and commit to the current stack. Alternatively, you can use the `git bc` extension command.

[![asciicast](https://asciinema.org/a/8jFtGyyRpqkDtjHmACsdul6Qa.svg)](https://asciinema.org/a/8jFtGyyRpqkDtjHmACsdul6Qa)

#### git bc extension command

For convenience, this repository contains an extension command `git bc` which shares the same interface as `git commit` but will create a branch with a name derived from the commit message and commit on that branch. This will also prompt you to setup a branch prefix for the current stack.

`git bc -m "fix: my commit message"`

This is just sugar for `git checkout -b <branch> && git commit`.

#### Branch prefixes

Branch prefixes can be setup for all stacks. The branch prefix configuration is used by the `git bc` command when it generates a branch name.

This repo contains a custom extension command `git bc-prefix` to configure the prefix

`git bc-prefix <prefix>`

This will set the branch prefix for the current stack. This is stored in your local repo's git config. `.git/config`.

You can inspect the current prefix using `git config stack.prefix`

This prefix supports nested shell commands and is evaluated before each commit. This allows you to set a prefix based on the output of other commands or even environment variables.

For example `git bc-prefix 'ahmed/$(date +"%m-%d")'` will set the prefix to `ahmed/01-01` if the current date is January 1st.

### Navigating a stack

To display the current stack, run `git stack`. This will display the current stack and the current branch.

`git stack next` or `git next` will move HEAD to the next commit in the stack. 

`git stack prev` or `git prev` will move HEAD to the previous commit in the stack.

This repository contains two convenience scripts `git top` and `git bottom` which will navigate to the top-most branch or bottom-most branch in the stack respectively.

### Amending a commit in a stack

`git stack amend` or `git amend` will amend the current commit in the stack and will automatically rebase descendents of the current commit.

### Repairing a stack

Let's say you commit to a branch earlier in the stack. This would usually require you to rebase all descendents of that commit. `git stack --repair` will attempt to automatically repair the stack by rebasing all descendents of the current commit.

Please see https://github.com/gitext-rs/git-stack/blob/main/docs/reference.md#git-stack---push for more information.

If you are on git `2.38` there are additional `git rebase` options which can be used to alter the history of a stack. Please see the below links for more information.

- https://git-scm.com/docs/git-rebase#Documentation/git-rebase.txt---update-refs
- https://andrewlock.net/working-with-stacked-branches-in-git-is-easier-with-update-refs/

### Pushing a stack

`git stack --push` will push the current stack to the remote. Please see https://github.com/gitext-rs/git-stack/blob/main/docs/reference.md#git-stack---push for more information.

Sometimes, `git stack --push` will not push a branch. It's unclear as to why. You can workaround this by running the follow command:

`git spush`

This will:

1. Use `git stack run` to run the command on each commit in the stack
2. Use `git srun` (an internal utility command) to run the command on each branch in the stack and avoid protected branches and detached HEADs
3. Use `git fpush` to push the branch to the remote using `git push --force-with-lease origin $BRANCH`

### Running arbitrary commands on an entire stack

`git stack run <command>` will run the command on each commit in the stack. Note, this is not running for each *branch*, it is running for each *commit*. This is useful for running tests on each commit in the stack.

### Stacking PRs on GitHub

The command below will create a PR for the current branch and set the base branch to the parent branch. This is useful for creating a PR for each branch in the stack.

You can run this command more than once. If a PR already exists for the current branch, it will be updated using `git fpush`. It will also automatically run `git prcomment` to update the PR description with the current stack.

`git spr`

This is a wrapper around `git pr create --base $(git parent)` or `gh pr create --base $(git parent)`

If you want to pass custom parameters like `--draft` or `--title` you can do so by using `git pr` or `gh pr` directly. `git pr` is just a wrapper around `gh pr` for convenience sake.

#### Automatic comment

Let's say you've opened a few PRs (manually or otherwise). We can run a script to automatically comment on each PR with the direct parent and direct descendents of the PR. This is useful for tracking the stack of PRs.

`git prcomment` will do this automatically. The comment template looks like this:

```
Current dependencies on/for this PR:

* **PR #<parent_PR_number>
  * **PR #<current_PR_number> 👈
    * **PR #<direct_descendant_PR_number>
    * **PR #<direct_descendant_PR_number>
    * **PR #<direct_descendant_PR_number>
```
