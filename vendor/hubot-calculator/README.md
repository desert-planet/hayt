hubot-calculator
================

Replacement for hubot's math.coffee script that uses http://mathjs.org/ instead of decommissioned Google calculator

## Installation

### Update the files to include the hubot-calculator module:

#### package.json
    ...
    "dependencies": {
      ...
      "hubot-calculator": ">= 0.4.0"
      ...
    },
    ...

#### external-scripts.json
    [...,"hubot-calculator"]

Run `npm install` to install hubot-calculator and dependencies.

Commands
-----
```
hubot calculate <expression> - Calculate the given math expression.
hubot convert <expression> in <units> - Convert expression to given units.
```

Examples
-----
```
hubot calculate sin(45 deg) ^ 2
@hubot: 0.5
hubot convert 34 L in gal
@hubot: 8.9818492676623 gal
```
