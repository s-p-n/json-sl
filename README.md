# json-sl
json-sl is a project that adds dynamic things to JSON. json-sl
files are valid JSON, not the other way around.

# Requiring json-sl as an NPM Module:
Well, I guess you can install it like this:
```
npm i json-sl
```

K..

The `json-sl` module is a function that takes in JSON and spits out, well, different JSON. Maybe use it like this:
```
    require('json-sl')({
        "list": "range(5,15)",
        "roll": "rand(0,20)",
        "result": ".You Lose!",
        "result if roll in list": ".You win!"
    });
```

# [Playground](https://s-p-n.github.io/json-sl/playground.html)
If I were looking at something (json-sl) I had no idea what it was, but might (somehow) be related to something I was doing, I would want a playground. In fact, I would open [this playground](https://s-p-n.github.io/json-sl/playground.html) in a new tab, and try some of the features from this readme..


# Features
* Perform math using these operators: `!%^*/+-()`
* Generate random data using the `rand(min,max)` function.
* Generate ranges of numbers using `range(to)`, `range(start, end)`, or `range(start, stop, step)`
* Reference properties using their names. `my.attack - opp.defense`
* Use `parent` to walk up. `parent.age`
* Use `prop if val is 1` as a property name to set `prop` only if `val` is `1`.
* Use `prop if in range(0,5)` as a property name to overwrite `prop` if the current value is between 0-5.


# Install from Git
You should have Node.js, NPM, and the 'git' command.
These are instructions for linux, and you may have to 
change some things for Windows.

open a Terminal and use `cd` to get to the place where 
you want the `json-sl` folder to be downloaded.
```
git clone https://github.com/s-p-n/json-sl
cd json-sl
npm i
```


# Running in the Terminal
To run this, get your terminal into the `json-sl` directory.
Once you are there, pass a JSON file to run it like below:
```
node run data/attack.json
```

There are some JSON files that work in the `data` directory.
Those work well as examples. Try copying one, making changes,
and creating something new and interesting.



## Enjoy!
