# acd-empty-trash

Empty Trash for Amazon Cloud Drive. Since there's apparently no other way to do it, your trash counts against your quota, and the web UI for emptying trash is garbage once you have a lot files.

**WARNING:** This will irrevocably delete your trash! Use with caution! No warranty guaranteed or implied! Read the all-caps text at the end of the LICENSE!

## Requirements

* Ruby
* [Bundler](http://bundler.io/)
* A working install of [the requirements for the `headless` gem](https://github.com/leonid-shevtsov/headless) (Xvfb/XQuartz...)
* [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/downloads) (`brew install chromedriver` on OS X)

## Usage

Add your Amazon login/password to your `~/.netrc` (which should be readable/writable only by the owner, which you can accomplish with `chmod 600 ~/.netrc`) like so:

    machine amazon.com
      login example@example.com
      password examplepassword

Then:

    bundle exec ./acd-empty-trash.rb

## FAQ

* I get the error: `Display socket is taken but lock file is missing - check the Headless troubleshooting guide`

See this issue/comment on the `headless` gem: <https://github.com/leonid-shevtsov/headless/issues/80#issuecomment-278182878>
