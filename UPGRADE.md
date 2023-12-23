# Upgrade Nodes

* Due to bad dependency versioning, many transitive dependencies are
  automatically being updated to newer versions which no longer support Node
  0.10.
  * To work around this we need to manually hunt down the version of the library
    that was compatible with Node 0.10. NPM still has all of the old versions
    available, but it's up to us to make sure that the correct library is 
  * Also, the version of NPM we have on Node 0.10 is so old that it doesn't
    support overriding dependency versions. So in order to change dependency A's
    version of dependency B, we basically have to fork A and update its
    `package.json` to point to the correct version of dependecy B. This gets
    very annoying if the chain is longer, e.g. A depends on B depends on C
    depends on D, and D is the package that needs to be rolled back. In this
    case, we may well have to locally fork A, B, and C just to control which
    version of D gets used.
