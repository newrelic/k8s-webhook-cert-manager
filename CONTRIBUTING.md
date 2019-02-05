# Guidelines for Contributing Code

At New Relic we welcome community code contributions to our code, and have
taken effort to make this process easy for both contributors and our development
team.

## Branches

The head of master will generally have New Relic's latest release. However,
New Relic reserves the ability to push an edge to the master. If you download a
release from this repo, use the appropriate tag. New Relic usually pushes beta
versions of a release to a working branch before tagging them for General
Availability.

## Testing

Ths project includes a basic suite of E2E tests which should be used to
verify your changes don't break existing functionality.

### Running Tests

Running the test suite is simple.  Just invoke:

```bash
$ make e2e-test
```

### Writing Tests

For most contributions it is strongly recommended to add additional tests which
exercise your changes.

This helps us efficiently incorporate your changes into our mainline codebase
and provides a safeguard that your change won't be broken by future development.

There are some rare cases where code changes do not result in changed
functionality (e.g. a performance optimization) and new tests are not required.
In general, including tests with your pull request dramatically increases the
chances it will be accepted.

### And Finally...

If you have any feedback on how we can make contributing easier, please get in
touch at [support.newrelic.com](http://support.newrelic.com) and let us know!
